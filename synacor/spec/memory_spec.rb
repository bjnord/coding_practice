require_relative '../app/memory'

describe Memory do
  let(:memory) { Memory.new }
  it 'should initialize all memory to 0' do
    expect(memory.get(0)).to be == 0x0
    expect(memory.get(Memory::MAX_ADDRESS)).to be == 0x0
  end

  describe '#get' do
    let(:memory) { Memory.new }
    it 'should disallow negative addresses' do
      expect{ memory.get(-1) }.to raise_error(MemoryError, 'negative address')
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
    it 'should disallow addresses outside address space' do
      expect{ memory.set(Memory::MAX_ADDRESS+1, 0x2) }.to raise_error(MemoryError, 'address outside address space')
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
end
