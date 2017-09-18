module Integrations::Shopify::CustomActions
  module Auth

    def auth_connect
      if params[:shop_name].blank?
        render :template => "auth"
      else
        @state[:shop] = "#{params[:shop_name]}.myshopify.com"
        p account = Account.find(session[:integration_session][:id])
        account.is_connected = true
        account.save()
        p redirect_url = integration_custom_action_url('auth_success_callback')
        render status: 200, json: { url: redirect_url}
      end
    end

    def auth_success_callback
      p params[:shop] = @state[:shop]
      shopify_session = ShopifyAPI::Session.new(@state[:shop])
      scope = %w(write_products write_orders)
      p permission_url = shopify_session.create_permission_url(scope)
      # p @state[:access_token] = shopify_session.request_token(params)
      flash[:notice] = 'Shopify account connected successfully'
      # redirect_to "http://localhost:8080/#/order-management/connected-accounts"
      redirect_to "https://erb-angular-app.herokuapp.com/#/order-management/connected-accounts"
    rescue
      flash[:alert] = 'There was an error connecting your Shopify account'
      # redirect_to "http://localhost:8080/#/order-management/connected-accounts"
      redirect_to "https://erb-angular-app.herokuapp.com/#/order-management/connected-accounts"
    end
  end
end