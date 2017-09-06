module Integrations
  def self.by_uid(service)
    case service.downcase
      when 'ebay'
        Integrations::Ebay::Instance
      when 'etsy'
        Integrations::Etsy::Instance
      when 'amazon'
        Integrations::Amazon::Instance
      when 'shopify'
        Integrations::Shopify::Instance
      else
        raise 'Invalid Service'
    end
  end
end