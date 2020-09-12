# Main machine class

# <https://harfangk.github.io/2017/01/01/how-to-enable-tail-call-recursion-in-ruby.html>
# we're using option #2:
# - include the `compile_option` code
# - and then `require` the code we want TRO on
#
RubyVM::InstructionSequence.compile_option = {
  :tailcall_optimization => true,
  :trace_instruction => false
}

require_relative './instruction'
require_relative './logic'
require_relative './memory'
require_relative './optimized_f'
require_relative './register_set'
require_relative './stack'

class MachineError < StandardError ; end

class Machine
  def initialize(opts)
    @pc = 0
    @memory = Memory.new
    @registers = RegisterSet.new(opts[:reg_init])
    @stack = Stack.new
    @buffer = ''
    @debug = opts[:debug]
    if opts[:program_file]
      @size = @memory.load_program(opts[:program_file])
    elsif opts[:program_string]
      @size = @memory.load_string(opts[:program_string])
    else
      @size = 0
    end
    @memory.patch(opts[:reg_init])
    r7 = @registers.get(7)
    @call_178b = (r7 > 0) ? OptimizedF.new(r7) : nil
    @input = opts[:input_file] ? File.readlines(opts[:input_file]) : []
  end

  def run
    $stderr.puts "[running]"
    while true do
      inst = Instruction.fetch(@memory, @pc)
      Instruction.dump(inst, @pc) if @debug
      new_pc = inst[:pc]
      case inst[:opcode]
      when 'NOP'
        # do nothing
      when 'SET'
        raise MachineError, 'SET arg a is not a register' unless inst[:args][0].register?
        @registers.set(inst[:args][0].value, arg_value(inst[:args][1]))
      when 'PUSH'
        @stack.push(arg_value(inst[:args][0]))
      when 'POP'
        raise MachineError, 'POP arg a is not a register' unless inst[:args][0].register?
        @registers.set(inst[:args][0].value, @stack.pop)
      when 'EQ'
        raise MachineError, 'EQ arg a is not a register' unless inst[:args][0].register?
        @registers.set(inst[:args][0].value, Logic.eq(arg_value(inst[:args][1]), arg_value(inst[:args][2])))
      when 'GT'
        raise MachineError, 'GT arg a is not a register' unless inst[:args][0].register?
        @registers.set(inst[:args][0].value, Logic.gt(arg_value(inst[:args][1]), arg_value(inst[:args][2])))
      when 'JMP'
        new_pc = arg_value(inst[:args][0])
      when 'JT'
        if arg_value(inst[:args][0]) != 0
          new_pc = arg_value(inst[:args][1])
        end
      when 'JF'
        if arg_value(inst[:args][0]) == 0
          new_pc = arg_value(inst[:args][1])
        end
      when 'ADD'
        raise MachineError, 'ADD arg a is not a register' unless inst[:args][0].register?
        @registers.set(inst[:args][0].value, Logic.add(arg_value(inst[:args][1]), arg_value(inst[:args][2])))
      when 'MULT'
        raise MachineError, 'MULT arg a is not a register' unless inst[:args][0].register?
        @registers.set(inst[:args][0].value, Logic.mult(arg_value(inst[:args][1]), arg_value(inst[:args][2])))
      when 'MOD'
        raise MachineError, 'MOD arg a is not a register' unless inst[:args][0].register?
        @registers.set(inst[:args][0].value, Logic.mod(arg_value(inst[:args][1]), arg_value(inst[:args][2])))
      when 'AND'
        raise MachineError, 'AND arg a is not a register' unless inst[:args][0].register?
        @registers.set(inst[:args][0].value, Logic.and(arg_value(inst[:args][1]), arg_value(inst[:args][2])))
      when 'OR'
        raise MachineError, 'OR arg a is not a register' unless inst[:args][0].register?
        @registers.set(inst[:args][0].value, Logic.or(arg_value(inst[:args][1]), arg_value(inst[:args][2])))
      when 'NOT'
        raise MachineError, 'NOT arg a is not a register' unless inst[:args][0].register?
        @registers.set(inst[:args][0].value, Logic.not(arg_value(inst[:args][1])))
      when 'RMEM'
        raise MachineError, 'RMEM arg a is not a register' unless inst[:args][0].register?
        @registers.set(inst[:args][0].value, @memory.get(arg_value(inst[:args][1])))
      when 'WMEM'
        @memory.set(arg_value(inst[:args][0]), arg_value(inst[:args][1]))
      when 'CALL'
        addr = arg_value(inst[:args][0])
        if (addr == 0x178b) && @call_178b
          r = @call_178b.f([@registers.get(0), @registers.get(1)])
          @registers.set(0, r[0])
          @registers.set(1, r[1])
        else
          @stack.push(new_pc)
          new_pc = addr
        end
      when 'RET'
        new_pc = @stack.pop
      when 'OUT'
        print arg_value(inst[:args][0]).chr
      when 'IN'
        raise MachineError, 'IN arg a is not a register' unless inst[:args][0].register?
        if @buffer.empty?
          if @input.empty?
            @buffer = gets
          else
            @buffer = @input.shift
            print @buffer
          end
        end
        @registers.set(inst[:args][0].value, @buffer[0].ord)
        @buffer[0] = ''
      when 'HALT'
        $stderr.puts "[halted]"
        return
      else
        raise MachineError, "unimplemented opcode #{inst[:opcode]} at PC=0x#{@pc.to_s(16).rjust(4, '0')} (byte=0x#{(@pc * 2).to_s(16).rjust(4, '0')})"
      end
      @pc = new_pc
    end
  end

  def disassemble
    while @pc < @size do
      if (d = @memory.get(@pc)) > 0x15
        $stderr.puts "%04x DATA 0x%04x " % [@pc, d]
        @pc += 1
      else
        inst = Instruction.fetch(@memory, @pc)
        Instruction.dump(inst, @pc)
        @pc = inst[:pc]
      end
    end
  end

protected

  def arg_value(cvalue)
    if cvalue.register?
      @registers.get(cvalue.value)
    else
      cvalue.value
    end
  end
end
