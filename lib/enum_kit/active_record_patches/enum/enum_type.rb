# frozen_string_literal: true

# :nodoc:
#
module ActiveRecord
  # :nodoc:
  #
  module Enum
    # :nodoc:
    #
    class EnumType < Type::Value
      # :nodoc:
      #
      def assert_valid_value(value)
        return value if value.blank? || mapping.key?(value) || mapping.value?(value)
        return value if Rails.application.config.enum_kit.disable_exceptions

        raise ArgumentError, "'#{value}' is not a valid #{name}"
      end
    end
  end
end
