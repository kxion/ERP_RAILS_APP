require 'builder'

module Integrations
  module Amazon
    module Items

      def add_item(item)
        create_update_item(item, :create)
      end

      def update_item(item)
        create_update_item(item, :update)
      end

      def delete_item(item)
        xml = Builder::XmlMarkup.new
        xml.instruct! :xml, :version => "1.0"
        xml.AmazonEnvelope do |envelope|
          envelope.Header do |header|
            header.DocumentVersion '1.01'
            header.MerchantIdentifier @state[:merchant_id]
          end
          envelope.MessageType 'Product'
          envelope.Message do |m|
            m.MessageID '1'
            m.OperationType "Delete"
            m.Product do |p|
              p.SKU item[:item_id]
            end
          end
        end

        submission_id = @client_feeds.submit_feed(xml.target!, '_POST_PRODUCT_DATA_', {}).parse['FeedSubmissionInfo']['FeedSubmissionId'] rescue nil
        raise 'Could not initialize processing an item' unless submission_id
        result = wait_for_feed_result(submission_id)

        processing_summary = result['ProcessingReport']['ProcessingSummary']
        result = result['ProcessingReport']['Result']

        if processing_summary['MessagesWithError'].to_i > 0
          {
              status: :failed,
              id: item[:id],
              errors: result.is_a?(Array) ? result.map { |r| r['ResultDescription'] } : [result['ResultDescription']]
          }
        else
          {
              status: :success,
              id: item[:id]
          }
        end
      end

      def get_item(skus, format = :short)
        @client_products.get_matching_product_for_id('SellerSKU', *skus).parse
      end

      private

      def wait_for_feed_result(submission_id)
        while true
          sleep(5)
          result = @client_feeds.get_feed_submission_result(submission_id).parse rescue nil
          break if result
        end
        result
      end

      def add_schema_fields_to_xml(xml, item, fields, schema_name)
        fields.each { |e|
          # resolve ref if set
          if e['ref']
            element = try_xpath_in_schemas("//xsd:element[@name=\"#{e['ref']}\"]", schema_name, 'amzn-base').reject(&:blank?).first.try(:first)
          else
            element = e
          end
          if element['type']
            type_element = try_xpath_in_schemas("//xsd:simpleType[@name=\"#{element['type']}\"]", schema_name, 'amzn-base').reject(&:blank?).first.try(:first)
            if type_element
              xml.tag!(element['name'], item[element['name']]) if !item[element['name']].blank? || item[element['name']] === false
            elsif element['type'].ends_with?('Dimension') && type_element = try_xpath_in_schemas("//xsd:complexType[@name=\"#{element['type']}\"]", schema_name, 'amzn-base').reject(&:blank?).first.try(:first)
              xml.tag!(element['name'], item[element['name']], 'unitOfMeasure' => item[element['name'] + 'Unit']) unless item[element['name']].blank?
            end
          end
        }
      end

      def create_update_item(item, operation)
        xml = Builder::XmlMarkup.new
        xml.instruct! :xml, :version => "1.0"
        xml.AmazonEnvelope do |envelope|
          envelope.Header do |header|
            header.DocumentVersion '1.01'
            header.MerchantIdentifier @state[:merchant_id]
          end
          envelope.MessageType 'Product'
          envelope.Message do |m|
            m.MessageID '1'
            m.OperationType "#{'Partial' if operation == :update}Update"
            build_product_xml(m, item)
          end
        end

        submission_id = @client_feeds.submit_feed(xml.target!, '_POST_PRODUCT_DATA_', {}).parse['FeedSubmissionInfo']['FeedSubmissionId'] rescue nil
        raise 'Could not initialize processing an item' unless submission_id
        result = wait_for_feed_result(submission_id)

        processing_summary = result['ProcessingReport']['ProcessingSummary']
        result = result['ProcessingReport']['Result']

        # TODO: rework this to using GetMatchingProductForId (now it returns 400 Bad Request for a completely valid request for some reason)
        existing_asin = result.find { |r| r['ResultMessageCode'].to_s == '8542' }['ResultDescription'].split('ASIN')[1].split(',').first.strip rescue nil

        if !existing_asin && processing_summary['MessagesWithError'].to_i > 0
          {
              status: :failed,
              id: item[:id],
              errors: result.is_a?(Array) ? result.map { |r| r['ResultDescription'] } : [result['ResultDescription']]
          }
        else
          if existing_asin
            item[:state][:asin] = existing_asin
            item[:state][:existing_asin] = true
            return create_update_item(item, operation)
          else
            # retrieve ASIN (if we don't have one yet)
            unless item[:state][:asin]
              # TODO: returns 400 Bad Reqest for some reason - need to check back later, maybe a temporary API glitch?
              asin = @client_products.get_matching_product_for_id('SellerSKU', item[:data_fields]['SKU']).parse['Products']['Product']['Identifiers']['MarketplaceASIN']['ASIN'] rescue nil
              item[:state][:asin] = asin
            end
          end
          # update remaining items
          puts update_item_inventory(item, true)
          puts update_item_shipping(item, true)
          puts update_item_pricing(item, true)
          puts upload_item_images(item, true)
          {
              status: :success,
              id: item[:id],
              item_id: item[:data_fields]['SKU'],
              url: ("http://www.amazon.com/dp/#{item[:state][:asin]}" if item[:state][:asin])
          }
        end
      end

      def build_product_xml(xml, item)
        data_fields = item[:data_fields]
        item_category = parse_item_category_id(item[:category_id])
        xml.Product do |p|
          p.SKU data_fields['SKU']
          p.StandardProductID do |pid|
            pid.Type item[:state][:existing_asin] ? 'ASIN' : data_fields['StandardProductIdType']
            pid.Value item[:state][:existing_asin] ? item[:state][:asin] : data_fields['StandardProductId']
          end if !data_fields['StandardProductId'].blank? || item[:state][:existing_asin]
          p.Condition do |c|
            c.ConditionType data_fields['ConditionType']
            c.ConditionNote data_fields['ConditionNote']
          end unless data_fields['ConditionType'].blank?
          unless item[:state][:existing_asin]
            p.DescriptionData do |dd|
              dd.Title data_fields['Title'] unless data_fields['Title'].blank?
              dd.Brand data_fields['Brand'] unless data_fields['Brand'].blank?
              dd.Description data_fields['Description'] unless data_fields['Description'].blank?
              (data_fields['Features'] || [])[0..4].each { |f|
                dd.BulletPoint f
              }
              dd.ItemDimensions do |id|
                id.Length data_fields['ItemLength'], 'unitOfMeasure' => data_fields['ItemLengthUnit'] unless data_fields['ItemLength'].blank?
                id.Width data_fields['ItemWidth'], 'unitOfMeasure' => data_fields['ItemWidthUnit'] unless data_fields['ItemWidth'].blank?
                id.Height data_fields['ItemHeight'], 'unitOfMeasure' => data_fields['ItemHeightUnit'] unless data_fields['ItemHeight'].blank?
                id.Weight data_fields['ItemWeight'], 'unitOfMeasure' => data_fields['ItemWeightUnit'] unless data_fields['ItemWeight'].blank?
              end
              dd.PackageDimensions do |pd|
                pd.Length data_fields['PackageLength'], 'unitOfMeasure' => data_fields['PackageLengthUnit'] unless data_fields['PackageLength'].blank?
                pd.Width data_fields['PackageWidth'], 'unitOfMeasure' => data_fields['PackageWidthUnit'] unless data_fields['PackageWidth'].blank?
                pd.Height data_fields['PackageHeight'], 'unitOfMeasure' => data_fields['PackageHeightUnit'] unless data_fields['PackageHeight'].blank?
                pd.Weight data_fields['PackageWeight'], 'unitOfMeasure' => data_fields['PackageWeightUnit'] unless data_fields['PackageWeight'].blank?
              end
              dd.MaxOrderQuantity data_fields['MaxOrderQuantity'] if data_fields.keys.include?('MaxOrderQuantity')
              dd.Manufacturer data_fields['Manufacturer'] unless data_fields['Manufacturer'].blank?
              dd.MfrPartNumber data_fields['ManufacturerPartNumber'] unless data_fields['ManufacturerPartNumber'].blank?
              (data_fields['SearchTerms'] || [])[0..4].each { |t|
                dd.SearchTerms t
              }
              dd.Memorabilia data_fields['Memorabilia'] if data_fields.keys.include?('Memorabilia')
              dd.Autographed data_fields['Autographed'] if data_fields.keys.include?('Autographed')
              dd.ItemType data_fields['ItemType'] if data_fields.keys.include?('ItemType')
              (data_fields['OtherItemAttributes'] || [])[0..4].each { |t|
                dd.OtherItemAttributes t
              }
              (data_fields['TargetAudience'] || [])[0..3].each { |t|
                dd.TargetAudience t
              }
              dd.IsGiftWrapAvailable data_fields['IsGiftWrapAvailable'] if data_fields.keys.include?('IsGiftWrapAvailable')
              dd.IsGiftMessageAvailable data_fields['IsGiftMessageAvailable'] if data_fields.keys.include?('IsGiftMessageAvailable')
              dd.IsCustomizable data_fields['IsCustomizable'] if data_fields.keys.include?('IsCustomizable')
              dd.RecommendedBrowseNode data_fields['RecommendedBrowseNode'] unless data_fields['RecommendedBrowseNode'].blank?
              (data_fields['PromotionKeywords'] || [])[0..9].each { |k|
                dd.PromotionKeywords k
              }
            end
            p.ProductData do |pd|
              pd.tag!(item_category[:schema]) do |c|
                c.ProductType do |pt|
                  pt.tag!(item_category[:product_type]) do |ptt|
                    # product type specific fields
                    product_type_schema = schema(item_category[:schema]).xpath("//xsd:element[@name=\"#{item_category[:product_type]}\"]").first
                    add_schema_fields_to_xml(ptt, data_fields, product_type_schema.xpath("xsd:complexType/xsd:sequence/xsd:element"), item_category[:schema])
                  end
                end
                # product data fields
                product_schema = schema(item_category[:schema]).xpath("//xsd:element[@name=\"#{item_category[:schema]}\"]").first
                add_schema_fields_to_xml(c, data_fields, product_schema.xpath("xsd:complexType/xsd:sequence/xsd:element"), item_category[:schema])
              end
            end
          end
        end
      end

      def update_item_inventory(item, async = true)
        data_fields = item[:data_fields]
        xml = Builder::XmlMarkup.new
        xml.instruct! :xml, :version => "1.0"
        xml.AmazonEnvelope do |envelope|
          envelope.Header do |header|
            header.DocumentVersion '1.01'
            header.MerchantIdentifier @state[:merchant_id]
          end
          envelope.MessageType 'Inventory'
          envelope.Message do |m|
            m.MessageID '1'
            m.OperationType 'Update'
            m.Inventory do |i|
              i.SKU data_fields['SKU']
              i.Quantity data_fields['Quantity'] unless data_fields['Quantity'].blank?
              i.FulfillmentLatency data_fields['FulfillmentLatency'] unless data_fields['FulfillmentLatency'].blank?
            end
          end
        end

        submission_id = @client_feeds.submit_feed(xml.target!, '_POST_INVENTORY_AVAILABILITY_DATA_', {}).parse['FeedSubmissionInfo']['FeedSubmissionId'] rescue nil
        return false unless submission_id
        async ? true : wait_for_feed_result(submission_id)
      end

      def update_item_shipping(item, async = true)
        data_fields = item[:data_fields]
        return true if data_fields['ShippingOption'].blank?

        xml = Builder::XmlMarkup.new
        xml.instruct! :xml, :version => "1.0"
        xml.AmazonEnvelope do |envelope|
          envelope.Header do |header|
            header.DocumentVersion '1.01'
            header.MerchantIdentifier @state[:merchant_id]
          end
          envelope.MessageType 'Override'
          envelope.Message do |m|
            m.MessageID '1'
            m.OperationType 'Update'
            m.Override do |o|
              o.SKU data_fields['SKU']
              o.ShippingOverride do |so|
                so.ShipOption data_fields['ShippingOption']
                so.Type 'Exclusive'
                so.ShipAmount data_fields['ShippingPrice'], 'currency' => 'USD'
              end
            end
          end
        end

        submission_id = @client_feeds.submit_feed(xml.target!, '_POST_PRODUCT_OVERRIDES_DATA_', {}).parse['FeedSubmissionInfo']['FeedSubmissionId'] rescue nil
        return false unless submission_id
        async ? true : wait_for_feed_result(submission_id)
      end

      def update_item_pricing(item, async = true)
        data_fields = item[:data_fields]
        xml = Builder::XmlMarkup.new
        xml.instruct! :xml, :version => "1.0"
        xml.AmazonEnvelope do |envelope|
          envelope.Header do |header|
            header.DocumentVersion '1.01'
            header.MerchantIdentifier @state[:merchant_id]
          end
          envelope.MessageType 'Price'
          envelope.Message do |m|
            m.MessageID '1'
            m.OperationType 'Update'
            m.Price do |p|
              p.SKU data_fields['SKU']
              p.StandardPrice data_fields['Price'], 'currency' => "USD"
              p.Sale do |s|
                # todo: yuck! add this to custom fields? or extract from Sale Events?
                s.StartDate "#{Date.today}T00:00:00Z"
                s.EndDate "#{Date.today.advance(:years => 2)}T00:00:00Z"
                s.SalePrice data_fields['SalePrice'], 'currency' => "USD"
              end unless data_fields['SalePrice'].blank?
            end
          end
        end

        submission_id = @client_feeds.submit_feed(xml.target!, '_POST_PRODUCT_PRICING_DATA_', {}).parse['FeedSubmissionInfo']['FeedSubmissionId'] rescue nil
        return false unless submission_id
        async ? true : wait_for_feed_result(submission_id)
      end

      def upload_item_images(item, async = true)
        data_fields = item[:data_fields]
        xml = Builder::XmlMarkup.new
        xml.instruct! :xml, :version => "1.0"
        xml.AmazonEnvelope do |envelope|
          envelope.Header do |header|
            header.DocumentVersion '1.01'
            header.MerchantIdentifier @state[:merchant_id]
          end
          envelope.MessageType 'ProductImage'
          item[:images].each_with_index { |img_url, i|
            envelope.Message do |m|
              m.MessageID (i + 1)
              m.OperationType 'Update'
              m.ProductImage do |img|
                img.SKU data_fields['SKU']
                img.ImageType i == 0 ? 'Main' : "PT#{i}"
                img.ImageLocation img_url
              end
            end
          }
        end

        submission_id = @client_feeds.submit_feed(xml.target!, '_POST_PRODUCT_IMAGE_DATA_', {}).parse['FeedSubmissionInfo']['FeedSubmissionId'] rescue nil
        return false unless submission_id
        async ? true : wait_for_feed_result(submission_id)
      end

    end
  end
end