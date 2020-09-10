# Memory storage region
#
# Details from architecture spec:
# - [first storage region:] memory with 15-bit address space storing 16-bit values
# - address 0 is the first 16-bit value, address 1 is the second 16-bit value, etc

class MemoryError < StandardError ; end

class Memory
  MAX_ADDRESS = 0x7FFF
  MAX_VALUE = 0xFFFF

  def initialize
    @memory = Array.new(MAX_ADDRESS+1, 0)
  end

  def get(addr)
    validate_address addr
    @memory[addr]
  end

  def set(addr, value)
    validate_address addr
    validate_value value
    @memory[addr] = value
  end

  # Details from architecture spec:
  # - each number is stored as a 16-bit little-endian pair (low byte, high byte)
  # - programs are loaded into memory starting at address 0
  def load_program(filename)
    content = IO.binread(filename)
    size = content.size / 2
    (0..size-1).each do |addr|
      lsb = content[addr * 2].ord
      msb = content[addr * 2 + 1].ord
      set(addr, msb * 0x100 + lsb)
    end
    size
  end

  def load_string(string)
    values = string.split(/,/).map{|v| (v =~ %r{^0x}) ? v.to_i(16) : v.to_i }
    size = values.size
    (0..size-1).each do |addr|
      set(addr, values[addr])
    end
    size
  end

  def patch(reg_init)
    if reg_init.respond_to?(:size) && (reg_init.size == 2)
      if reg_init[0] == 7
        # 0209 JT   R7 0x0445
        if (get(0x0209) == 0x07) && (get(0x020a) == 0x8007) && (get(0x020b) == 0x0445)
          set(0x0209, 0x08)  # change to JF
        end
      end
    end
  end

protected

  def validate_address(addr)
    raise MemoryError, 'negative address' if addr < 0x0
    raise MemoryError, 'address outside address space' if addr > MAX_ADDRESS
  end

  def validate_value(value)
    raise MemoryError, 'negative value' if value < 0x0
    raise MemoryError, 'value overflow' if value > MAX_VALUE
  end
end
