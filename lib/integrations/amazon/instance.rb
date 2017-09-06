# https://sellercentral.amazon.com/gp/mws/registration/register-summary.html
# Seller account identifiers for JamesDeighan
# Seller ID:	A11HLS295W80IP
# Marketplace ID:	A3BXB0YN3XH17H (Amazon Payments Advanced US Sandbox)
#                 AGWSWK15IEJJ7 (Amazon Payments Advanced US Live)
#                 A6W85IYQ5WB1C (IBA)
#                 A2EUQ1WTGCTBG2 (Amazon.ca)
#                 ATVPDKIKX0DER (Amazon.com)
# Developer account identifier and credentials
# Developer Account Number:	2350-0906-1488
# AWS Access Key ID:	AKIAJQ7UNORQIKAVL76A
# Secret Key:	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




# new_clarabyte
# 9681-8867-7426

# Seller account identifiers for Urban Geek
# Seller ID:  A2TV91R20V27O2
# Marketplace ID: A2EUQ1WTGCTBG2 (Amazon.ca)
# ATVPDKIKX0DER (Amazon.com)
# A1AM78C64UM0Y8 (Amazon.com.mx)
# Seller-Developer Authorization
# MWS Auth Token: amzn.mws.a4ad0572-4ebd-0a59-adfc-da3da2b8decc
#---\n:merchant_id: A2TV91R20V27O2\n:auth_token: amzn.mws.a4ad0572-4ebd-0a59-adfc-da3da2b8decc\n"


module Integrations::Amazon
  class Instance < Integrations::Base
    include Integrations::Amazon::Items
    include Integrations::Amazon::Orders
    include Integrations::Amazon::Categories

    PRIMARY_MARKETPLACE_ID = 'ATVPDKIKX0DER'
    MERCHANT_ID = 'A11HLS295W80IP'
    AWS_ACCESS_KEY_ID = 'AKIAIUSUX6KHGOEYTRXQ'
    AWS_SECRET_ACCESS_KEY = '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'

    attr_accessor :client, :client_feeds, :client_products, :client_orders, :client_recommendations

    def initialize(state)
      super
      options = {
          primary_marketplace_id: PRIMARY_MARKETPLACE_ID,
          aws_access_key_id: AWS_ACCESS_KEY_ID,
          aws_secret_access_key: AWS_SECRET_ACCESS_KEY,
      }
      options[:auth_token] = @state[:auth_token] unless @state[:auth_token].blank?
      options[:merchant_id] = @state[:merchant_id] || MERCHANT_ID
      @client_orders = MWS.orders(options)
      @client_products = MWS.products(options)
      @client_feeds = MWS.feeds(options)
      @client_recommendations = MWS.recommendations(options)
    end

    def custom_actions_controller_class
      Integrations::Amazon::CustomActionsController
    end

    def logged_in?
      @state[:auth_token] && @state[:merchant_id]
    rescue
      false
    end

    # http://docs.developer.amazonservices.com/en_US/products/Products_ListMatchingProducts.html
    def search_items(query)
      @client_products.list_matching_products(query).parse['Products']['Product']
    end

  end
end