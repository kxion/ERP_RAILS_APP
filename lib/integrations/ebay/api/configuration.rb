module Integrations
  module Ebay
    module Api
      module Configuration

        def dev_id
          '6876a00f-97d4-4dc9-b2db-da216f2b84f4' if Rails.env.development? || Rails.env.staging?
        end

        def app_id
          'CoreAuto-df73-4a63-a2fa-4ee210c6cbb6' if Rails.env.development? || Rails.env.staging?
        end

        def cert_id
          '2fa035b8-8fa4-4e1a-996f-7aca47187407' if Rails.env.development? || Rails.env.staging?
        end

        def ru_name
          'Core_Automotive-CoreAuto-df73-4-huchtfv' if Rails.env.development? || Rails.env.staging?
        end

      end
    end
  end
end