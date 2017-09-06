module Etsy
  class Image
    def self.create(listing, image_path, options = {})
      options.merge!(:require_secure => true)
      options[:image] = File.new(image_path) if image_path
      options[:multipart] = true
      post("/listings/#{listing.id}/images", options)
    end

    def id
      @result['listing_image_id']
    end
  end
end