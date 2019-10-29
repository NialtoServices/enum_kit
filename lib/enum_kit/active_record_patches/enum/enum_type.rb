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
      # @return [Boolean] Whether to prevent an exception from being raised when the enum is set to an invalid value.
      #
      attr_accessor :disable_exceptions

      # :nodoc:
      #
      def assert_valid_value(value)
        return value if value.blank? || mapping.key?(value) || mapping.value?(value) || disable_exceptions

        raise ArgumentError, "'#{value}' is not a valid #{name}"
      end
    end
  end
end
