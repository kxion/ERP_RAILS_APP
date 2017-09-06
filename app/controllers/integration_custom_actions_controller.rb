class IntegrationCustomActionsController < ApplicationController
  before_filter :set_account_id
  before_filter :set_current_integration

  def action_missing(action)
  end

  private
    def self.add_integration_filter
      around_filter do |controller, &block|
        custom_actions_controller.filter(&block)
      end
    end

    add_integration_filter

    def custom_actions_controller
      if @current_integration
        @custom_actions_controller ||= @current_integration.custom_actions_controller(self)
      else
        Integrations::CustomActionsController.new(self)
      end
    end

    def set_account_id
      session[:integration_session] ||= {}
      @account_id = params[:id] || session[:integration_session][:id] || session[:integration_session]['id']
      session[:integration_session] = session[:integration_session].merge(:id => @account_id)
    end

    def set_current_integration
      @current_integration ||= current_user.accounts.where(id: @account_id).first.try(:integration)
    end
end