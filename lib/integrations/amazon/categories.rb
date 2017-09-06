module Integrations
  module Amazon
    module Categories
      def categories(root_category_id = nil)
        if root_category_id
          return [] if root_category_id.split('#').length > 1
          doc = Nokogiri::XML(open("https://images-na.ssl-images-amazon.com/images/G/01/rainier/help/xsd/release_1_9/#{root_category_id}.xsd")) rescue nil
          return [] unless doc
          [doc.xpath('//xsd:element[@name="ProductType"]/xsd:complexType//xsd:element[@ref]'), doc.xpath('//xsd:element[@name="ProductType"]/xsd:simpleType//xsd:enumeration[@value]')].reject(&:blank?).first.map { |c|
            {
                id: "#{root_category_id}##{c['ref'] || c['value']}",
                name: c['ref'] || c['value'],
                parent_id: root_category_id,
                has_children: false
            }
          }
        else
          doc = Nokogiri::XML(open('https://images-na.ssl-images-amazon.com/images/G/01/rainier/help/xsd/release_1_9/Product.xsd'))
          doc.xpath('//xsd:element[@name="ProductData"]//xsd:element[@ref]').map { |c|
            {
                id: c['ref'],
                name: c['ref'],
                parent_id: nil,
                has_children: true
            }
          }
        end
      end

      def category_fields(category_id)
        generic_fields = [
            # General
            {
                name: 'Title',
                required: true,
                data_type: :string
            },
            {
                name: 'Brand',
                required: true,
                data_type: :string
            },
            {
                name: 'Description',
                required: true,
                data_type: :text
            },
            {
                name: 'Manufacturer',
                required: true,
                data_type: :string
            },
            {
                name: 'Features',
                required: true,
                data_type: :array,
                data_subtype: :string,
                max_items: 5
            },
            {
                name: 'ManufacturerPartNumber',
                required: { for: :create },
                data_type: :string
            },
            {
                name: 'StandardProductIdType',
                required: { for: :create },
                data_type: :enum,
                data_options: get_schema_enumeration_values('amzn-base', 'StandardProductID'),
            },
            {
                name: 'StandardProductId',
                required: { for: :create },
                data_type: :string
            },
            {
                name: 'SKU',
                required: true,
                data_type: :string
            },
            {
                name: 'ConditionType',
                required: true,
                data_type: :enum,
                data_options: get_schema_enumeration_values('amzn-base', 'ConditionType'),
            },
            {
                name: 'ConditionNote',
                data_type: :text
            },
            {
                name: 'ItemType',
                required: true,
                data_type: :string
            },
            {
                name: 'RecommendedBrowseNode',
                required: true,
                data_type: :string
            },
            {
                name: 'Price',
                required: true,
                data_type: :float
            },
            {
                name: 'SalePrice',
                data_type: :float
            },
            {
                name: 'Quantity',
                required: true,
                data_type: :int
            },
            {
                name: 'FulfillmentLatency',
                data_type: :int
            },
            {
                name: 'ShippingOption',
                data_type: :enum,
                data_options: [
                    'Exp APO/FPO PO Box',
                    'Exp APO/FPO Street Addr',
                    'Exp Alaska Hawaii PO Box',
                    'Exp Alaska Hawaii Street Addr',
                    'Exp Cont US PO Box',
                    'Exp Cont US Street Addr',
                    'Exp US Prot PO Box',
                    'Exp US Prot Street Addr',
                    'Std APO/FPO PO Box',
                    'Std APO/FPO Street Addr',
                    'Std Alaska Hawaii PO Box',
                    'Std Alaska Hawaii Street Addr',
                    'Std Cont US PO Box',
                    'Std Cont US Street Addr',
                    'Std US Prot PO Box',
                    'Std US Prot Street Addr',

                    'Exp Europe',
                    'Exp Asia',
                    'Exp Canada',
                    'Exp Outside US, EU, CA, Asia',
                    'Std Europe',
                    'Std Asia',
                    'Std Canada',
                    'Std Outside US, EU, CA, Asia',

                    'Exp UK Dom',
                    'Std UK Asia 1',
                    'Std UK Asia 2',
                    'Std UK BFPO',
                    'Std UK Dom',
                    'Std UK Europe 1',
                    'Std UK Europe 2',
                    'Std UK Europe 3',
                    'Std UK NA',
                    'Std UK Off-mainland',
                    'Std UK PO Box',
                    'Std UK ROW',

                    'Std CA Dom',
                    'Exp CA Dom',
                    'Std CA US',
                    'Exp CA US',
                    'Std CA Asia',
                    'Exp CA Asia',
                    'Std CA Europe',
                    'Exp CA Europe',
                    'Std CA ROW',

                ]
            },
            {
                name: 'ShippingPrice',
                data_type: :float
            },

            # Item Dimensions
            {
                name: 'ItemLength',
                data_type: :int
            },
            {
                name: 'ItemLengthUnit',
                data_type: :enum,
                data_options: get_schema_enumeration_values('amzn-base', 'LengthUnitOfMeasure')
            },
            {
                name: 'ItemWidth',
                data_type: :int
            },
            {
                name: 'ItemWidthUnit',
                data_type: :enum,
                data_options: get_schema_enumeration_values('amzn-base', 'LengthUnitOfMeasure')
            },
            {
                name: 'ItemHeight',
                data_type: :int
            },
            {
                name: 'ItemHeightUnit',
                data_type: :enum,
                data_options: get_schema_enumeration_values('amzn-base', 'LengthUnitOfMeasure')
            },
            {
                name: 'ItemWeight',
                data_type: :int
            },
            {
                name: 'ItemWeightUnit',
                data_type: :enum,
                data_options: get_schema_enumeration_values('amzn-base', 'WeightUnitOfMeasure')
            },

            # Package Dimensions
            {
                name: 'PackageLength',
                data_type: :int
            },
            {
                name: 'PackageLengthUnit',
                data_type: :enum,
                data_options: get_schema_enumeration_values('amzn-base', 'LengthUnitOfMeasure')
            },
            {
                name: 'PackageWidth',
                data_type: :int
            },
            {
                name: 'PackageWidthUnit',
                data_type: :enum,
                data_options: get_schema_enumeration_values('amzn-base', 'LengthUnitOfMeasure')
            },
            {
                name: 'PackageHeight',
                data_type: :int
            },
            {
                name: 'PackageHeightUnit',
                data_type: :enum,
                data_options: get_schema_enumeration_values('amzn-base', 'LengthUnitOfMeasure')
            },
            {
                name: 'PackageWeight',
                data_type: :int
            },
            {
                name: 'PackageWeightUnit',
                data_type: :enum,
                data_options: get_schema_enumeration_values('amzn-base', 'WeightUnitOfMeasure')
            },

            # Additional
            {
                name: 'MaxOrderQuantity',
                data_type: :int
            },
            {
                name: 'SearchTerms',
                data_type: :array,
                data_subtype: :string,
                max_items: 5
            },
            {
                name: 'PromotionKeywords',
                data_type: :array,
                data_subtype: :string,
                max_items: 10
            },
            {
                name: 'TargetAudience',
                data_type: :array,
                data_subtype: :string,
                max_items: 4
            },
            {
                name: 'OtherItemAttributes',
                data_type: :array,
                data_subtype: :string,
                max_items: 5
            },
            {
                name: 'IsGiftWrapAvailable',
                data_type: :bool
            },
            {
                name: 'IsGiftMessageAvailable',
                data_type: :bool
            },
            {
                name: 'Memorabilia',
                data_type: :bool
            },
            {
                name: 'Autographed',
                data_type: :bool
            },
            {
                name: 'IsCustomizable',
                data_type: :bool
            },
        ]
        # now let's retrieve category-specific fields
        item_category = parse_item_category_id(category_id)
        product_schema = schema(item_category[:schema]).xpath("//xsd:element[@name=\"#{item_category[:schema]}\"]").first
        product_type_schema = schema(item_category[:schema]).xpath("//xsd:element[@name=\"#{item_category[:product_type]}\"]").first
        specific_fields = ((product_type_schema.xpath("xsd:complexType/xsd:sequence/xsd:element") rescue []) + product_schema.xpath("xsd:complexType/xsd:sequence/xsd:element")).map { |e|
          # resolve ref fs set
          if e['ref']
            element = try_xpath_in_schemas("//xsd:element[@name=\"#{e['ref']}\"]", item_category[:schema], 'amzn-base').reject(&:blank?).first.try(:first)
          else
            element = e
          end
          if element['type']
            type_element = try_xpath_in_schemas("//xsd:simpleType[@name=\"#{element['type']}\"]", item_category[:schema], 'amzn-base').reject(&:blank?).first.try(:first)
            if type_element
              if (enumeration_options = type_element.xpath(".//xsd:enumeration")) && enumeration_options.count > 0
                {
                    name: element['name'],
                    data_type: :enum,
                    data_options: enumeration_options.map { |o| o['value'] }
                }
              else
                case type_element.xpath("xsd:restriction").first['base']
                  when 'xsd:string', 'xsd:normalizedString'
                    {
                        name: element['name'],
                        data_type: (type_element.xpath(".//xsd:maxLength").first['value'].to_i > 200 rescue false) ? :text : :string
                    }
                  when 'xsd:decimal'
                    {
                        name: element['name'],
                        data_type: :float
                    }
                  when 'xsd:integer', 'xsd:positiveInteger'
                    {
                        name: element['name'],
                        data_type: :int
                    }
                end
              end
            elsif element['type'].ends_with?('Dimension') && type_element = try_xpath_in_schemas("//xsd:complexType[@name=\"#{element['type']}\"]", item_category[:schema], 'amzn-base').reject(&:blank?).first.try(:first)
              units_type_name = type_element.xpath(".//xsd:attribute[@name=\"unitOfMeasure\"]").first['type'] rescue nil
              if units_type_name && units_type_element = try_xpath_in_schemas("//xsd:simpleType[@name=\"#{units_type_name}\"]", item_category[:schema], 'amzn-base').reject(&:blank?).first.try(:first)
                [
                    {
                        name: element['name'],
                        data_type: :float
                    },
                    {
                        name: "#{element['name']}Unit",
                        data_type: :enum,
                        data_options: units_type_element.xpath(".//xsd:enumeration").map { |o| o['value'] }
                    }
                ]
              end
            end
          end
        }.uniq.flatten.compact
        (generic_fields + specific_fields).uniq { |f| f[:name] }
      end

      private

      def schema(name)
        @schema ||= {}
        @schema[name] ||= Nokogiri::XML(open("https://images-na.ssl-images-amazon.com/images/G/01/rainier/help/xsd/release_1_9/#{name}.xsd"))
      end

      def get_schema_enumeration_values(schema_name, type_name)
        res = schema(schema_name).xpath("//xsd:simpleType[@name=\"#{type_name}\"]//xsd:enumeration[@value]").map { |e| e['value'] }
        res = schema(schema_name).xpath("//xsd:element[@name=\"#{type_name}\"]//xsd:enumeration[@value]").map { |e| e['value'] } if res.blank?
        res
      end

      def try_xpath_in_schemas(xpath, *schemas)
        schemas.map { |s|
          schema(s).xpath(xpath)
        }
      end

      def parse_item_category_id(category_id)
        {
            :schema => category_id.split('#')[0],
            :product_type => category_id.split('#')[1]
        }
      end

      # %w{CE Computers Home HomeImprovement Tools Health Sports Jewelry CameraPhoto}.map {|t| schema(t).xpath("//xsd:element[@type]").map {|e| e['type'] }.select {|t| schema('amzn-base').xpath("//xsd:simpleType[@name=\"#{t}\"]").count > 0 } }.flatten.group_by {|e| e}

    end
  end
end