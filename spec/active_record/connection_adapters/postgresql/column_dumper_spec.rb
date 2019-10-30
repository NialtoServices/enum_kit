# frozen_string_literal: true

# The `ColumnDumper` class is used by ActiveRecord '< 5.2.0'.
# For newer versions, see the `SchemaDumper` class instead.
return unless defined?(ActiveRecord::ConnectionAdapters::PostgreSQL::ColumnDumper)

RSpec.describe ActiveRecord::ConnectionAdapters::PostgreSQL::ColumnDumper do
  let(:connection) { ActiveRecord::Base.connection }
  let(:stream)     { StringIO.new }

  subject do
    options = {
      table_name_prefix: ActiveRecord::Base.table_name_prefix,
      table_name_suffix: ActiveRecord::Base.table_name_suffix
    }

    described_class.send(:new, connection, options)
  end

  describe '#enums' do
    let(:result) do
      subject.enums(stream)
      stream.rewind
      stream.read
    end

    context 'when the database has enums' do
      before do
        expect(connection).to receive(:enums).and_return(color: %w[red green blue], size: %w[small medium large])
      end

      it 'generates matching `create_enum` statements' do
        expect(result).to include('create_enum :color, ["red", "green", "blue"]')
        expect(result).to include('create_enum :size, ["small", "medium", "large"]')
      end
    end

    context 'when the database has no enums' do
      before do
        expect(connection).to receive(:enums).and_return({})
      end

      it 'generates nothing' do
        expect(result).to be_empty
      end
    end
  end

  describe '#extensions' do
    it 'invokes #enums' do
      expect(subject).to receive(:enums).with(stream).once
      subject.extensions(stream)
    end
  end
end
