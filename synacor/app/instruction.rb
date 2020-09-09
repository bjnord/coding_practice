# Instruction decoder

require_relative './complex_value'

class InstructionError < StandardError ; end

class Instruction
  INSTRUCTIONS = {
    0x00 => {opcode: 'HALT', n_args: 0},
    0x01 => {opcode: 'SET', n_args: 2},
    0x02 => {opcode: 'PUSH', n_args: 1},
    0x03 => {opcode: 'POP', n_args: 1},
    0x04 => {opcode: 'EQ', n_args: 3},
    0x05 => {opcode: 'GT', n_args: 3},
    0x06 => {opcode: 'JMP', n_args: 1},
    0x07 => {opcode: 'JT', n_args: 2},
    0x08 => {opcode: 'JF', n_args: 2},
    0x09 => {opcode: 'ADD', n_args: 3},
    0x0a => {opcode: 'MULT', n_args: 3},
    0x0b => {opcode: 'MOD', n_args: 3},
    0x0c => {opcode: 'AND', n_args: 3},
    0x0d => {opcode: 'OR', n_args: 3},
    0x0e => {opcode: 'NOT', n_args: 2},
    0x0f => {opcode: 'RMEM', n_args: 2},
    0x10 => {opcode: 'WMEM', n_args: 2},
    0x11 => {opcode: 'CALL', n_args: 1},
    0x12 => {opcode: 'RET', n_args: 0},
    0x13 => {opcode: 'OUT', n_args: 1},
    0x14 => {opcode: 'IN', n_args: 1},
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
    ret = {}
    op = fetch_op(memory, pc)
    ret[:opcode] = op[:opcode]
    ret[:args] = fetch_args(memory, pc, op[:n_args])
    ret[:pc] = pc + 1 + op[:n_args]
    ret
  end

  def self.dump(inst, pc)
    $stderr.print "%04x %-4s " % [pc, inst[:opcode]]
    inst[:args].each do |arg|
      ch = (arg.value < 0x7f) ? arg.value.chr : 0x00.chr
      if arg.register?
        $stderr.print "R%d " % [arg.value]
      elsif (inst[:opcode] == 'OUT') && (ch =~ %r{[[:print:]]})
        $stderr.print "'%s' " % [ch]
      else
        $stderr.print "0x%04x " % [arg.value]
      end
    end
    $stderr.puts ''
  end

protected

  def self.fetch_op(memory, pc)
    val = memory.get(pc)
    op = INSTRUCTIONS[val]
    raise InstructionError, "unknown instruction 0x#{val.to_s(16).rjust(2, '0')}" unless op
    op
  end

  def self.fetch_args(memory, pc, n_args)
    n_args.times.collect {|n| ComplexValue.new(memory.get(pc + 1 + n)) }
  end
end
