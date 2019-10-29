# frozen_string_literal: true

RSpec.describe EnumKit do
  describe '::VERSION' do
    subject { described_class::VERSION }

    it 'is semantic' do
      expect(subject).to match(/[0-9]+\.[0-9]+\.[0-9]+/)
    end
  end
end
