module Mixin
  module ModuleKey
    def self.included(klass)
      klass.extend(ClassMethods)
    end

    def mkey
      self.class.key
    end

    module ClassMethods
      def mkey
        @key ||= self.name.deconstantize.demodulize.underscore
      end
    end
  end
end