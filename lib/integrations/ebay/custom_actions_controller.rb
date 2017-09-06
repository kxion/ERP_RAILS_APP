module Integrations
  module Ebay
    class CustomActionsController < Integrations::CustomActionsController
      include Integrations::Ebay::CustomActions::Auth
    end
  end
end