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

        # Record the deletion of an enum type.
        #
        def drop_enum(*args)
          record(:drop_enum, args)
        end

        # :nodoc:
        #
        def rename_enum(*args)
          record(:rename_enum, args)
        end

        # :nodoc:
        #
        def invert_create_enum(args)
          record(:drop_enum, args.first)
        end

        # :nodoc:
        #
        def invert_drop_enum(args)
          unless args.length > 1
            raise ::ActiveRecord::IrreversibleMigration, 'drop_enum is only reversible if given an Array of values.'
          end

          record(:create_enum, args)
        end

        # :nodoc:
        #
        def invert_rename_enum(args)
          record(:rename_enum, args.reverse)
        end
      end
    end
  end
end
