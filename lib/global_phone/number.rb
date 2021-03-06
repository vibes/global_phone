require 'forwardable'

module GlobalPhone
  class Number
    extend Forwardable

    E161_MAPPING       = Hash[*"a2b2c2d3e3f3g4h4i4j5k5l5m6n6o6p7q7r7s7t8u8v8w9x9y9z9".split("")]
    VALID_E161_CHARS  = /[a-zA-Z]/
    LEADING_PLUS_CHARS = /^\++/
    NON_DIALABLE_CHARS = /[^,#+\*\d]/
    SPLIT_FIRST_GROUP  = /^(\d+)(.*)$/

    def self.normalize(string, configurations = {})
      enable_e161 = configurations[:enable_e161]
      normalized = string.to_s
      if enable_e161
        normalized = normalized.gsub(VALID_E161_CHARS) { |c| E161_MAPPING[c.downcase] }
      elsif VALID_E161_CHARS.match(normalized)
        # found e161 chars. did not expect them.
        return ""
      end
      normalized.gsub(LEADING_PLUS_CHARS, "+").
        gsub(NON_DIALABLE_CHARS, "")
    end

    attr_reader :territory, :national_string

    def_delegator :territory, :region
    def_delegator :territory, :country_code
    def_delegator :territory, :national_prefix
    def_delegator :territory, :national_pattern

    def initialize(territory, national_string)
      @territory = territory
      @national_string = national_string
    end

    def national_format
      @national_format ||= begin
        if format && result = format.apply(national_string, :national)
          apply_national_prefix_format(result)
        else
          national_string
        end
      end
    end

    def international_string
      @international_string ||= international_format.gsub(NON_DIALABLE_CHARS, "")
    end

    def international_format
      @international_format ||= begin
        if format && formatted_number = format.apply(national_string, :international)
          "+#{country_code} #{formatted_number}"
        else
          "+#{country_code} #{national_string}"
        end
      end
    end

    def valid?
      !!(format && national_string =~ national_pattern)
    end

    def inspect
      "#<#{self.class.name} territory=#{territory.inspect} national_string=#{national_string.inspect}>"
    end

    def to_s
      international_string
    end

    protected
      def format
        @format ||= find_format_for(national_string)
      end

      def find_format_for(string)
        region.formats.detect { |format| format.match(string) } ||
        region.formats.detect { |format| format.match(string, false) }
      end

      def apply_national_prefix_format(result)
        prefix = national_prefix_formatting_rule
        return result unless prefix && match = result.match(SPLIT_FIRST_GROUP)

        prefix = prefix.gsub("$NP", national_prefix)
        prefix = prefix.gsub("$FG", match[1])
        result = "#{prefix} #{match[2]}"
      end

      def national_prefix_formatting_rule
        format.national_prefix_formatting_rule || territory.national_prefix_formatting_rule
      end
  end
end
