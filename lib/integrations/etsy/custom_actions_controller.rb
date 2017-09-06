module Integrations::Etsy
  class CustomActionsController < Integrations::CustomActionsController
    include Integrations::Etsy::CustomActions::Auth
  end
end