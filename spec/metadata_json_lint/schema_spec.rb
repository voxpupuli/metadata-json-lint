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

    context 'with valid operating system support objects' do
      subject { described_class.new.validate(minimal.merge(operatingsystem_support: support)) }

      let(:support) do
        [
          { operatingsystem: 'RedHat', operatingsystemrelease: %w[8 9] },
          { operatingsystem: 'Debian', operatingsystemrelease: %w[12 13] },
        ]
      end

      it { is_expected.to eq([]) }
    end

    context 'with an empty operating system support array' do
      subject { described_class.new.validate(minimal.merge(operatingsystem_support: [])) }

      it { is_expected.to eq([]) }
    end

    {
      operatingsystem: { operatingsystemrelease: ['12'] },
      operatingsystemrelease: { operatingsystem: 'Debian' },
    }.each do |key, entry|
      context "with operating system support missing #{key}" do
        subject { described_class.new.validate(minimal.merge(operatingsystem_support: [entry])) }

        it do
          expect(subject).to contain_exactly(
            field: 'operatingsystem_support',
            message: "The property 'operatingsystem_support/0' did not contain a required property of '#{key}'",
          )
        end
      end
    end

    ['RedHat', 42, true, nil, []].each do |entry|
      context "with a non-object operating system support entry #{entry.inspect}" do
        subject { described_class.new.validate(minimal.merge(operatingsystem_support: support)) }

        let(:support) { [{ operatingsystem: 'Debian', operatingsystemrelease: ['12'] }, entry] }

        it do
          expect(subject).to contain_exactly(
            field: 'operatingsystem_support',
            message: a_string_matching(%r{operatingsystem_support/1.*did not match the following type: object}),
          )
        end
      end
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
