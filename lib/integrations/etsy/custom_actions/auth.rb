module Integrations::Etsy::CustomActions
  module Auth

    def auth_connect
      account = Account.find(params[:id])
      account.is_connected = true
      account.save if params[:id].present?
      Etsy.callback_url = integration_custom_action_url('auth_success_callback')
      Etsy.permission_scopes = %w{listings_r listings_w listings_d transactions_r transactions_w profile_r address_r shops_rw }
      request = Etsy.request_token
      session[:integration_session] = (session[:integration_session] || {}).merge({:request_token => { "token"=> request.token , "secret"=> request.secret } })
      redirect_to = Etsy.verification_url
      render status: 200, json: { url: redirect_to}
    end

    def auth_success_callback
      access = Etsy.access_token(session[:integration_session]['request_token']['token'], session[:integration_session]['request_token']['secret'], params[:oauth_verifier])
      @state[:credentials] = {
        :access_token => access.token,
        :access_secret => access.secret
      }
      flash[:notice] = "Etsy account connected successfully"
      # redirect_to "http://localhost:8080/#/order-management/connected-accounts?success"
      redirect_to "https://erb-angular-app.herokuapp.com/#/order-management/connected-accounts?success"
    rescue
      flash[:alert] = "There was an error connecting your Etsy account"
      # redirect_to "http://localhost:8080/#/order-management/connected-accounts?error"
      redirect_to "https://erb-angular-app.herokuapp.com/#/order-management/connected-accounts?error"
    end

    def auth_fail_callback
      flash[:alert] = "It seems you rejected the authentication request. Account not connected"
      # redirect_to "http://localhost:8080/#/order-management/connected-accounts?reject"
      redirect_to "https://erb-angular-app.herokuapp.com/#/order-management/connected-accounts?reject"
    end

  end
end