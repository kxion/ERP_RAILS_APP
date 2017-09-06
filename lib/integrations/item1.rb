module Integrations
  class Item1

    ATTRIBUTES = %w(local_id integration_id price image_urls title description)
    attr_accessor *ATTRIBUTES

    def initialize(opt = {})
      options = ActiveSupport::HashWithIndifferentAccess.new(opt)
      ATTRIBUTES.each do |attr|
        instance_variable_set("@#{attr}", options[attr])
      end
    end

    def to_hash
      h = ActiveSupport::HashWithIndifferentAccess.new
      ATTRIBUTES.each do |attr|
        h[attr] = self.send(attr)
      end
      h
    end

  end
end