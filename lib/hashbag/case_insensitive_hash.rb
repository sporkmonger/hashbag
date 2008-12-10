# ++
# HashBag, Copyright (c) 2008 Bob Aman
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# --

module HashBag
  ##
  # This Hash subclass stores keys in a case-insensitive manner.
  class CaseInsensitiveHash < Hash
    def self.[](*params)
      if params.size % 2 != 0
        raise ArgumentError,
          "Odd number of arguments for CaseInsensitiveHash."
      end
      hash = self.new
      loop do
        key = params.shift
        value = params.shift
        hash[key] = value
        break if params.empty?
      end
      return hash
    end

    ##
    # @see Hash#[]
    def [](key)
      if self.has_key?(key)
        key = @lookup[key.to_str.downcase]
        return super(key)
      else
        return self.default(key)
      end
    end

    ##
    # @see Hash#[]=
    def []=(key, value)
      if !key.kind_of?(String) && !key.respond_to?(:to_str)
        raise TypeError, "Can't convert #{key.class} into String"
      end
      self.delete(key)
      @lookup[key.to_str.downcase] = key
      return super(key, value)
    end

    ##
    # @see Hash#store
    alias_method :store, :[]=

    ##
    # @see Hash#==
    def ==(hash)
      self_hash = self.to_hash.inject({}) do |accu, (key, value)|
        accu[key.to_str.downcase] = value
        accu
      end
      other_hash = hash.to_hash.inject({}) do |accu, (key, value)|
        if key.respond_to?(:to_str)
          accu[key.to_str.downcase] = value
        else
          return false
        end
        accu
      end
      return self_hash == other_hash
    end

    ##
    # @see Hash#has_key?
    def has_key?(key)
      if !key.kind_of?(String) && !key.respond_to?(:to_str)
        return false
      end
      @lookup ||= {}
      return @lookup.has_key?(key.to_str.downcase)
    end

    ##
    # @see Hash#include?
    alias_method :include?, :has_key?

    ##
    # @see Hash#member?
    alias_method :member?, :has_key?

    ##
    # @see Hash#key?
    alias_method :key?, :has_key?

    ##
    # @see Hash#key
    def key(value)
      index = self.values.index(value)
      if index
        return self.keys[index]
      else
        return nil
      end
    end

    ##
    # @see Hash#delete
    def delete(key)
      if self.has_key?(key)
        key = @lookup[key.to_str.downcase]
        @lookup.delete(key.downcase)
        return super(key)
      elsif block_given?
        return yield(key)
      else
        return self.default(key)
      end
    end

    ##
    # @see Hash#values_at
    def values_at(*keys)
      return keys.map { |key| self[key] }
    end

    # Conditionally override indexes method.
    if {}.respond_to?(:indexes)
      ##
      # @see Hash#indices
      def indexes(*values) # :nodoc:
        raise NotImplementedError, "Use CaseInsensitiveHash#select instead."
      end

      ##
      # @see Hash#indices
      alias_method :indices, :indexes # :nodoc:
    end

    ##
    # @see Hash#fetch
    def fetch(*params)
      if params.size > 2
        raise ArgumentError,
          "wrong number of arguments (#{params.size} for 2)"
      end
      key, default = params
      if self.has_key?(key)
        return self[key]
      elsif block_given?
        warn("Block supersedes default value argument.") if params.size == 2
        return yield(key)
      elsif params.size == 2
        return default
      else
        raise IndexError, "Key not found."
      end
    end

    ##
    # @see Hash#merge
    def merge(hash)
      merged_hash = self.dup
      hash.each do |key, value|
        if block_given? && merged_hash.include?(key)
          merged_hash[key] = yield(key, self[key], value)
        else
          merged_hash[key] = value
        end
      end
      return merged_hash
    end

    ##
    # @see Hash#update
    def update(hash, &block)
      return self.replace(self.merge(hash, &block))
    end

    ##
    # @see Hash#dup
    def dup
      hash = super
      hash.instance_variable_set("@lookup", (@lookup || {}).dup)
      return hash
    end

    ##
    # @see Hash#replace
    def replace(hash)
      self.clear
      hash.each do |key, value|
        self[key] = value
      end
      return self
    end

    ##
    # @see Hash#clear
    def clear
      @lookup = {}
      return super
    end

    ##
    # Converts to a normal Hash object.  The key labels are used as the
    # Hash keys.
    #
    # @return [Hash] The converted Hash.
    def to_hash
      self.inject({}) do |accu, (key, value)|
        accu[key] = value
        accu
      end
    end
  end
end
