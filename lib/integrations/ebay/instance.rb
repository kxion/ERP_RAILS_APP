module Integrations::Ebay
  class Instance < Integrations::Base
    include Integrations::Ebay::Categories
    include Integrations::Ebay::Orders
    include Integrations::Ebay::Items::Request
    include Integrations::Ebay::Items::Response

    attr_accessor :client

    def initialize(state)
      super
      @client = Integrations::Ebay::Api::Base
      @client.auth_token = @state[:auth_token]
      @client.site_id = 0 # eBay US
      # @client.debug = true
    end

    def custom_actions_controller_class
      Integrations::Ebay::CustomActionsController
    end

    def logged_in?
      client.auth_token && client.call(:GeteBayOfficialTime).ack != 'Failure'
    rescue
      false
    end

  end
end