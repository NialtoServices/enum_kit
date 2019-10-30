# frozen_string_literal: true

RSpec.describe ActiveRecord::Validations::PgEnumValidator, :unit do
  subject { Shirt.create(name: 'Plain Shirt', size: :small) }

  it 'permits known values' do
    expect { subject.update!(size: :large) }.not_to raise_exception
    expect { subject.update!(size: :medium) }.not_to raise_exception
    expect { subject.update!(size: :small) }.not_to raise_exception
  end

  it 'rejects unknown values' do
    expect { subject.update!(size: :other) }.to raise_exception(ActiveRecord::RecordInvalid)
  end

  it 'rejects nil values' do
    expect { subject.update!(size: nil) }.to raise_exception(ActiveRecord::RecordInvalid)
  end
end
