describe MetadataJsonLint::Schema do
  describe '#schema' do
    it { expect(subject.schema).to be_a(Hash) }
  end

  describe '#validate' do
    let(:minimal) do
      { author: '', dependencies: [], license: 'A', name: 'a-a', source: '', summary: '', version: '1.0.0' }
    end

    context 'with empty hash' do
      subject { described_class.new.validate({}) }

      it { is_expected.to be_a(Array) }
      it { expect(subject.size).to eq(7) }
      it { is_expected.to include(field: 'root', message: "The file did not contain a required property of 'author'") }
    end

    context 'with minimal entries' do
      subject { described_class.new.validate(minimal) }

      it { is_expected.to eq([]) }
    end

    context 'with validation error on entry' do
      subject { described_class.new.validate(minimal.merge(summary: 'A' * 145)) }

      it {
        expect(subject).to eq([{ field: 'summary',
                                 message: "The property 'summary' was not of a maximum string length of 144", }])
      }
    end

    context 'with validation error on nested entry' do
      subject { described_class.new.validate(minimal.merge(dependencies: [{ name: 'in###id' }])) }

      it { expect(subject.size).to eq(1) }

      it {
        expect(subject).to include(field: 'dependencies',
                                   message: a_string_matching(%r{The property 'dependencies/0/name' value "in###id" did not match the regex}))
      }
    end

    context 'with semver validation failure' do
      subject { described_class.new.validate(minimal.merge(version: 'a')) }

      it { expect(subject.size).to eq(1) }

      it {
        expect(subject).to include(field: 'version',
                                   message: a_string_matching(/The property 'version' must be a valid semantic version/))
      }
    end
  end
end
