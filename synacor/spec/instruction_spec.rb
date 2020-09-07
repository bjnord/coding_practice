require_relative '../app/instruction'
require_relative '../app/memory'

describe Instruction do
  context 'with all no-argument operations' do
    let(:memory) { Memory.new }
    before(:each) { memory.load_string('0x15,0x15,0x00') }

    it 'should decode the instructions' do
      expect(Instruction.fetch(memory, 0)).to be == {opcode: 'NOP', args: [], pc: 1}
      expect(Instruction.fetch(memory, 1)).to be == {opcode: 'NOP', args: [], pc: 2}
      expect(Instruction.fetch(memory, 2)).to be == {opcode: 'HALT', args: [], pc: 3}
    end
  end

  context 'with mixed n-argument operations' do
    let(:memory) { Memory.new }
    before(:each) { memory.load_string('0x15,0x13,0x57,0x00') }

    it 'should decode the instructions' do
      expect(Instruction.fetch(memory, 0)).to be == {opcode: 'NOP', args: [], pc: 1}
      inst = Instruction.fetch(memory, 1)
      expect(inst.slice(:opcode, :pc)).to be == {opcode: 'OUT', pc: 3}
      expect(inst[:args].size).to be == 1
      expect(inst[:args][0].register?).to be_falsey
      expect(inst[:args][0].value).to be == 0x57
      expect(Instruction.fetch(memory, 3)).to be == {opcode: 'HALT', args: [], pc: 4}
    end
  end

  context 'with an unknown instruction' do
    let(:memory) { Memory.new }
    before(:each) { memory.load_string('0x58,0x13') }

    it 'should raise an error' do
      expect{ Instruction.fetch(memory, 0) }.to raise_error(InstructionError, 'unknown instruction 0x58')
    end
  end
end
