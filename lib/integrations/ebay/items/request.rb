module Integrations
  module Ebay
    module Items
      module Request

        def delete_item(params)
          response = client.call(:EndItem, {EndingReason: 'NotAvailable', ItemID: params[:item_id]})
          response.instance_eval { undef :errors } if response.try(:errors) && response.errors.error_code == '1047'
          process_response(response).merge(id: params[:id])
        end

        # VerifyAddItem
        # Can be used for testing
        # return the same as AddItem/ReviseItem/RelistItem
        def verify_item(params)
          process_response(client.call(:VerifyAddItem, item_params(params)))
        end

        # AddItem
        # List new item
        # return item_id & fees or errors
        def add_item(params)
          # need to store that in state here
          # because listing_format won't be passed to update_item params (it's create-only param)
          params[:state][:listing_format] = params[:data_fields][:listing_format]
          process_response(client.call(:AddItem, item_params(params))).merge(id: params[:id])
        end

        # ReviseItem
        # Edit current item
        # return item_id & fees or errors
        def update_item(params)
          process_response(client.call(:ReviseItem, revise_item_params(params))).merge(id: params[:id])
        end

        # RelistItem
        # Relist item which was on ebay
        # return item_id & fees or errors
        def relist(params)
          process_response(client.call(:RelistItem, relist_item_params(params)))
        end

        def item_params(params)
          # http://developer.ebay.com/devzone/xml/docs/reference/ebay/additem.html#Request.Item.AttributeArray
          options = {
              Item: {
                  # http://developer.ebay.com/Devzone/XML/docs/Reference/ebay/extra/AddItm.Rqst.Itm.LstngTyp.html
                  ListingType: 'FixedPriceItem',
                  BestOfferDetails: {
                      BestOfferEnabled: params[:data_fields][:best_offer],
                  },
                  Currency: 'USD',
                  Country: 'US',
                  ListingDuration: params[:data_fields][:listing_duration],
                  AutoPay: true,
                  ShipToLocations: 'Worldwide',
                  Location: params[:data_fields][:ships_from], #'Philadelphia, Pennsylvania',
                  ReturnPolicy: {
                      ReturnsAcceptedOption: 'ReturnsNotAccepted'
                  },
                  # http://developer.ebay.com/DevZone/guides/ebayfeatures/Development/Desc-ItemCondition.html
                  ConditionID: params[:data_fields][:condition_id], #3000,
                  # http://developer.ebay.com/Devzone/XML/docs/Reference/ebay/types/BuyerPaymentMethodCodeType.html
                  PaymentMethods: ['PayPal'],
                  PayPalEmailAddress: 'it@coretest.com',
                  PaymentDetails: {
                      DaysToFullPayment: 7,
                  },
                  ShippingDetails: {
                      GlobalShipping: true,
                      ShippingServiceOptions: {
                          ShippingServicePriority: 1,
                          ShippingService: 'USPSMedia',
                          ShippingServiceCost: params[:data_fields][:shipping_price],
                      }
                  },
                  DispatchTimeMax: 1,
                  PrimaryCategory: {CategoryID: params[:category_id]},
                  StartPrice: params[:data_fields][:discount_price] || params[:data_fields][:price],
                  DiscountPriceInfo: {
                      OriginalRetailPrice: params[:data_fields][:price],
                      PricingTreatment: 'STP',
                  },
                  PictureDetails: {
                      GalleryType: 'Gallery',
                      PictureURL: params[:images],
                  },
                  Title: params[:data_fields][:title],
                  Description: params[:data_fields][:description], #listing description
                  Quantity: [params[:data_fields][:quantity], 1].max,
                  ItemSpecifics: params[:data_fields].select { |key, v| key.to_s.match(/^SPEC: .*/) }.map { |k, v| {NameValueList: {Name: k.gsub('SPEC: ', ''), Value: v}} }
              }
          }
          if params[:data_fields][:listing_format] == 'auction'
            options[:Item][:ListingType] = 'Chinese'
            options[:Item][:StartPrice] = params[:data_fields][:discount_price] || params[:data_fields][:price]
            options[:Item][:StartPrice] ||= 0
            options[:Item][:Currency] = 'USD'
            options[:Item][:Country] = 'US'
            options[:Item][:Quantity] = 1
          end
          options
        end

        def revise_item_params(params)
          # http://developer.ebay.com/devzone/xml/docs/reference/ebay/additem.html#Request.Item.AttributeArray
          {
              Item: {
                  # http://developer.ebay.com/Devzone/XML/docs/Reference/ebay/extra/AddItm.Rqst.Itm.LstngTyp.html
                  ItemID: params[:item_id],
                  ShipToLocations: 'Worldwide',
                  Location: params[:data_fields][:ships_from], #'Philadelphia, Pennsylvania',
                  ReturnPolicy: {
                      ReturnsAcceptedOption: 'ReturnsNotAccepted'
                  },
                  BestOfferDetails: {
                      BestOfferEnabled: params[:data_fields][:best_offer],
                  },
                  ShippingDetails: {
                      GlobalShipping: true,
                      ShippingServiceOptions: {
                          ShippingServicePriority: 1,
                          ShippingService: 'USPSMedia',
                          ShippingServiceCost: params[:data_fields][:shipping_price],
                      }
                  },
                  DispatchTimeMax: 1,
                  StartPrice: params[:data_fields][:discount_price] || params[:data_fields][:price],
                  DiscountPriceInfo: {
                      OriginalRetailPrice: params[:data_fields][:price],
                      PricingTreatment: 'STP',
                  },
                  PictureDetails: {
                      GalleryType: 'Gallery',
                      PictureURL: params[:images],
                  },
                  Title: params[:data_fields][:title],
                  Description: params[:data_fields][:description], #listing description
                  Quantity: params[:state][:listing_format] == 'auction' ? 1 : [params[:data_fields][:quantity], 1].max,
                  ItemSpecifics: params[:data_fields].select { |key, v| key.to_s.match(/^SPEC: .*/) }.map { |k, v| {NameValueList: {Name: k.gsub('SPEC: ', ''), Value: v}} }
              }
          }
        end

        def relist_item_params(params)
          {Item: {ItemID: params[:item_id]}}
        end

      end
    end
  end
end
