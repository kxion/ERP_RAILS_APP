module Integrations
  module Amazon
    class CustomActionsController < Integrations::CustomActionsController
      include Integrations::Amazon::CustomActions::Auth

      VIEWS_PATH = 'amazon/custom_views'
    end
  end
end