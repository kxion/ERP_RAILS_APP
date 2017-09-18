module Integrations
  module Ebay
    module CustomActions
      module Auth

        def auth_connect
          session_id = Integrations::Ebay::Api::Base.call(:GetSessionID, { RuName: 'james_james-jamesjam-myapp--zdghtmp' }).session_id
          puts session_id.inspect
          session[:integration_session] = (session[:integration_session] || {}).merge(session_id: session_id)
          redirect_to = Integrations::Ebay::Api::Base.authorization_uri(session_id).to_s
          p redirect_to
          render status: 200, json: { url: redirect_to}
        end

        def auth_success_callback
          session_id = session[:integration_session]['session_id']
          token = Integrations::Ebay::Api::Base.call(:FetchToken, { SessionID: session_id }).ebay_auth_token
          @state[:auth_token] = token
          Integrations::Ebay::Api::Base.auth_token = token
          flash[:notice] = "eBay account connected successfully"
          account = Account.find(session[:integration_session][:id])
          account.is_connected = true
          account.save()
          flash[:notice] = 'Shopify account connected successfully'
          # redirect_to "http://localhost:8080/#/order-management/connected-accounts"
          redirect_to "https://erb-angular-app.herokuapp.com/#/order-management/connected-accounts"
        rescue
          flash[:alert] = "There was an error connecting your eBay account"
          redirect_to redirect_url_on_failure
        end

        def auth_fail_callback
          flash[:alert] = "It seems you rejected the authentication request. Account not connected"
          redirect_to redirect_url_on_failure
        end

      end
    end
  end
end