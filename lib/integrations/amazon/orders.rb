module Integrations
  module Amazon
    module Orders

      # http://docs.developer.amazonservices.com/en_US/orders/2013-09-01/Orders_ListOrders.html
      def get_orders(date_from, date_to)
        puts "hello"
        orders = @client_orders.list_orders(created_after: date_from.strftime('%Y-%m-%d'), created_before: date_to.strftime('%Y-%m-%d'))
        puts orders.parse['Orders']
        ((orders.parse['Orders'] || {})['Order'] || []).map do |order|
          {
              id: order['AmazonOrderId'],
              # Available options
              # Ex: PendingAvailability Pending Unshipped PartiallyShipped Shipped InvoiceUnconfirmed Canceled Unfulfillable
              # Unshipped and PartiallyShipped must be used together
              payment_status: case order['OrderStatus']
                                when 'Pending', 'PendingAvailability', 'Canceled'
                                  :new
                                when 'Unshipped', 'PartiallyShipped', 'Shipped'
                                  :paid
                              end,
              custom_status: order['OrderStatus'],
              created_at: DateTime.parse(order['PurchaseDate']),
              shipped: order['OrderStatus'] == 'Shipped',
              shipped_at: DateTime.parse(order['LatestShipDate']),
              cancelled: order['OrderStatus'] == 'Canceled',

              totals: {
                  grandtotal: order['OrderTotal'] ? order['OrderTotal']['Amount'].to_f : nil,
                  # subtotal:
                  # tax
                  # vat
                  # discount
              },
              items: order_items(order['AmazonOrderId']),
              buyer: {
                  id: order['BuyerEmail'],
                  name: order['BuyerName'],
                  email: order['BuyerEmail'],
                  # phone_number
              },
              shipping: {
                  name: order['ShippingAddress'] ? order['ShippingAddress']['Name'] : nil,
                  country: order['ShippingAddress'] ? order['ShippingAddress']['CountryCode'] : nil,
                  city: order['ShippingAddress'] ? order['ShippingAddress']['City'] : nil,
                  postal_code: order['ShippingAddress'] ? order['ShippingAddress']['PostalCode'] : nil,
                  address_line_1: order['ShippingAddress'] ? order['ShippingAddress']['AddressLine1'] : nil,
                  phone: order['ShippingAddress'] ? order['ShippingAddress']['Phone'] : nil,
                  state: order['ShippingAddress'] ? order['ShippingAddress']['StateOrRegion'] : nil,
                  # price
                  # carrier
                  # tracking_code
                  # tracking_url
                  # notes
                  # available_carriers
              },

              payment_method: order['PaymentMethod'],
              last_update_at: DateTime.parse(order['LastUpdateDate']),
              # cancelled_at
              # cancel_reason
              # notes
              # paid_at
          }
        end
      end

      # http://docs.developer.amazonservices.com/en_US/orders/2013-09-01/Orders_ListOrderItems.html
      def order_items(amazon_order_id)
        items_data = @client_orders.list_order_items(amazon_order_id).parse['OrderItems']
        items = items_data['OrderItem'].is_a?(Hash) ? [items_data['OrderItem']] : items_data['OrderItem']
        items.map do |item|
          {
              item_id: item.try(:[], 'OrderItemId') || item.try(:[], 'SellerSKU') || item.try(:[], 'ASIN'),
              quantity: item['QuantityOrdered'],
              price: item['ItemPrice'] && ((item['QuantityOrdered'] || 0).to_i > 0) ? item['ItemPrice']['Amount'].to_f / item['QuantityOrdered'].to_i : nil,
          }
        end
      end
    end
  end
end