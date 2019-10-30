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
        enums(stream)
        super
      end

      # Write `create_enum` statements for each of the enum types created in the database to the specified stream.
      #
      # @param stream [IO] The stream to write the statements into.
      #
      def enums(stream)
        return unless @connection.respond_to?(:enums)

        statements = @connection.enums.map do |name, values|
          "  create_enum #{name.inspect}, #{values.inspect}"
        end

        return if statements.empty?

        stream.puts statements.join("\n")
        stream.puts
      end
    end
  end
end
