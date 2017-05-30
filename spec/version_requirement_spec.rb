describe MetadataJsonLint::VersionRequirement do
  describe '.new' do
    it { expect(described_class.new('')).to be_a(MetadataJsonLint::VersionRequirement) }
    it { expect(described_class.new('>= 1.0')).to be_a(MetadataJsonLint::VersionRequirement) }
    it { expect { described_class.new('## 1.0') }.to raise_error(ArgumentError) }
  end

  describe '#mixed_syntax?' do
    it { expect(described_class.new('>= 1.0.0').mixed_syntax?).to be false }
    it { expect(described_class.new('1.0.x').mixed_syntax?).to be false }
    it { expect(described_class.new('>= 1.0.0 < 2.0').mixed_syntax?).to be false }
    it { expect(described_class.new('< 2.0').mixed_syntax?).to be false }

    it { expect(described_class.new('>= 1.0.x').mixed_syntax?).to be true }
    it { expect(described_class.new('>= 1.0.*').mixed_syntax?).to be true }
    it { expect(described_class.new('>= 1.x').mixed_syntax?).to be true }
    it { expect(described_class.new('>= 1.x.x').mixed_syntax?).to be true }
    it { expect(described_class.new('>= 1.*').mixed_syntax?).to be true }
    it { expect(described_class.new('>= 1.0.0 < 2.x').mixed_syntax?).to be true }
    it { expect(described_class.new('<2.x').mixed_syntax?).to be true }
  end

  describe '#open_ended?' do
    it { expect(described_class.new('>= 1.0 < 2.0').open_ended?).to be false }
    it { expect(described_class.new('>= 1.0').open_ended?).to be true }
    it { expect(described_class.new('').open_ended?).to be true }
  end
end
