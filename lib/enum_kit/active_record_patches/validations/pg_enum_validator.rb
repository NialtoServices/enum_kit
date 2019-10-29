# frozen_string_literal: true

# :nodoc:
#
module ActiveRecord
  # :nodoc:
  #
  module Validations
    # Validates whether an enum's value is acceptable by comparing with the acceptable values defined in the PostgreSQL
    # database.
    #
    class PgEnumValidator < ActiveModel::EachValidator
      # Validate the given value is acceptable for the enum.
      #
      # @param record    [ActiveRecord::Base]  The record being validated.
      # @param attribute [Symbol]              The enum attribute being validated.
      # @param value     [String, Symbol, nil] The current value of the enum.
      #
      def validate_each(record, attribute, value)
        values = record.class.pg_enum_values(attribute)

        return if values.include?(value)

        record.errors.add(attribute, options[:message] || :invalid, **options.except(:message).merge!(
          attribute: record.class.human_attribute_name(attribute),
          values: values.join(', ')
        ))
      end
    end
  end
end
