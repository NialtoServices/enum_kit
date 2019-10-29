# frozen_string_literal: true

# :nodoc:
#
module ActiveRecord
  # :nodoc:
  #
  module ConnectionAdapters
    # :nodoc:
    #
    module PostgreSQL
      # :nodoc:
      #
      module OID
        # :nodoc:
        #
        class Enum < Type::Value
          # @return [String] The PostgreSQL type for the enum.
          #
          attr_reader :name

          # :nodoc:
          #
          def initialize(options = {})
            @name = options.delete(:name).to_sym
            super
          end
        end
      end
    end
  end
end
