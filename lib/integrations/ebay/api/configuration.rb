module Integrations
  module Ebay
    module Api
      module Configuration

        def dev_id
          'f7960b98-7552-4572-bcdc-a32471e8fb66' if Rails.env.development? || Rails.env.production? || Rails.env.staging?
        end

        def app_id
          'jamesjam-myapp-SBX-d2442a3e5-f3c4bc10' if Rails.env.development? || Rails.env.production? || Rails.env.staging?
        end

        def cert_id
          'SBX-2442a3e55857-c437-4a67-af9e-8d28' if Rails.env.development? || Rails.env.production? || Rails.env.staging?
        end

        def ru_name
          'james_james-jamesjam-myapp--zdghtmp' if Rails.env.development? || Rails.env.production? || Rails.env.staging?
        end

      end
    end
  end
end