require_relative '../app/register_set'

describe RegisterSet do
  let(:register_set) { RegisterSet.new }
  it 'should initialize all registers to 0' do
    expect(register_set.get(0)).to be == 0x0
    expect(register_set.get(RegisterSet::MAX_NUMBER)).to be == 0x0
  end
  it 'should retrieve a previously-stored value' do
    expect(register_set.get(5)).to be == 0x0
    register_set.set(5, 0x4321)
    expect(register_set.get(5)).to be == 0x4321
    register_set.set(5, 0x0)
    expect(register_set.get(5)).to be == 0x0
  end

  describe '#get' do
    let(:register_set) { RegisterSet.new }
    it 'should disallow negative register numbers' do
      expect{ register_set.get(-1) }.to raise_error(RegisterSetError, 'negative register number')
    end
    it 'should allow minimum register number' do
      expect{ register_set.get(0) }.not_to raise_error
    end
    it 'should allow maximum register number' do
      expect{ register_set.get(RegisterSet::MAX_NUMBER) }.not_to raise_error
    end
    it 'should disallow register numbers above maximum' do
      expect{ register_set.get(RegisterSet::MAX_NUMBER+1) }.to raise_error(RegisterSetError, 'register number above maximum')
    end
  end

  describe '#set' do
    let(:register_set) { RegisterSet.new }
    it 'should disallow negative register numbers' do
      expect{ register_set.set(-1, 0x1) }.to raise_error(RegisterSetError, 'negative register number')
    end
    it 'should allow minimum register number' do
      expect{ register_set.set(0, 0x2) }.not_to raise_error
    end
    it 'should allow maximum register number' do
      expect{ register_set.set(RegisterSet::MAX_NUMBER, 0x3) }.not_to raise_error
    end
    it 'should disallow register numbers above maximum' do
      expect{ register_set.set(RegisterSet::MAX_NUMBER+1, 0x4) }.to raise_error(RegisterSetError, 'register number above maximum')
    end
    it 'should disallow negative values' do
      expect{ register_set.set(1, -1) }.to raise_error(RegisterSetError, 'negative value')
    end
    it 'should allow minimum value' do
      expect{ register_set.set(2, 0x0) }.not_to raise_error
    end
    it 'should allow maximum value' do
      expect{ register_set.set(3, RegisterSet::MAX_VALUE) }.not_to raise_error
    end
    it 'should disallow too-large values' do
      expect{ register_set.set(4, RegisterSet::MAX_VALUE+1) }.to raise_error(RegisterSetError, 'value overflow')
    end
  end
end
