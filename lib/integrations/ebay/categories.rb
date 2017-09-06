module Integrations
  module Ebay
    module Categories

      # Features
      def category_features(category_id)
        client.call(:GetCategoryFeatures, CategoryID: category_id, DetailLevel: 'ReturnAll')
      end

      def category_fields(category_id)
        generic_fields = [
            {
                name: 'listing_format',
                required: true,
                data_type: :enum,
                data_options: %w{auction fixed_price},
                for: [:create]
            },
            {
                name: 'condition_id',
                required: true,
                data_type: :enum,
                data_options: [{key: 1000, title: 'New'},
                               {key: 1500, title: 'New other'},
                               {key: 1750, title: 'New with defects'},
                               {key: 2000, title: 'Manufacturer refurbished'},
                               {key: 2500, title: 'Seller refurbished'},
                               {key: 2750, title: 'Like New'},
                               {key: 3000, title: 'Used'},
                               {key: 4000, title: 'Very Good'},
                               {key: 5000, title: 'Good'},
                               {key: 6000, title: 'Acceptable'},
                               {key: 7000, title: 'For parts'}]
            },
            {
                name: 'listing_duration',
                required: true,
                data_type: :enum,
                data_options: %w{Days_1 Days_3 Days_5 Days_7 Days_10 Days_14 Days_21 Days_30 Days_60 Days_90 Days_120}+ [key: 'GTC', title: 'Good till cancel'],
            },
            {
                name: 'price',
                required: true,
                data_type: :float
            },
            {
                name: 'shipping_price',
                required: true,
                data_type: :float
            },
            {
                name: 'best_offer',
                required: true,
                data_type: :bool
            },
            {
                name: 'title',
                required: true,
                data_type: :string
            },
            {
                name: 'quantity',
                required: false,
                data_type: :int
            },
            {
                name: 'description',
                required: true,
                data_type: :text
            },
            {
                name: 'discount_price',
                required: false,
                data_type: :float
            },
            {
                name: 'ships_from',
                required: true,
                data_type: :string
            }
        ]
        specifics = Rails.cache.fetch("ebay_category_specifics_for_#{category_id}", expires_in: 10.minutes) do
          cat_spec = client.call(:GetCategorySpecifics, CategoryID: category_id, MaxNames: 100, MaxValuesPerName: 100)
          if cat_spec.recommendations.name_recommendation && cat_spec.recommendations.name_recommendation.is_a?(Array)
            cat_spec.recommendations.name_recommendation.map do |c|
              recommendations = if !c[:value_recommendation]
                                  []
                                elsif c[:value_recommendation].is_a?(Array)
                                  c[:value_recommendation].map { |vr| vr.to_h }
                                elsif c[:value_recommendation].is_a?(Hash)
                                  [c[:value_recommendation].to_h]
                                end

              if c.validation_rules.selection_mode == 'SelectionOnly'
                data_type = :enum
              elsif c.validation_rules.max_values.try(:to_i) || 1 > 1
                data_type = :array
                data_subtype = :string
              else
                data_type = :string
              end

              {
                  name: 'SPEC: ' + c.name,
                  label: c.name,
                  required: false, # there are no option to check that
                  data_type: data_type,
                  data_subtype: data_subtype,
                  data_options: recommendations.map { |r| r[:value] },
              }
            end
          else
            []
          end
        end
        generic_fields + specifics
      end

      # Categories
      # Array of hashes
      # Hash keys name, id, parent_id, has_children
      def categories(parent_id = nil)
        categories_data = Rails.cache.fetch('ebay_categories', expires_in: 10.day) do
          categories = client.call(:GetCategories, CategorySiteID: 0, ViewAllNodes: true, DetailLevel: 'ReturnAll')
          categories = categories.category_array.category.map do |c|
            {
                name: c[:category_name],
                id: c[:category_id].to_s,
                parent_id: c[:category_parent_id].to_s,
                level: c[:category_level],
            }
          end
          {
              by_parent_id: categories.group_by { |r| r[:parent_id] },
              by_level: categories.group_by { |r| r[:level] }
          }
        end
        categories_formatter(categories_data, parent_id)
      rescue
        []
      end

      private
      def categories_formatter(categories_data, parent_id)
        if parent_id
          categories_data[:by_parent_id][parent_id.try(:to_s)].map { |e| e.delete(:level); e[:has_children] = categories_data[:by_parent_id][e[:id]].present?; e }.select { |e| e[:parent_id] != e[:id] }
        else
          categories_data[:by_level]['1'].map { |e| e.delete(:level); e[:has_children] = categories_data[:by_parent_id][e[:id]].present?; e }
        end
      end
    end
  end
end