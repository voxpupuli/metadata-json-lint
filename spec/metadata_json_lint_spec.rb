describe MetadataJsonLint do
  describe '.validate_requirements!' do
    context 'empty requirements' do
      let :requirements do
        []
      end

      it { expect { described_class.validate_requirements!(requirements) }.not_to raise_error }
    end

    context 'with openvox' do
      let :requirements do
        [
          { 'name' => 'openvox', 'version_requirement' => '>= 7.0.0 < 9.0.0' },
        ]
      end

      it { expect { described_class.validate_requirements!(requirements) }.not_to raise_error }
    end

    context 'with openvox and puppet' do
      let :requirements do
        [
          { 'name' => 'puppet', 'version_requirement' => '>= 6.0.0 < 8.0.0' },
          { 'name' => 'openvox', 'version_requirement' => '>= 7.0.0 < 9.0.0' },
        ]
      end

      it { expect { described_class.validate_requirements!(requirements) }.not_to raise_error }
    end

    context 'with pe' do
      let :requirements do
        [
          { 'name' => 'pe' },
        ]
      end

      it do
        expect(described_class).to receive('warn').with(:requirements,
                                                        "The 'pe' requirement is no longer supported by the Forge.")
        expect { described_class.validate_requirements!(requirements) }.not_to raise_error
      end
    end

    context 'with invalid requirement' do
      let :requirements do
        [
          { 'name' => 'puppet', 'version_requirement' => 'a' },
        ]
      end

      it do
        expect(described_class).to receive('error').with(:requirements,
                                                         "Invalid 'version_requirement' field in metadata.json: Unparsable version range: \"a\"")
        expect { described_class.validate_requirements!(requirements) }.not_to raise_error
      end
    end
  end
end
