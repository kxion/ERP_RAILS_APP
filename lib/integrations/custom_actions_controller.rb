module Integrations
  class CustomActionsController
    include Rails.application.routes.url_helpers

    VIEWS_PATH = ""

    def initialize(controller, state = {})
      @controller = controller
      @state = state
    end

    def filter(&block)
      if has_custom_behaviour?
        execute_action(&block)
      elsif block
        yield
      else
        flash[:alert] = 'Action not supported'
        redirect_to root_path
      end
    end

    def auth_connect
      raise 'Must be implemented by descendants'
    end

    def redirect_url_on_success
      :connected_accounts
    end

    def redirect_url_on_failure
      :connected_accounts
    end

    protected

    delegate :request, :params, :session, :response, :redirect_to, :render, :flash, :append_view_path, to: :@controller

    private

    def has_custom_behaviour?
      respond_to?(current_action_method)
    end

    def current_action_method
      "#{@controller.action_name}".to_sym
    end

    def execute_action(&block)
      append_view_path "#{File.dirname(__FILE__)}/#{self.class::VIEWS_PATH}"
      self.send(current_action_method, &block)
    end

  end
end