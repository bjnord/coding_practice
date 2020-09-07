require_relative './instruction'
require_relative './memory'

class MachineError < StandardError ; end

class Machine
  def initialize(opts)
    @pc = 0
    @memory = Memory.new
    if opts[:program_file]
      @memory.load_program(opts[:program_file])
    elsif opts[:program_string]
      @memory.load_string(opts[:program_string])
    end
  end

  def run
    $stderr.puts "[running]"
    while true do
      inst = Instruction.fetch(@memory, @pc)
      case inst[:opcode]
      when 'NOP'
        # do nothing
      when 'OUT'
        print inst[:args][0].value.chr
      when 'HALT'
        $stderr.puts "[halted]"
        return
      else
        raise MachineError, "unimplemented opcode #{inst[:opcode]} at PC=0x#{@pc.to_s(16).rjust(4, '0')} (byte=0x#{(@pc * 2).to_s(16).rjust(4, '0')})"
      end
      @pc = inst[:pc]
    end
  end
end
