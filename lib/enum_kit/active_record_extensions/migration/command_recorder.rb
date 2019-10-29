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
        # :nodoc:
        #
        def create_enum(*args)
          record(:create_enum, args)
        end

        # :nodoc:
        #
        def drop_enum(*args)
          record(:drop_enum, args)
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
      end
    end
  end
end
