# frozen_string_literal: true

# :nodoc:
#
module EnumKit
  # :nodoc:
  #
  module ActiveRecordExtensions
    # :nodoc:
    #
    module SchemaDumper
      # :nodoc:
      #
      def tables(stream)
        export_enums(stream)
        super
      end

      # :nodoc:
      #
      def export_enums(stream)
        @connection.enums.each do |name, values|
          values = values.map(&:inspect).join(', ')
          stream.puts "  create_enum #{name.inspect}, [#{values}]"
        end

        stream.puts if @connection.enums.any?
      end
    end
  end
end
