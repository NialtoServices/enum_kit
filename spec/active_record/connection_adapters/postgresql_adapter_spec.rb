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

  describe '#rename_enum' do
    before do
      connection.execute "CREATE TYPE an_enum AS ENUM ('first', 'second')"
    end

    after do
      connection.execute 'DROP TYPE IF EXISTS an_enum'
      connection.execute 'DROP TYPE IF EXISTS another_enum'
    end

    context 'when called with valid arguments' do
      subject { connection.rename_enum(:an_enum, :another_enum) }

      it 'renames the enum' do
        expect(subject.result_status).to eq(PG::PGRES_COMMAND_OK)
      end
    end

    context 'when called with a non-existent enum name' do
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

  describe '#add_enum_value' do
    before { connection.execute "CREATE TYPE numbers AS ENUM ('one', 'two', 'four', 'six', 'eight')" }
    after  { connection.execute 'DROP TYPE IF EXISTS numbers' }

    context 'when called with valid arguments' do
      subject { connection.add_enum_value(:numbers, :nine) }

      it 'appends the value' do
        expect(subject.result_status).to eq(PG::PGRES_COMMAND_OK)
        expect(connection.enums[:numbers]).to eq(%w[one two four six eight nine])
      end

      context 'with :before' do
        subject { connection.add_enum_value(:numbers, :three, before: :four) }

        it 'inserts the value at the correct position' do
          expect(subject.result_status).to eq(PG::PGRES_COMMAND_OK)
          expect(connection.enums[:numbers]).to eq(%w[one two three four six eight])
        end
      end

      context 'with :after' do
        subject { connection.add_enum_value(:numbers, :seven, after: :six) }

        it 'inserts the value at the correct position' do
          expect(subject.result_status).to eq(PG::PGRES_COMMAND_OK)
          expect(connection.enums[:numbers]).to eq(%w[one two four six seven eight])
        end
      end

      context 'with :before and :after' do
        subject { connection.add_enum_value(:numbers, :five, before: :six, after: :four) }

        it 'raises an ArgumentError' do
          expect { subject }.to raise_exception(ArgumentError)
        end
      end
    end

    context 'when called with a non-existent enum name' do
      subject { connection.add_enum_value(:non_existent_enum, :new_value) }

      it 'raises ActiveRecord::StatementInvalid' do
        expect { subject }.to raise_exception(ActiveRecord::StatementInvalid)
      end
    end

    context 'when called with a malformed name' do
      subject { connection.add_enum_value('an enum', :new_value) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '#rename_enum_value' do
    before { connection.execute "CREATE TYPE numbers AS ENUM ('one', 'two', 'four')" }
    after  { connection.execute 'DROP TYPE IF EXISTS numbers' }

    context 'when called with valid arguments' do
      subject { connection.rename_enum_value(:numbers, :four, :three) }

      it 'renames the value' do
        expect(subject.result_status).to eq(PG::PGRES_COMMAND_OK)
        expect(connection.enums[:numbers]).to eq(%w[one two three])
      end
    end

    context 'when called with a non-existent enum name' do
      subject { connection.rename_enum_value(:non_existent_enum, :four, :three) }

      it 'raises ActiveRecord::StatementInvalid' do
        expect { subject }.to raise_exception(ActiveRecord::StatementInvalid)
      end
    end

    context 'when called with a non-existent enum value' do
      subject { connection.rename_enum_value(:numbers, :ten, :three) }

      it 'raises ActiveRecord::StatementInvalid' do
        expect { subject }.to raise_exception(ActiveRecord::StatementInvalid)
      end
    end

    context 'when called with a malformed name' do
      subject { connection.rename_enum_value('an enum', :four, :three) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end

    context 'when called with a malformed current value' do
      subject { connection.rename_enum_value(:numbers, 'bad$value', :three) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end

    context 'when called with a malformed new value' do
      subject { connection.rename_enum_value(:numbers, :four, 'bad$value') }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_exception(ArgumentError)
      end
    end
  end
end
