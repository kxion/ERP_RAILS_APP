module Integrations::Shopify::CustomActions
  module Auth

    def auth_connect
      if params[:shop_name].blank?
        render :template => "auth"
      else
        @state[:shop] = "#{params[:shop_name]}.myshopify.com"
        shopify_session = ShopifyAPI::Session.new(@state[:shop])
        scope = %w(write_products write_orders)
        redirect_url = integration_custom_action_url('auth_success_callback')
        permission_url = shopify_session.create_permission_url(scope, redirect_url)
        render status: 200, json: { url: permission_url}
      end
    end

    def auth_success_callback
      raise '' unless params[:shop] = @state[:shop]
      shopify_session = ShopifyAPI::Session.new(@state[:shop])
      @state[:access_token] = shopify_session.request_token(params)
      account = Account.find(session[:integration_session][:id])
      account.is_connected = true
      account.save()
      flash[:notice] = 'Shopify account connected successfully'
      redirect_to "https://erp-clarabyte.herokuapp.com/order-management/connected-accounts"
    rescue
      flash[:alert] = 'There was an error connecting your Shopify account'
      redirect_to "https://erp-clarabyte.herokuapp.com/order-management/connected-accounts"
    end
  end
end