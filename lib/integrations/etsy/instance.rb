module Integrations::Etsy

  class Instance < Integrations::Base

    Etsy.protocol = 'https'
    Etsy.api_key = Rails.application.config_for('integrations/etsy')['key']
    Etsy.api_secret = Rails.application.config_for('integrations/etsy')['secret']

    def logged_in?
      credentials && Etsy::User.myself(credentials[:access_token], credentials[:access_secret]) && true
    end

    def add_items(items)
      shipping_template_manager.reset_templates
      items.map { |item| add_item(item, false) }
    end

    def add_item(item, reset_shipping_templates = true)
      shipping_template_manager.reset_templates if reset_shipping_templates

      options = tailor_item_input(item)
      res = tailor_item_output(Etsy::Listing.create(options), item[:id])
      update_images(res, item[:images], item[:state])
      res
    end

    def update_items(items)
      shipping_template_manager.reset_templates
      items.map { |item| update_item(item, false) }
    end

    def update_item(item, reset_shipping_templates = true)
      shipping_template_manager.reset_templates if reset_shipping_templates

      options = tailor_item_input(item)
      listing = Etsy::Listing.new(options)
      res = tailor_item_output(Etsy::Listing.update(listing, options), item[:id])
      update_images(res, item[:images], item[:state])
      res
    end

    def delete_item(item)
      options = tailor_item_input(item)
      listing = Etsy::Listing.new(options)
      tailor_item_output(Etsy::Listing.destroy(listing, options), item[:id])
    end

    def search_items(keywords, count)
      main_keys = [:item_id, :title, :description, :price, :images, :url]
      Array(Etsy::Listing.get_all('/listings/active', keywords: keywords.join(' '), limit: count)).map do |listing|
        {:item => tailor_item_output(listing, nil, main_keys)}
      end
    end

    def get_items(uids, format = :short)
      main_keys = [:item_id, :title, :description, :price, :images, :url]
      main_keys << :data_fields if format == :full
      Array(Etsy::Listing.find(uids, credentials)).map do |listing|
        tailor_item_output(listing, nil, main_keys)
      end
    end

    def categories(parent_id = nil)
      Instance.seller_taxonomy.find_all_subcategories(parent_id.try(:to_i))
    end

    def category_fields(category_id)
      [
          Instance.field('quantity', {for: [:create]}, :integer),
          Instance.field('title', {for: [:create]}, :string),
          Instance.field('description', {for: [:create]}, :string),
          Instance.field('price', {for: [:create]}, :float),
          Instance.field('wholesale_price', false, :float, nil, [:update]),
          Instance.field('materials', false, :array, nil, nil, :string),
          Instance.field('renew', false, :bool, nil, [:update]),
          Instance.field('is_customizable', false, :bool),
          Instance.field('non_taxable', false, :bool),
          Instance.field('image', false, :image, nil, [:create]),
          Instance.field('state', false, :enum, ['active', {title: 'inactive', for: [:update]}, 'draft']),
          Instance.field('item_weight', false, :float, nil, [:update]),
          Instance.field('item_length', false, :float, nil, [:update]),
          Instance.field('item_width', false, :float, nil, [:update]),
          Instance.field('item_height', false, :float, nil, [:update]),
          Instance.field('item_weight_unit', false, :string, nil, [:update]),
          Instance.field('item_dimensions_unit', false, :string, nil, [:update]),
          Instance.field('processing_min', false, :int),
          Instance.field('processing_max', false, :int),
          Instance.field('tags', false, :array, nil, nil, :string),
          Instance.field('who_made', {for: [:create]}, :enum, %w(i_did collective someone_else)),
          Instance.field('is_supply', {for: [:create]}, :bool),
          Instance.field('when_made', {for: [:create]}, :enum, ['made_to_order', '2010_2016', '2000_2009', '1997_1999', 'before_1997', '1990_1996', '1980 s', '1970 s', '1960 s', '1950 s', '1940 s', '1930 s', '1920 s', '1910 s', '1900 s', '1800 s', '1700 s', 'before_1700']),
          Instance.field('recipient', false, :enum, %w(men women unisex_adults teen_boys teen_girls teens boys girls children baby_boys baby_girls babies birds cats dogs pets not_specified)),
          Instance.field('occasion', false, :enum, %w(anniversary baptism bar_or_bat_mitzvah birthday canada_day chinese_new_year cinco_de_mayo confirmation christmas day_of_the_dead easter eid engagement fathers_day get_well graduation halloween hanukkah housewarming kwanzaa prom july_4th mothers_day new_baby new_years quinceanera retirement st_patricks_day sweet_16 sympathy thanksgiving valentines wedding)),
          Instance.field('style', false, :array, nil, nil, :string),

          # shipping profile
          Instance.field('ships_from', {for: [:create]}, :enum, Instance.countries.map { |country| country.name }),
          Instance.field('shipping_price', {for: [:create]}, :float)
      ] unless category_id.blank?
    end

    def get_orders(date_from, date_to)
      all_transactions = Etsy::Transaction.find_all_by_shop_id(current_user.shop.id, credentials.merge(:limit => :all))

      options = credentials.merge(:limit => :all)
      options[:min_created] = date_from if date_from
      options[:max_created] = date_to if date_to
      Etsy::Receipt.find_all_by_shop_id(current_user.shop.id, options).map do |receipt|
        transactions = all_transactions.select { |transaction| transaction.result['receipt_id'] == receipt.id }
        order_to_output(receipt, transactions)
      end
    end

    def update_order(order)
      output = case order[:status]
                 when :shipped then
                   options = credentials.merge(:require_secure => true)
                   options['was_paid'] = true
                   options['was_shipped'] = true
                   res1 = tailor_output(Etsy::Receipt.put("/receipts/#{order[:order_id]}", options))

                   res2 = if order.has_key?(:tracking_code) && order.has_key?(:shipping_carrier_id)
                            options = credentials.merge(:require_secure => true)
                            options['tracking_code'] = order[:tracking_code]
                            options['carrier_name'] = order[:shipping_carrier_id]
                            tailor_output(Etsy::Receipt.post("/shops/#{current_user.shop.id}/receipts/#{order[:order_id]}/tracking", options))
                          end

                   res2 || res1
                 when :cancelled then
                 else
                   {status: :failed, errors: ['Invalid status']}
               end
      output.slice!(:status, :errors)
      output[:id] = order[:id]
      output
    end

    private

    def custom_actions_controller_class
      Integrations::Etsy::CustomActionsController
    end

    def credentials
      state[:credentials]
    end

    def current_user
      @current_user ||= credentials && Etsy::User.myself(credentials[:access_token], credentials[:access_secret])
    end

    def shipping_template_manager
      @shipping_template_manager ||= current_user && ShippingTemplateManager.new(current_user, credentials)
    end

    def update_images(item, image_urls, etsy_state)
      return if item[:status] == :failed
      return unless image_urls

      listing = Etsy::Listing.new(tailor_item_input(item))

      etsy_state[:image_url_id_map] ||= {}

      listing.images.each do |image|
        Etsy::Image.destroy(listing, image, credentials)
      end

      image_urls.each_index do |i|
        url = image_urls[i]
        id = etsy_state[:image_url_id_map][url]

        image_path = nil
        options = {'rank' => i + 1}.merge!(credentials)

        if id then
          options['listing_image_id'] = id
        else
          image_path = open(url).path
        end

        res = tailor_output(Etsy::Image.create(listing, image_path, options))
        etsy_state[:image_url_id_map][url] = res[:listing_image_id] if res.has_key? :listing_image_id
      end
    end

    def map_field(item, dest_field, src_field)
      item[dest_field] = item.delete src_field if item.has_key? src_field
    end

    def tailor_item_input(item)
      options = item.clone
      options.delete :id
      map_field(options, 'listing_id', :item_id)
      map_field(options, 'taxonomy_id', :category_id)
      options.delete :images
      options.delete :state
      options.merge!(item[:data_fields] || {})
      options.delete :data_fields

      options.stringify_keys!
      shipping_template_manager.update_shipping_template_id!(options)
      options.merge!(credentials)
      options
    end

    def tailor_item_output(output, id, main_keys = [:id, :item_id, :url, :status, :errors])
      item = tailor_output(output)
      item[:id] = id if id
      map_field(item, :item_id, :listing_id)

      item[:images] = Etsy::Image.find_all_by_listing_id(item[:item_id], credentials).map { |image| image.full } if main_keys.include? :images
      item[:data_fields] = item.except *main_keys if main_keys.include? :data_fields
      item.slice *main_keys
    end

    def order_to_output(receipt, transactions)
      output = get_fields(receipt, [:id], id: :receipt_id)

      receipt_hash = receipt.result.symbolize_keys
      shipping_details = receipt_hash[:shipping_details].symbolize_keys
      output[:created_at] = Time.at(receipt_hash[:creation_tsz]) if receipt_hash.has_key? :creation_tsz
      output[:last_update_at] = Time.at(receipt_hash[:last_modified_tsz]) if receipt_hash.has_key? :last_modified_tsz
      output[:payment_status] = receipt_hash[:was_paid] ? :paid : :new
      output[:shipped] = receipt_hash[:was_shipped] && true
      output[:shipped_at] = Time.at(shipping_details[:shipment_date]) if shipping_details.has_key? :shipment_date

      output[:totals] = receipt_to_output_totals(receipt)
      output[:items] = transactions_to_output_items(transactions)
      output[:buyer] = receipt_to_output_buyer(receipt)
      output[:shipping] = receipt_shipments_to_output(receipt)

      output
    end

    def receipt_to_output_totals(receipt)
      get_fields(receipt, [:subtotal, :grandtotal, :discount], discount: :discount_amt)
    end

    def transactions_to_output_items(transactions)
      transactions.map do |transaction|
        get_fields(transaction, [:item_id, :quantity, :price], item_id: :listing_id)
      end
    end

    def receipt_to_output_buyer(receipt)
      get_fields(receipt, [:id, :name, :email], id: :buyer_user_id, email: :buyer_email)
    end

    def receipt_shipments_to_output(receipt)
      output = get_fields(receipt, [:price, :name, :city, :state, :postal_code, :address_line_1, :address_line_2],
                          price: :total_shipping_cost, postal_code: :zip, address_line_1: :first_line, address_line_2: :second_line)
      country = Instance.countries.find { |country| country.id == receipt.country_id }
      output[:country] = country.name if country

      shipment = receipt.result['shipments'].last
      output.merge!(get_fields(shipment, [:carrier, :tracking_code, :tracking_url], carrier: :carrier_name)) if shipment

      output
    end

    def tailor_output(output)
      item = output.result
      item = {} unless item.is_a? Hash
      map_field(item, :category_id, 'taxonomy_id')
      item.symbolize_keys!
      item[:status] = output.success? ? :success : :failed if output.is_a? Etsy::Response
      item[:errors] = [output.body] unless output.success? if output.is_a? Etsy::Response
      item
    end

    def get_fields(src, dest_fields, field_map = {})
      src_hash = (src.is_a?(Hash) ? src : src.result).symbolize_keys
      dest_hash = {}
      dest_fields.each do |dest_field|
        src_field = field_map[dest_field] || dest_field
        dest_hash[dest_field] = src_hash[src_field] if src_hash.has_key? src_field
      end
      dest_hash
    end

    def self.seller_taxonomy
      Rails.cache.fetch(:etsy_seller_taxonomy, expires_in: 1.day) do
        json = JSON.parse(Etsy::Request.get('/taxonomy/seller/get').body)
        Taxonomy.new(json)
      end
    end

    def self.countries
      Rails.cache.fetch(:etsy_countries, expires_in: 1.day) do
        Etsy::Country.find_all
      end
    end

    def self.field(name, required, data_type, data_options = nil, used_for = nil, data_subtype = nil)
      {name: name, required: required, data_type: data_type, data_options: data_options, for: used_for, data_subtype: data_subtype}
    end
  end
end