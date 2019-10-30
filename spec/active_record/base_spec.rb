# frozen_string_literal: true

RSpec.describe ActiveRecord::Base, :unit do
  describe '.pg_enum' do
    it 'is defined' do
      expect(described_class).to respond_to(:pg_enum)
    end
  end

  describe '.pg_enum_values' do
    it 'is defined' do
      expect(described_class).to respond_to(:pg_enum_values)
    end
  end
end
