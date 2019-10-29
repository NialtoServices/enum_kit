# frozen_string_literal: true

require 'enum_kit/constants'
require 'enum_kit/helpers'

# Used as a namespace to encapsulate the logic for the EnumKit gem.
#
module EnumKit
  # Queue loading of the patches/extensions and database type registration for when `ActiveRecord` has loaded.
  #
  def self.load!
    require 'active_record'
    require 'active_record/connection_adapters/postgresql_adapter'
    require 'active_support/lazy_load_hooks'

    ActiveSupport.on_load(:active_record) do
      EnumKit.load_patches!
      EnumKit.load_extensions!
      EnumKit.register_database_type!
    end
  end

  # Load the `ActiveRecord` monkey patches.
  #
  def self.load_patches!
    require 'enum_kit/active_record_patches/connection_adapters/postgresql/column_methods'
    require 'enum_kit/active_record_patches/connection_adapters/postgresql/oid/enum'
    require 'enum_kit/active_record_patches/connection_adapters/postgresql/oid/type_map_initializer'
    require 'enum_kit/active_record_patches/enum'
    require 'enum_kit/active_record_patches/enum/enum_type'
    require 'enum_kit/active_record_patches/validations/pg_enum_validator'
  end

  # Load the `ActiveRecord` extensions.
  #
  def self.load_extensions!
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
  end

  # Register `:enum` as a native database type.
  #
  def self.register_database_type!
    ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES[:enum] = { name: 'enum' }
  end
end

EnumKit.load!
