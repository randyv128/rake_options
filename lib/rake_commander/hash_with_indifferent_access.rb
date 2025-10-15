# frozen_string_literal: true

module RakeCommander
  class HashWithIndifferentAccess < Hash
    def initialize(hash = {})
      super()
      hash.each do |key, value|
        self[key] = value
      end
    end

    # Override [] to handle both string and symbol keys
    def [](key)
      super(convert_key(key))
    end

    # Override []= to store with string keys
    def []=(key, value)
      super(convert_key(key), value)
    end

    # Override fetch to handle both string and symbol keys
    def fetch(key, *args, &block)
      super(convert_key(key), *args, &block)
    end

    # Override key? to handle both string and symbol keys
    def key?(key)
      super(convert_key(key))
    end

    alias_method :has_key?, :key?
    alias_method :include?, :key?

    private

    # Convert key to string and normalize dashes/underscores
    def convert_key(key)
      key_str = key.to_s
      # Try exact match first
      return key_str if Hash.instance_method(:key?).bind(self).call(key_str)
      
      # Try with underscores converted to dashes
      dashed = key_str.tr("_", "-")
      return dashed if Hash.instance_method(:key?).bind(self).call(dashed)
      
      # Try with dashes converted to underscores
      underscored = key_str.tr("-", "_")
      return underscored if Hash.instance_method(:key?).bind(self).call(underscored)
      
      # Return original if no match
      key_str
    end
  end
end
