# frozen_string_literal: true

RSpec.describe ActiveRecord::ConnectionAdapters::PostgreSQLAdapter, :unit do
  subject(:connection) { ActiveRecord::Base.connection }

  describe '#create_enum' do
    after { connection.execute 'DROP TYPE IF EXISTS an_enum' }

    it 'is defined' do
      expect(connection).to respond_to(:create_enum)
    end

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

    it 'is defined' do
      expect(connection).to respond_to(:drop_enum)
    end

    context 'when called with an existing enum' do
      subject { connection.drop_enum(:an_enum) }

      it 'drops the enum' do
        expect(subject.result_status).to eq(PG::PGRES_COMMAND_OK)
      end
    end

    context 'when called with a non-existent enum' do
      subject { connection.drop_enum(:non_existent_enum) }

      it 'raises ActiveRecord::StatementInvalid' do
        expect { subject }.to raise_exception(ActiveRecord::StatementInvalid)
      end
    end
  end
end
