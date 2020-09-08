require_relative '../app/memory'

describe Memory do
  let(:memory) { Memory.new }
  it 'should initialize all memory to 0' do
    expect(memory.get(0)).to be == 0x0
    expect(memory.get(Memory::MAX_ADDRESS)).to be == 0x0
  end
  it 'should retrieve a previously-stored 16-bit value' do
    expect(memory.get(0x55)).to be == 0x0
    memory.set(0x55, 0x9005)
    expect(memory.get(0x55)).to be == 0x9005
    memory.set(0x55, 0x0)
    expect(memory.get(0x55)).to be == 0x0
  end

  describe '#get' do
    let(:memory) { Memory.new }
    it 'should disallow negative addresses' do
      expect{ memory.get(-1) }.to raise_error(MemoryError, 'negative address')
    end
    it 'should allow minimum address' do
      expect{ memory.get(0x0) }.not_to raise_error
    end
    it 'should allow maximum address' do
      expect{ memory.get(Memory::MAX_ADDRESS) }.not_to raise_error
    end
    it 'should disallow addresses outside address space' do
      expect{ memory.get(Memory::MAX_ADDRESS+1) }.to raise_error(MemoryError, 'address outside address space')
    end
  end

  describe '#set' do
    let(:memory) { Memory.new }
    it 'should disallow negative addresses' do
      expect{ memory.set(-1, 0x1) }.to raise_error(MemoryError, 'negative address')
    end
    it 'should allow minimum address' do
      expect{ memory.set(0x0, 0x5) }.not_to raise_error
    end
    it 'should allow maximum address' do
      expect{ memory.set(Memory::MAX_ADDRESS, 0x6) }.not_to raise_error
    end
    it 'should disallow addresses outside address space' do
      expect{ memory.set(Memory::MAX_ADDRESS+1, 0x2) }.to raise_error(MemoryError, 'address outside address space')
    end
    it 'should disallow negative values' do
      expect{ memory.set(0x3, -1) }.to raise_error(MemoryError, 'negative value')
    end
    it 'should allow minimum value' do
      expect{ memory.set(0x7, 0x0) }.not_to raise_error
    end
    it 'should allow maximum value' do
      expect{ memory.set(0x8, Memory::MAX_VALUE) }.not_to raise_error
    end
    it 'should disallow too-large values' do
      expect{ memory.set(0x4, Memory::MAX_VALUE+1) }.to raise_error(MemoryError, 'value overflow')
    end
  end

  describe '#load_program' do
    let(:memory) { Memory.new }
    it 'should load the test file properly' do
      expect(memory.load_program('test/load_program.bin')).to be == 71
      expect(memory.get(0x00)).to be == 0x15
      expect(memory.get(0x02)).to be == 0x13
      expect(memory.get(0x03)).to be == 0x57
      expect(memory.get(0x45)).to be == 0x0a
      expect(memory.get(0x46)).to be == 0x00
    end
  end

  describe '#load_string' do
    let(:memory) { Memory.new }
    it 'should load the test string properly' do
      expect(memory.load_string('0x15,0x15,0x00')).to be == 3
      expect(memory.get(0x00)).to be == 0x15
      expect(memory.get(0x01)).to be == 0x15
      expect(memory.get(0x02)).to be == 0x00
    end
  end
end
