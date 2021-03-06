# frozen_string_literal: true

module EnumKit
  # ...
  #
  class Railtie < Rails::Railtie
    initializer 'enum_kit.set_configs' do |app|
      app.configure do
        config.enum_kit = ActiveSupport::OrderedOptions.new
        config.enum_kit.disable_exceptions = false
      end
    end

    initializer 'enum_kit.active_support.register_active_record_handler', after: 'active_support.set_configs' do
      ActiveSupport.on_load(:active_record) do
        # Require the ActiveRecord patches.
        require 'enum_kit/active_record_patches/connection_adapters/postgresql/column_methods'
        require 'enum_kit/active_record_patches/connection_adapters/postgresql/oid/enum'
        require 'enum_kit/active_record_patches/connection_adapters/postgresql/oid/type_map_initializer'
        require 'enum_kit/active_record_patches/enum'
        require 'enum_kit/active_record_patches/enum/enum_type'
        require 'enum_kit/active_record_patches/validations/pg_enum_validator'

        # Require the ActiveRecord extensions.
        %w[
          ConnectionAdapters::PostgreSQL::ColumnDumper
          ConnectionAdapters::PostgreSQL::SchemaDumper
          ConnectionAdapters::PostgreSQLAdapter
          Migration::CommandRecorder
          SchemaDumper
        ].each do |extension|
          next unless Object.const_defined?("ActiveRecord::#{extension}")

          require File.join('enum_kit', 'active_record_extensions', EnumKit.underscore(extension))

          target_constant    = Object.const_get("ActiveRecord::#{extension}")
          extension_constant = Object.const_get("EnumKit::ActiveRecordExtensions::#{extension}")

          target_constant.prepend(extension_constant)
        end

        # Register `:enum` as a native database type.
        ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES[:enum] = { name: 'enum' }
      end
    end
  end
end
