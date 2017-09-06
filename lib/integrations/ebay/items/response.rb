module Integrations
  module Ebay
    module Items
      module Response

        def process_response(response)
          errors = process_response_messages(response, 'error')
          {
              errors: errors,
              warnings: process_response_messages(response, 'warning'),
              fees: process_response_fees(response),
              item_id: response.try(:item_id),
              status: errors.blank? ? :success : :error,
              listing_ends_at: (DateTime.parse(response.end_time) if response.try(:end_time)),
              url: "http://#{client.sandbox ? "cgi.sandbox.ebay.com/itm/" : "ebay.com/itm/"}#{response.try(:item_id)}"
          }
        end

        def process_response_messages(response, type)
          return [] unless response.try(:errors)
          convert_element = lambda do |el|
            [el.short_message, el.long_message].uniq.join(': ') if el.severity_code.downcase == type.to_s.downcase
          end
          return [convert_element.call(response.errors)].compact if response.errors.is_a?(Hash)
          response.errors.map { |error| convert_element.call(error) }.compact
        end

        def process_response_fees(response)
          return unless response.try(:fees)
          return unless response.fees.try(:fee)
          response.fees.fee
        end

      end
    end
  end
end