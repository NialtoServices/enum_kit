# frozen_string_literal: true

RSpec.describe ActiveRecord::ConnectionAdapters::PostgreSQLAdapter, :unit do
  subject(:connection) { ActiveRecord::Base.connection }

  before do
    # Sanity check to ensure ActiveRecord is configured to use a PostgreSQL database.
    expect(connection).to be_a(described_class)
  end

  describe '#create_enum' do
    after { connection.execute 'DROP TYPE IF EXISTS an_enum' }

    context 'when called with valid arguments' do
      subject { connection.create_enum(:an_enum, [:first_value, 'second value']) }

      it 'creates an enum' do
        expect(subject.result_status).to eq(PG::PGRES_COMMAND_OK)
      end
    end

    context 'when called with a malformed name' do
      subject { connection.create_enum('an enum', [:first_value, 'second value']) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end

    context 'when called with malformed values' do
      subject { connection.create_enum(:an_enum, [:good_value, 'bad$value']) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '#drop_enum' do
    before { connection.execute "CREATE TYPE an_enum AS ENUM ('first', 'second')" }
    after  { connection.execute 'DROP TYPE IF EXISTS an_enum' }

    context 'when called with valid arguments' do
      subject { connection.drop_enum(:an_enum) }

      it 'drops the enum' do
        expect(subject.result_status).to eq(PG::PGRES_COMMAND_OK)
      end
    end

    context 'when called with a non-existent enum name' do
      subject { connection.drop_enum(:non_existent_enum) }

      it 'raises ActiveRecord::StatementInvalid' do
        expect { subject }.to raise_exception(ActiveRecord::StatementInvalid)
      end
    end

    context 'when called with a malformed name' do
      subject { connection.drop_enum('an enum') }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '#rename_enum' do
    before do
      connection.execute "CREATE TYPE an_enum AS ENUM ('first', 'second')"
    end

    after do
      connection.execute 'DROP TYPE IF EXISTS an_enum'
      connection.execute 'DROP TYPE IF EXISTS another_enum'
    end

    context 'when called with an existing enum' do
      subject { connection.rename_enum(:an_enum, :another_enum) }

      it 'renames the enum' do
        expect(subject.result_status).to eq(PG::PGRES_COMMAND_OK)
      end
    end

    context 'when called with a non-existent enum' do
      subject { connection.rename_enum(:non_existent_enum, :another_enum) }

      it 'raises ActiveRecord::StatementInvalid' do
        expect { subject }.to raise_exception(ActiveRecord::StatementInvalid)
      end
    end

    context 'when called with a malformed current name' do
      subject { connection.rename_enum('an enum', :another_enum) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end

    context 'when called with a malformed new name' do
      subject { connection.rename_enum(:an_enum, 'another enum') }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end
  end
end
