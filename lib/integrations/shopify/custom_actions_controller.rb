module Integrations::Shopify
  class CustomActionsController < Integrations::CustomActionsController
    include Integrations::Shopify::CustomActions::Auth

    VIEWS_PATH = 'shopify/custom_views'

  end
end