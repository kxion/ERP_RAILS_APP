module Mixin
  module ClassKey
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    def key
      self.class.key
    end

    module ClassMethods
      def key
        @key ||= self.name.demodulize.underscore
      end
    end
  end
end