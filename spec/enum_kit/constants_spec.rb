# frozen_string_literal: true

require 'enum_kit/constants'

RSpec.describe EnumKit do
  it 'has a semantic version' do
    expect(described_class::VERSION).to match(/[0-9]+\.[0-9]+\.[0-9]+/)
  end
end
