# frozen_string_literal: true

RSpec.describe ActiveRecord::ConnectionAdapters::PostgreSQLAdapter, :unit do
  subject(:connection) { ActiveRecord::Base.connection }

  before do
    # Sanity check to ensure ActiveRecord is configured to use a PostgreSQL database.
    expect(connection).to be_a(described_class)

    # Clear the cached enums before each test to ensure clean tests.
    connection.clear_enum_cache!
  end

  %i[create_enum rename_enum drop_enum add_enum_value rename_enum_value].each do |method|
    define_method(method) do |*args, &block|
      connection.send(method, *args, &block).result_status
    end
  end

  # TODO: Investigate possible alternatives as this test is a bit odd.
  describe '#clear_enum_cache!' do
    it 'sets @enums to nil' do
      connection.instance_eval do
        @enums = { sizes: ['small', 'medium', 'large', 'extra large'] }
      end

      connection.clear_enum_cache!

      expect(connection.instance_eval { @enums }).to be nil
    end
  end

  describe '#create_enum' do
    after { connection.execute 'DROP TYPE IF EXISTS sizes' }

    context 'when called with valid arguments' do
      subject { create_enum(:sizes, [:small, :medium, :large, 'extra large']) }

      it 'creates an enum' do
        expect(subject).to eq(PG::PGRES_COMMAND_OK)
        expect(connection.enums[:sizes]).to eq(['small', 'medium', 'large', 'extra large'])
      end
    end

    context 'when called with a malformed name' do
      subject { create_enum('bad enum name', [:small, :medium, :large, 'extra large']) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end

    context 'when called with malformed values' do
      subject { create_enum(:sizes, [:small, :medium, :large, 'extra large', 'extra+extra+large']) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '#rename_enum' do
    before do
      connection.execute "CREATE TYPE sizes AS ENUM ('small', 'medium', 'large', 'extra large')"
    end

    after do
      connection.execute 'DROP TYPE IF EXISTS lengths'
      connection.execute 'DROP TYPE IF EXISTS sizes'
    end

    context 'when called with valid arguments' do
      subject { rename_enum(:sizes, :lengths) }

      it 'renames the enum' do
        expect(subject).to eq(PG::PGRES_COMMAND_OK)
        expect(connection.enums).to have_key(:lengths)
        expect(connection.enums).not_to have_key(:sizes)
      end
    end

    context 'when called with a non-existent enum name' do
      subject { rename_enum(:non_existent_enum, :lengths) }

      it 'raises ActiveRecord::StatementInvalid' do
        expect { subject }.to raise_exception(ActiveRecord::StatementInvalid)
      end
    end

    context 'when called with a malformed current name' do
      subject { rename_enum('bad enum name', :lengths) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end

    context 'when called with a malformed new name' do
      subject { rename_enum(:sizes, 'bad enum name') }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '#drop_enum' do
    before { connection.execute "CREATE TYPE sizes AS ENUM ('small', 'medium', 'large', 'extra large')" }
    after  { connection.execute 'DROP TYPE IF EXISTS sizes' }

    context 'when called with valid arguments' do
      subject { drop_enum(:sizes) }

      it 'drops the enum' do
        expect(subject).to eq(PG::PGRES_COMMAND_OK)
        expect(connection.enums).not_to have_key(:sizes)
      end
    end

    context 'when called with a non-existent enum name' do
      subject { drop_enum(:non_existent_enum) }

      it 'raises ActiveRecord::StatementInvalid' do
        expect { subject }.to raise_exception(ActiveRecord::StatementInvalid)
      end
    end

    context 'when called with a malformed name' do
      subject { drop_enum('bad enum name') }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '#add_enum_value' do
    before { connection.execute "CREATE TYPE sizes AS ENUM ('small', 'large', 'extra large')" }
    after  { connection.execute 'DROP TYPE IF EXISTS sizes' }

    context 'when called with valid arguments' do
      subject { add_enum_value(:sizes, 'extra extra large') }

      it 'appends the value' do
        expect(subject).to eq(PG::PGRES_COMMAND_OK)
        expect(connection.enums[:sizes]).to eq(['small', 'large', 'extra large', 'extra extra large'])
      end

      context 'with :before' do
        subject { add_enum_value(:sizes, 'extra small', before: :small) }

        it 'inserts the value at the correct position' do
          expect(subject).to eq(PG::PGRES_COMMAND_OK)
          expect(connection.enums[:sizes]).to eq(['extra small', 'small', 'large', 'extra large'])
        end
      end

      context 'with :after' do
        subject { add_enum_value(:sizes, :medium, after: :small) }

        it 'inserts the value at the correct position' do
          expect(subject).to eq(PG::PGRES_COMMAND_OK)
          expect(connection.enums[:sizes]).to eq(['small', 'medium', 'large', 'extra large'])
        end
      end

      context 'with :before and :after' do
        subject { add_enum_value(:sizes, :medium, before: :large, after: :small) }

        it 'raises an ArgumentError' do
          expect { subject }.to raise_exception(ArgumentError)
        end
      end
    end

    context 'when called with a non-existent enum name' do
      subject { add_enum_value(:non_existent_enum, :new_value) }

      it 'raises ActiveRecord::StatementInvalid' do
        expect { subject }.to raise_exception(ActiveRecord::StatementInvalid)
      end
    end

    context 'when called with a malformed name' do
      subject { add_enum_value('bad enum name', :new_value) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '#rename_enum_value' do
    before { connection.execute "CREATE TYPE sizes AS ENUM ('small', 'medium', 'large', 'extra large')" }
    after  { connection.execute 'DROP TYPE IF EXISTS sizes' }

    context 'when called with valid arguments' do
      subject { rename_enum_value(:sizes, 'extra large', :extra_large) }

      it 'renames the value' do
        expect(subject).to eq(PG::PGRES_COMMAND_OK)
        expect(connection.enums[:sizes]).to eq(%w[small medium large extra_large])
      end

      context 'when using PostgreSQL < 10.0' do
        before do
          allow(connection).to receive(:postgresql_version).and_return(99_999)
        end

        it 'raises a NotImplementedError' do
          expect { subject }.to raise_exception(NotImplementedError)
        end
      end
    end

    context 'when called with a non-existent enum name' do
      subject { rename_enum_value(:non_existent_enum, :previous_value, :new_value) }

      it 'raises ActiveRecord::StatementInvalid' do
        expect { subject }.to raise_exception(ActiveRecord::StatementInvalid)
      end
    end

    context 'when called with a non-existent enum value' do
      subject { rename_enum_value(:sizes, 'extra extra large', :extra_extra_large) }

      it 'raises ActiveRecord::StatementInvalid' do
        expect { subject }.to raise_exception(ActiveRecord::StatementInvalid)
      end
    end

    context 'when called with a malformed name' do
      subject { rename_enum_value('bad enum name', 'extra large', :extra_large) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end

    context 'when called with a malformed current value' do
      subject { rename_enum_value(:sizes, 'extra-large', :extra_large) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end

    context 'when called with a malformed new value' do
      subject { rename_enum_value(:sizes, 'extra large', 'extra-large') }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end

    context 'when called with an equivalent current value and new value' do
      subject { rename_enum_value(:sizes, 'extra large', 'extra large') }

      it 'raises ActiveRecord::StatementInvalid' do
        expect { subject }.to raise_exception(ActiveRecord::StatementInvalid)
      end
    end

    context 'when called with a new value matching an existing value' do
      subject { rename_enum_value(:sizes, 'extra large', :large) }

      it 'raises ActiveRecord::StatementInvalid' do
        expect { subject }.to raise_exception(ActiveRecord::StatementInvalid)
      end
    end
  end
end
