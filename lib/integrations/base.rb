module Integrations
  class Base
    include Mixin::ClassKey
    include Mixin::ModuleKey

    attr_reader :state

    # integration class instance initializer.
    # - state - Hash - represents persistent state hash. Anything written to 'state' will be persisted
    def initialize(state)
      @state = state
    end

    # initializes custom actions controller for an integration
    # - base_controller - ActionController::Base - origin controller
    # Returns:
    # - Integrations::CustomActionsController instance
    def custom_actions_controller(base_controller)
      custom_actions_controller_class.new(base_controller, @state)
    end

    # returns whether the current integration is logged in
    def logged_in?
      raise 'To be implemented by descendants'
    end

    # - items - list of items (array of Hash)
    # Returns:
    # - array of Hash - operation status for each item
    def add_items(items)
      raise 'To be implemented by descendants' unless respond_to? :add_item

      items.map { |item| add_item(item) }
    end

    # adds items to the marketplace
    # - items - list of items (array of Hash)
    # Returns:
    # - array of Hash - operation status for each item
    def update_items(items)
      raise 'To be implemented by descendants' unless respond_to? :update_item

      items.map { |item| update_item(item) }
    end

    # removes items from the marketplace
    # - items - list of items (array of Hash)
    # Returns:
    # - array of Hash - operation status for each item
    def delete_items(items)
      raise 'To be implemented by descendants' unless respond_to? :delete_item

      items.map { |item| delete_item(item) }
    end

    # searches marketplace for items by search keywords
    # - keywords - Array or string - array of keywords to search items
    # - count - Integer - number of items to return
    # Returns:
    # - array of Hash - items list
    def search_items(keywords, count)
      raise 'To be implemented by descendants'
    end

    # retrieves items list by marketplace UIDs
    # - uids - Array or string - array of target items marketplace UIDs
    # - format - Symbol - number of items to return
    # Returns:
    # - array of Hash - items list
    def get_items(uids, format = :short)
      raise 'To be implemented by descendants'
    end

    # returns child category list
    # - parent_category_id - string - optional, returns top-level categories when nil
    # Returns:
    # - array of Hash - child categories
    #     {
    #       id: string,
    #       parent_id: string,
    #       name: string,
    #       has_children: bool
    #     }
    def categories(parent_category_id = nil)
      raise 'To be implemented by descendants'
    end

    # returns category field list for the category
    # - category_id - string
    # Returns:
    # - array of Hash - category fields details
    def category_fields(category_id)
      raise 'To be implemented by descendants'
    end

    # retrieves orders list for the specified date range
    # - date_from - Date
    # - date_to - Date
    # Returns:
    # - array of Hash - orders list
    def get_orders(date_from, date_to)
      raise 'To be implemented by descendants'
    end

    # updates specified orders
    # - orders - array of Hash - orders list with properties to be updated
    # Returns:
    # - array of Hash - operation status for each order
    def update_orders(orders)
      raise 'To be implemented by descendants' unless respond_to? :update_order

      orders.map { |order| update_order(order) }
    end

    protected

    # defines custom actions controller class name for an integration
    # Returns:
    # - Integrations::CustomActionsController class
    def custom_actions_controller_class
      Integrations::CustomActionsController
    end
  end
end