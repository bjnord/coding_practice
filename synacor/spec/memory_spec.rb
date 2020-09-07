require_relative '../app/memory'

describe Memory do
  let(:memory) { Memory.new }
  it 'should initialize all memory to 0' do
    expect(memory.get(0)).to be == 0x0
    expect(memory.get(0x7fff)).to be == 0x0
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
