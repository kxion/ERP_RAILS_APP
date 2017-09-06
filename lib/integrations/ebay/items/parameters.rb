# module Integrations
#   module Ebay
#     module Items
#       module Parameters
#
#         def ui_parameters
#           [
#               {
#
#                   required: true,
#                   lable: 'Listing format',
#                   key: 'listing_format',
#                   type: :select,
#                   variants: [{key: 'auction', lable: 'Auction'},
#                              {key: 'fixed_price', lable: 'Fixed price'}]
#               },
#               {
#                   required: true,
#                   lable: 'Condition',
#                   key: 'condition_id',
#                   type: :select,
#                   variants: [{key: 1000, lable: 'New'},
#                              {key: 1500, lable: 'New other'},
#                              {key: 1750, lable: 'New with defects'},
#                              {key: 2000, lable: 'Manufacturer refurbished'},
#                              {key: 2500, lable: 'Seller refurbished'},
#                              {key: 2750, lable: 'Like New'},
#                              {key: 3000, lable: 'Used'},
#                              {key: 4000, lable: 'Very Good'},
#                              {key: 5000, lable: 'Good'},
#                              {key: 6000, lable: 'Acceptable'},
#                              {key: 7000, lable: 'For parts'},]
#               },
#               {
#                   required: true,
#                   lable: 'Listing duration',
#                   key: 'listing_duration',
#                   type: :select,
#                   variants: [{key: 'Days_1', lable: '1 Day'},
#                              {key: 'Days_3', lable: '3 Days'},
#                              {key: 'Days_5', lable: '5 Days'},
#                              {key: 'Days_7', lable: '7 Days'},
#                              {key: 'Days_10', lable: '10 Days'},
#                              {key: 'Days_30', lable: '30 Days'},
#                              {key: 'GTC', name: 'Good till cancel'},]
#               },
#               {
#                   required: true,
#                   lable: 'Price',
#                   key: 'price',
#                   type: :input,
#               },
#               {
#                   required: true,
#                   lable: 'Shipping price',
#                   key: 'shipping_price',
#                   type: :input,
#               },
#               {
#                   required: true,
#                   lable: 'Enable best offer',
#                   key: 'best_offer',
#                   type: :boolean,
#               },
#               {
#                   required: true,
#                   lable: 'Title',
#                   key: 'title',
#                   type: :input,
#               },
#               {
#                   required: false,
#                   lable: 'Quantity',
#                   key: 'quantity',
#                   type: :input,
#               },
#               {
#                   required: true,
#                   lable: 'Description',
#                   key: 'description',
#                   type: :text,
#               },
#               {
#                   required: false,
#                   lable: 'Quantity',
#                   key: 'quantity',
#                   type: :input,
#               },
#               {
#                   required: false,
#                   lable: 'Discount price',
#                   key: 'discount_price',
#                   type: :input,
#               },
#               {
#                   required: true,
#                   lable: 'Item pictures',
#                   key: 'image_urls',
#                   type: :array,
#               },
#               {
#                   required: true,
#                   lable: 'Category',
#                   key: 'category_id',
#                   type: :category, # category id should be selected from category tree, data from `categories`
#               }
#           ]
#         end
#
#       end
#     end
#   end
# end