# frozen_string_literal: true

RSpec.describe ActiveRecord::Validations::PgEnumValidator, :unit do
  subject { Shirt.create(name: 'Plain Shirt', size: :medium) }

  it 'passes validation when using supported values' do
    %i[small medium large].each do |size|
      expect(subject.update(size: size)).to eq(true)
      expect(subject).to be_valid
    end
  end

  it 'fails validation when using an unsupported value' do
    expect(subject.update(size: :other)).to eq(false)
    expect(subject).not_to be_valid
  end

  it 'fails validation when using nil' do
    expect(subject.update(size: nil)).to eq(false)
    expect(subject).not_to be_valid
  end
end
