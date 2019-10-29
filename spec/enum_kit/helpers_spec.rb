# frozen_string_literal: true

RSpec.describe EnumKit do
  describe '.underscore' do
    it 'converts camel case into snake case' do
      expect(described_class.underscore('EnumKit')).to eq('enum_kit')
    end

    it 'converts namespaces into paths' do
      expect(described_class.underscore('EnumKit::Example')).to eq('enum_kit/example')
    end

    it 'treats PostgreSQL as an acronym' do
      expect(described_class.underscore('PostgreSQL')).to eq('postgresql')
    end
  end

  describe '.sqlize' do
    context 'with a String' do
      subject { described_class.sqlize('value') }

      it 'returns a quoted String' do
        expect(subject).to eq("'value'")
      end
    end

    context 'with a Symbol' do
      subject { described_class.sqlize(:value) }

      it 'returns a quoted String' do
        expect(subject).to eq("'value'")
      end
    end

    context 'with an Array' do
      subject { described_class.sqlize(%i[one two three]) }

      it 'returns a SQL array representation' do
        expect(subject).to eq("('one', 'two', 'three')")
      end
    end
  end

  describe '.sanitize_name!' do
    it 'permits lowercase letters' do
      expect(described_class.sanitize_name!('abc')).to eq('abc')
    end

    it 'permits numbers' do
      expect(described_class.sanitize_name!('123')).to eq('123')
    end

    it 'permits underscores' do
      expect(described_class.sanitize_name!('_')).to eq('_')
    end

    it 'rejects hyphens' do
      expect { described_class.sanitize_name!('-') }.to raise_exception(ArgumentError)
    end

    it 'rejects spaces' do
      expect { described_class.sanitize_name!(' ') }.to raise_exception(ArgumentError)
    end

    it 'rejects uppercase letters' do
      expect { described_class.sanitize_name!('ABC') }.to raise_exception(ArgumentError)
    end
  end

  describe '.sanitize_value!' do
    it 'permits lowercase letters' do
      expect(described_class.sanitize_value!('abc')).to eq('abc')
    end

    it 'permits numbers' do
      expect(described_class.sanitize_value!('123')).to eq('123')
    end

    it 'permits spaces' do
      expect(described_class.sanitize_value!(' ')).to eq(' ')
    end

    it 'permits underscores' do
      expect(described_class.sanitize_value!('_')).to eq('_')
    end

    it 'rejects hyphens' do
      expect { described_class.sanitize_value!('-') }.to raise_exception(ArgumentError)
    end

    it 'rejects uppercase letters' do
      expect { described_class.sanitize_value!('ABC') }.to raise_exception(ArgumentError)
    end
  end

  describe '.sanitize_values!' do
    subject { described_class.sanitize_values!(%i[one two three]) }

    it 'calls .sanitize_value! for each of the inputs' do
      expect(described_class).to receive(:sanitize_value!).with(:one).once
      expect(described_class).to receive(:sanitize_value!).with(:two).once
      expect(described_class).to receive(:sanitize_value!).with(:three).once
      subject
    end
  end
end
