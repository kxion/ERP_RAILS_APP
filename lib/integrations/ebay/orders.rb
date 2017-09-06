module Integrations
  module Ebay
    module Orders

      # http://developer.ebay.com/devzone/xml/docs/Reference/eBay/GetOrders.html
      def get_orders(date_from, date_to)
        return [] if date_from.blank? or date_to.blank?
        return [] if !date_from.is_a?(DateTime) or !date_to.is_a?(DateTime)
        return [] if date_from > date_to
        options = {
            CreateTimeFrom: "#{date_from.iso8601}",
            CreateTimeTo: "#{date_to.iso8601}"
        }
        orders = client.call(:GetOrders, options)[:order_array]
        return [] unless orders
        orders[:order].map do |order|
          items = []
          shipping_price = 0.0
          transactions = order.transaction_array.transaction
          transactions = [order.transaction_array.transaction] if order.transaction_array.transaction.is_a?(Hash)
          transactions.each do |transaction|
            shipping_price += transaction.try(:actual_shipping_cost).to_f if transaction.try(:actual_shipping_cost)
            items.push({
                           item_id: transaction.item.item_id,
                           quantity: transaction.quantity_purchased.to_i,
                           price: transaction.try(:actual_handling_cost).try(:to_f) })
          end

          {
              id: order.order_id,
              # status: [:new, :paid, :refunded],
              # http://developer.ebay.com/devzone/xml/docs/Reference/eBay/types/OrderStatusCodeType.html
              payment_status: order.try(:paid_time) ? :paid : :new,
              custom_status: order.order_status,
              created_at: DateTime.parse(order.created_time),
              shipped: order.try(:shipped_time).present?,
              totals: {
                  grandtotal: order.total.to_f
                  # subtotal:
                  # tax
                  # vat
                  # discount
              },
              items: items,
              buyer: {
                  id: order.buyer_user_id,
                  name: order.buyer_user_id,
                  # email
                  # phone_number
              },
              shipping: {
                  name: order.shipping_address.name,
                  country: order.shipping_address.country_name,
                  city: order.shipping_address.city_name,
                  postal_code: order.shipping_address.postal_code,
                  address_line_1: order.shipping_address.street1,
                  address_line_2: order.shipping_address.street2,
                  phone: order.shipping_address.phone,
                  state: order.shipping_address.state_or_province,
                  price: shipping_price,
                  available_carriers: ['UPS-MI', 'USPS', 'FedEx', 'FedExSmartPost'],
                  # carrier
                  # tracking_code
                  # tracking_url
                  # notes
              },

              shipped_at: order.try(:shipped_time) ? DateTime.parse(order.shipped_time) : nil,
              paid_at: order.try(:paid_time) ? DateTime.parse(order.paid_time) : nil,
              payment_method: order.checkout_status.payment_method,
              cancelled: (!order.cancel_detail.cancel_intiation_date.blank? if order.cancel_detail),
              cancelled_at: (order.cancel_detail.cancel_intiation_date if order.cancel_detail),
              cancel_reason: ([order.cancel_detail.cancel_reason, order.cancel_detail.cancel_reason_details].reject(&:blank?).join('. ') if order.cancel_detail),
              # last_update_at: DateTime.parse(order.creation_time),
              # notes
          }
        end
      end

      # http://developer.ebay.com/Devzone/XML/docs/Reference/eBay/GetSellingManagerSoldListings.html
      # def get_orders(date_from, date_to)
      #   return [] if date_from.blank? or date_to.blank?
      #   return [] if !date_from.is_a?(DateTime) or !date_to.is_a?(DateTime)
      #   return [] if date_from > date_to
      #   options = {
      #       SaleDateRange: {
      #           TimeFrom: "#{date_from.iso8601}",
      #           TimeTo: "#{date_to.iso8601}"
      #       }
      #   }
      #   orders = client.call(:GetSellingManagerSoldListings, options)[:sale_record]
      #   return [] unless orders
      #   orders.map do |order|
      #     {
      #         id: order.selling_manager_sold_transaction.order_line_item_id,
      #         # status: [:new, :paid, :cancelled, :refunded],
      #         # http://developer.ebay.com/devzone/xml/docs/Reference/eBay/types/OrderStatusCodeType.html
      #         # {
      #         #   :checkout_status=>"CheckoutIncomplete",
      #         #   :paid_status=>"Unpaid",
      #         #   :shipped_status=>"Unshipped",
      #         #   :payment_method_used=>"None",
      #         #   :feedback_sent=>"false",
      #         #   :total_emails_sent=>"0"
      #         # }
      #         status: order.order_status,
      #         created_at: DateTime.parse(order.creation_time),
      #         shipped: order.try(:shipped_time).present?,
      #         totals: {
      #             grandtotal: order.total_amount.to_f
      #             # subtotal:
      #             # tax
      #             # vat
      #             # discount
      #         },
      #         items: [
      #             {
      #                 item_id: order.selling_manager_sold_transaction.item_id,
      #                 quantity: order.selling_manager_sold_transaction.quantity_sold.to_i,
      #                 price: order.sale_price.to_f
      #             }
      #         ],
      #         buyer: {
      #             id: order.buyer_id,
      #             name: order.buyer_id,
      #             # email
      #             # phone_number
      #         },
      #         shipping: {
      #             name: order.shipping_address.name,
      #             country: order.shipping_address.try(:country_name),
      #             city: order.shipping_address.try(:city_name),
      #             postal_code: order.shipping_address.postal_code,
      #             address_line_1: order.shipping_address.try(:street1),
      #             address_line_2: order.shipping_address.try(:street2),
      #             phone: order.shipping_address.try(:phone),
      #             state: order.shipping_address.try(:state_or_province),
      #             price: order.try(:actual_shipping_cost).try(:to_f),
      #             available_carriers: ['UPS-MI', 'USPS', 'FedEx', 'FedExSmartPost'],
      #             # carrier
      #             # tracking_code
      #             # tracking_url
      #             # notes
      #         },
      #
      #         shipped_at: order.try(:shipped_time) ? DateTime.parse(order.shipped_time) : nil,
      #         custom_status: [order.order_status.paid_status, order.order_status.shipped_status].join(', '),
      #         paid_at: order.try(:paid_time) ? DateTime.parse(order.paid_time) : nil,
      #         payment_method: order.order_status.payment_method_used,
      #         # last_update_at: DateTime.parse(order.creation_time),
      #         # cancelled_at
      #         # cancel_reason
      #         # notes
      #     }
      #   end
      # end

      def update_order(order)
        status = :success
        errors = []
        begin
          if order[:status] == 'cancelled'
            options = { legacyOrderId: order[:order_id] }

            # check if we can cancel order
            check_eligibility = client.call_json('/post-order/v2/cancellation/check_eligibility', options)

            if check_eligibility['eligible']
              options[:cancelReason] = 'OUT_OF_STOCK_OR_CANNOT_FULFILL'
              # request cancellation
              cancel_result = client.call_json('/post-order/v2/cancellation', options)
              unless cancel_result['eligible']
                errors = check_eligibility['failureReason']
                status = :failed
              end
            else
              errors = check_eligibility['failureReason']
              status = :failed
            end
          elsif order[:status] == 'shipped'
            options = {
                OrderID: order[:order_id], # Marketplace order ID
                Shipment: {
                    Notes: order[:notes], # Order notes
                    ShipmentTrackingDetails: {
                        ShipmentTrackingNumber: order[:tracking_code], # Required if new status = shipped
                        ShippingCarrierUsed: order[:shipping_carrier_id], #Shipping carrier ID (from order > shipping > available_carriers > id)
                    }
                }
            }
            complete_sale_result = client.call(:CompleteSale, options)
            if complete_sale_result.ack == 'Failure'
              errors = [complete_sale_result.errors.short_message, complete_sale_result.errors.long_message]
              status = :failed
            end
          end
        rescue => e
          status = :failed
          errors = [e]
        end

        {
            id: order[:order_id],
            status: status,
            errors: errors,
        }
      end

    end
  end
end