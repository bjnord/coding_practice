# Instruction decoder

require_relative './complex_value'

class InstructionError < StandardError ; end

class Instruction
  INSTRUCTIONS = {
    0x00 => {opcode: 'HALT', n_args: 0},
    0x13 => {opcode: 'OUT', n_args: 1},
    0x15 => {opcode: 'NOP', n_args: 0},
  }

  # Fetch one instruction and its arguments.
  #
  # * @param [Memory] +memory+ The memory storage area.
  # * @param [Integer] +pc+ The location in memory from which to fetch the instruction and its arguments.
  #
  # @return [Hash]
  # * +:opcode+ [String] The instruction's opcode (_e.g._ +NOP+)
  # * +:args+ [Array] The instruction's argument list (array of +ComplexValue+)
  # * +:pc+ [Integer] The updated +PC+
  def self.fetch(memory, pc)
    ret = {args: []}
    val = memory.get(pc)
    op = INSTRUCTIONS[val]
    raise InstructionError, "unknown instruction 0x#{val.to_s(16).rjust(2, '0')}" unless op
    pc += 1
    ret[:opcode] = op[:opcode]
    op[:n_args].times do |n|
      ret[:args] << ComplexValue.new(memory.get(pc))
      pc += 1
    end
    ret[:pc] = pc
    ret
  end
end
