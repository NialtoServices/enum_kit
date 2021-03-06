# frozen_string_literal: true

RSpec.describe 'ActiveRecord Schema', :integration do
  let(:connection) { ActiveRecord::Base.connection }
  let(:stream)     { StringIO.new }

  subject do
    ActiveRecord::SchemaDumper.dump(connection, stream)
    stream.rewind
    stream.read.split("\n").map { |line| line.gsub(/\s+/, ' ').strip }
  end

  it 'includes `create_enum` statements' do
    expect(subject).to include('create_enum :shirt_size, ["small", "medium", "large"]')
  end

  it 'includes `t.enum` statements' do
    expect(subject).to include('t.enum "size", enum_type: "shirt_size"')
  end
end
