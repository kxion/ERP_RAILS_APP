module Integrations::Shopify

  class Instance < Integrations::Base

    ShopifyAPI::Session.setup(:api_key => Rails.application.config_for('integrations/shopify')['api_key'],
                              :secret => Rails.application.config_for('integrations/shopify')['secret'])

    def initialize(state)
      super(state)

      if @state[:shop] && @state[:access_token]
        @shopify_session = ShopifyAPI::Session.new(@state[:shop], @state[:access_token])
        ShopifyAPI::Base.activate_session(@shopify_session)
      end

      @available_carriers =
          [
              { id: '', title: '' },
              { id: 'Australia Post', title: 'Australia Post' },
              { id: 'Canada Post', title: 'Canada Post' },
              { id: 'DHL', title: 'DHL' },
              { id: 'DHL eCommerce', title: 'DHL eCommerce' },
              { id: 'Eagle', title: 'Eagle' },
              { id: 'FedEx', title: 'FedEx' },
              { id: 'FedEx UK', title: 'FedEx UK' },
              { id: 'New Zealand Post', title: 'New Zealand Post' },
              { id: 'Post Danmark', title: 'Post Danmark' },
              { id: 'Purolator', title: 'Purolator' },
              { id: 'Royal Mail', title: 'Royal Mail' },
              { id: 'TNT', title: 'TNT' },
              { id: 'TNT Post', title: 'TNT Post' },
              { id: 'UPS', title: 'UPS' },
              { id: 'USPS', title: 'USPS' }
          ]
    end

    def logged_in?
      @shopify_session && true
    end

    def add_item(item)
      product = item_to_product(item)
      product.save
      update_images(product, item[:images], item[:state])
      product_to_item(product, item[:id])
    end

    def update_item(item)
      variant = ShopifyAPI::Variant.find(:first, params: { product_id: item[:item_id] })
      product = item_to_product(item, variant.id)
      begin
        product.save
      rescue ActiveResource::ResourceNotFound => ex
        return { id: item[:id], status: :failed, errors: ['The listing doesn\'t exist in your shop'] }
      end
      update_images(product, item[:images], item[:state])
      product_to_item(product, item[:id])
    end

    def delete_item(item)
      product = item_to_product(item)
      begin
        product.destroy
      rescue ActiveResource::ResourceNotFound => ex
        return { id: item[:id], status: :success }
      end
      product_to_item(product, item[:id])
    end

    def search_items(keywords, count)
      []
    end

    def get_items(uids, format = :short)
      main_keys = [:item_id, :title, :description, :price, :images, :url]
      main_keys << :data_fields if format == :full
      ShopifyAPI::Product.find(:all, params: { ids: uids.join(',') }).map do |product|
        product_to_item(product, nil, main_keys)
      end
    end

    def categories(parent_id = nil)
      return [] if parent_id
      [
          { parent_id: nil, id: 0, name: 'Default', has_children: false }
      ]
    end

    def category_fields(category_id)
      [
          Instance.field('title', { for: [:create] }, :string),
          Instance.field('body_html', false, :text, :html),
          Instance.field('inventory_quantity', false, :int),
          Instance.field('price', false, :float),
          Instance.field('compare_at_price', false, :float),
          Instance.field('taxable', false, :bool, nil, true),
          Instance.field('sku', false, :string),
          Instance.field('barcode', false, :string),
          Instance.field('weight', false, :float),
          Instance.field('weight_unit', false, :enum, %w(g kg oz lb)),
          Instance.field('requires_shipping', false, :bool, nil, true),
          Instance.field('product_type', false, :string),
          Instance.field('vendor', false, :string),
          Instance.field('tags', false, :array, nil, nil, nil, :string)
      ]
    end

    def get_orders(date_from, date_to)
      params = { status: :any }
      params[:created_at_min] = date_from if date_from
      params[:created_at_max] = date_to if date_to
      ShopifyAPI::Order.find(:all, params: params).map do |order|
        transactions = ShopifyAPI::Transaction.find(:all, params: { order_id: order.id })
        order_to_output(order, transactions)
      end
    end

    def update_order(order)
      s_order = ShopifyAPI::Order.new(id: order[:order_id])
      s_order.attributes.merge!(get_fields(order, [:note], note: :notes))
      begin
        s_order.save!
      rescue ActiveResource::ResourceNotFound => ex
        return { id: item[:id], status: :failed, errors: ['The order doesn\'t exist in your shop'] }
      end

      output = case order[:status]
                 when :shipped then
                   complete_order(order)
                 when :cancelled then
                   cancel_fulfillments(s_order.fulfillments)
                 else
                   { status: :failed, errors: ['Invalid status'] }
               end
      output[:id] = order[:id]
      output
    end

    private

    def custom_actions_controller_class
      Integrations::Shopify::CustomActionsController
    end

    def item_to_product(item, variant_id = nil)
      fields = item.except(:id, :images, :data_fields, :state).merge(item[:data_fields] || {}).with_indifferent_access

      variant = ShopifyAPI::Variant.new
      variant.attributes = fields.slice(:inventory_quantity, :price, :compare_at_price, :taxable, :sku, :barcode, :weight, :weight_unit, :requires_shipping)
      variant.id = variant_id if variant_id
      variant.attributes.stringify_keys!

      product = ShopifyAPI::Product.new
      product.attributes = fields.slice(:item_id, :body_html, :title, :product_type, :vendor, :tags)
      map_field(product.attributes, :id, :item_id)
      map_field(product.attributes, :body_html, :description)
      product.variants = [variant] unless variant.attributes.empty?
      product.attributes.stringify_keys!

      product
    end

    def product_to_item(product, id, main_keys = [:id, :item_id, :url, :status, :errors])
      item = product.attributes.symbolize_keys.except(:variants, :options, :images, :image)
      item.merge!(product.variants[0].attributes.symbolize_keys.except(:id, :title)) if product.respond_to? :variants
      item[:data_fields] = item.except(:id)

      map_field(item, :item_id, :id)
      item[:category_id] = 0
      map_field(item, :description, :body_html)
      item[:url] = "#{@shopify_session.protocol}://#{@shopify_session.url}/products/#{product.handle}" if product.respond_to? :handle
      item[:images] = product.images.map { |image| image.src } if product.respond_to? :images
      item[:id] = id if id
      set_errors_and_status(item, product)

      item.slice *main_keys
    end

    def update_images(product, image_urls, item_state)
      return unless product.respond_to? :id
      return if product.errors.messages.count > 0
      return unless image_urls

      item_state[:image_url_id_map] ||= {}

      image_ids = image_urls.map { |url| item_state[:image_url_id_map][url] }

      images_to_delete = product.images.reject { |image| image_ids.include? image.id }

      images_to_delete.each do |image|
        image.destroy rescue ActiveResource::ResourceNotFound
      end

      item_state[:image_url_id_map].delete_if { |url, id| images_to_delete.include? id }

      product.images = []

      position = 1

      image_urls.each do |url|
        id = item_state[:image_url_id_map][url]
        image = if id
                  update_image(product.id, position, url, id)
                else
                  add_image(product.id, position, url)
                end

        product.images << image

        item_state[:image_url_id_map][url] = image.id if image.respond_to? :id

        position = image.position + 1 if image.respond_to? :position
      end
    end

    def update_image(product_id, position, url, id)
      image = ShopifyAPI::Image.new(product_id: product_id, position: position, id: id)

      begin
        image.save
      rescue ActiveResource::ResourceNotFound
        image = add_image(product_id, position, url)
      end

      image
    end

    def add_image(product_id, position, url)
      image = ShopifyAPI::Image.new(product_id: product_id, position: position)
      image.attach_image(open(url).read)

      image.save
      image
    end

    def order_to_output(order, transactions)
      output = get_fields(order, [:id, :created_at, :last_update_at, :cancelled_at, :cancel_reason, :notes],
                          last_update_at: :updated_at, notes: :note)
      output[:payment_status] =
          (%w(paid partially_paid partially_refunded).include? order.financial_status) && :paid ||
              'refunded' == order.financial_status && :refunded ||
              :new
      output[:shipped] = %w(fulfilled partial).include? order.fulfillment_status
      output[:shipped_at] = order.fulfillments.last.created_at if order.fulfillments.last
      output[:cancelled] = !!order.cancelled_at
      output[:cancelled_at] = order.cancelled_at

      last_paid_tran = transactions.select { |tran| tran.kind == 'sale' && tran.status == 'success' }.last
      output[:paid_at] = last_paid_tran.created_at if last_paid_tran
      output[:payment_method] = last_paid_tran.gateway if last_paid_tran

      output[:totals] = order_to_output_totals(order)
      output[:items] = order_to_output_items(order)
      output[:buyer] = order_customer_to_output(order.customer) if order.respond_to? :customer
      output[:shipping] = order_shipping_to_output(
          order.fulfillments, order.shipping_address, order.shipping_lines) if order.respond_to? :shipping_address

      output
    end

    def order_to_output_totals(order)
      get_fields(order, [:subtotal, :grandtotal, :tax, :discount],
                 subtotal: :subtotal_price, grandtotal: :total_price, tax: :total_tax, discount: :total_discounts)
    end

    def order_to_output_items(order)
      order.line_items.map do |line_item|
        get_fields(line_item, [:item_id, :quantity, :price], item_id: :id)
      end
    end

    def order_customer_to_output(customer)
      output = get_fields(customer, [:id, :email])
      output[:name] = "#{customer.first_name.strip} #{customer.last_name.strip}".strip
      output
    end

    def order_shipping_to_output(fulfillments, shipping_address, shipping_lines)
      output = get_fields(shipping_address,
                          [:name, :country, :city, :state, :postal_code, :phone, :address_line_1, :address_line_2],
                          state: :province, postal_code: :zip, address_line_1: :address1, address_line_2: :address2)
      output.merge!(get_fields(fulfillments.last, [:carrier, :tracking_code, :tracking_url],
                               carrier: :tracking_company, tracking_code: :tracking_number)) if fulfillments.last

      output[:price] = shipping_lines.last.price if shipping_lines.last
      output[:available_carriers] = @available_carriers

      output
    end

    def complete_order(order)
      fulfillment = ShopifyAPI::Fulfillment.new(order_id: order[:order_id])
      fulfillment.attributes.merge!(
          get_fields(order, [:tracking_company, :tracking_number],
                     tracking_company: :shipping_carrier_id, tracking_number: :tracking_code))
      fulfillment.save
      output = {}
      set_errors_and_status(output, fulfillment)
      output
    end

    def cancel_fulfillments(fulfillments)
      fulfillments.each do |fulfillment|
        fulfillment.cancel rescue ActiveResource::ResourceInvalid
      end
      { status: :success, errors: [] }
    end

    def set_errors_and_status(output, s_base)
      output[:errors] = s_base.errors.messages.map do |field, messages|
        messages.map { |message| "#{field} #{message}" }
      end.flatten
      output[:status] = output[:errors].empty? ? :success : :failed
    end

    def map_field(fields, dest_field, src_field)
      fields[dest_field] = fields.delete src_field if fields.has_key? src_field
    end

    def get_fields(src, dest_fields, field_map = {})
      dest_hash = {}
      src_hash = src.is_a?(ActiveResource::Base) ? src.attributes : src
      dest_fields.each do |dest_field|
        src_field = field_map[dest_field] || dest_field
        dest_hash[dest_field] = src_hash[src_field] if src_hash.has_key? src_field
      end
      dest_hash
    end

    def self.field(name, required, data_type, data_options = nil, default_value = nil, used_for = nil, data_subtype = nil)
      {
          name: name,
          required: required,
          data_type: data_type,
          data_subtype: data_subtype,
          data_options: data_options,
          default_value: default_value,
          for: used_for
      }
    end

  end
end