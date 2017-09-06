module Integrations::Etsy

  class ShippingTemplateManager

    def initialize(user, credentials)
      @user = user
      @credentials = credentials
    end

    def reset_templates
      @templates = nil
    end

    def update_shipping_template_id!(item)
      return unless item['ships_from'] && item['shipping_price']

      item['shipping_template_id'] = create_template(item['ships_from'], item['shipping_price']).id
      item.delete 'ships_from'
      item.delete 'shipping_price'
    end

    private

    def self.generate_title(ships_from, shipping_price)
      "~auto-gen by clarabyte app [#{ships_from}, #{shipping_price}]"
    end

    def get_templates
      templates = Etsy::ShippingTemplate.find_by_user(@user, @credentials)
      if templates.is_a?(Enumerable)
        templates
      else
        [templates]
      end
    end

    def create_template(ships_from, shipping_price)
      title = ShippingTemplateManager.generate_title(ships_from, shipping_price)
      @templates ||= get_templates
      template = @templates.find { |template| template.title == title }

      if template.nil? # create one
        country_name = ships_from
        country = Instance.countries.find { |country| country.name == country_name }
        raise "Invalid country '#{country_name}'" unless country

        resp = Etsy::ShippingTemplate.create('title' => title,
                                             'origin_country_id' => country.id,
                                             'primary_cost' => shipping_price,
                                             'secondary_cost' => shipping_price,
                                             access_token: @credentials[:access_token],
                                             access_secret: @credentials[:access_secret])

        template = Etsy::ShippingTemplate.new(resp.result)

        @templates << template if resp.success?
      end

      template
    end
  end
end