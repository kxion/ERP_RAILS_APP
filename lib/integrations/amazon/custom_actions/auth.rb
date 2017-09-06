module Integrations
  module Amazon
    module CustomActions
      module Auth

        def auth_connect
          if params[:merchant_id].blank? && params[:auth_token].blank?
            render template: :auth
          else
            @state[:merchant_id]  = params[:merchant_id]
            @state[:auth_token]  = params[:auth_token]
            account = Account.find(params[:id])
            account.is_connected = true
            account.save()
            redirect_url = integration_custom_action_url('auth_success_callback')
            # redirect_to redirect_url
            render status: 200, json: { url: redirect_url}
          end
        end

        def auth_success_callback
          redirect_to "https://erp-clarabyte.herokuapp.com/order-management/connected-accounts"
          # redirect_to "http://localhost:3000/order-management/connected-accounts"
        end

      end
    end
  end
end