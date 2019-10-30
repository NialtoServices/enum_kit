# frozen_string_literal: true

# :nodoc:
#
module EnumKit
  # :nodoc:
  #
  module ActiveRecordExtensions
    # :nodoc:
    #
    module Migration
      # :nodoc:
      #
      module CommandRecorder
        # Record the creation of an enum type.
        #
        def create_enum(*args)
          record(:create_enum, args)
        end

        # Record the renaming of an enum type.
        #
        def rename_enum(*args)
          record(:rename_enum, args)
        end

        # Record the deletion of an enum type.
        #
        def drop_enum(*args)
          record(:drop_enum, args)
        end

        # Record the addition of a value to an enum type.
        #
        def add_enum_value(*args)
          record(:add_enum_value, args)
        end

        # Record the renaming of a value in an enum type.
        #
        def rename_enum_value(*args)
          record(:rename_enum_value, args)
        end

        # Invert the creation of an enum type by deleting it.
        #
        def invert_create_enum(args)
          record(:drop_enum, args.first)
        end

        # Invert the renaming of an enum by renaming it back to the previous name.
        #
        def invert_rename_enum(args)
          record(:rename_enum, args.reverse)
        end

        # Invert the deletion of an enum type by creating it.
        #
        # Note that `drop_enum` can only be reversed if given a collection of values to call `create_enum` with as the
        # previously deleted enum values cannot be automatically determined.
        #
        def invert_drop_enum(args)
          unless args.length > 1
            raise ActiveRecord::IrreversibleMigration, 'drop_enum is only reversible if given an Array of values.'
          end

          record(:create_enum, args)
        end

        # Invert the addition of a value to an enum type by removing the value.
        #
        def invert_add_enum_value(_args)
          raise ActiveRecord::IrreversibleMigration, 'add_enum_value is not reversible.'
        end

        # Invert the renaming of an enum's value by renaming it back to the previous value.
        #
        def invert_rename_enum_value(args)
          record(:rename_enum_value, args[0], args[2], args[1])
        end
      end
    end
  end
end
