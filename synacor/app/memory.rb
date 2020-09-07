# Memory storage region
#
# Details from architecture spec:
# - [first storage region:] memory with 15-bit address space storing 16-bit values
# - all numbers are unsigned integers 0..32767 (15-bit)
# - address 0 is the first 16-bit value, address 1 is the second 16-bit value, etc

class MemoryError < StandardError ; end

class Memory
  MAX_ADDRESS = 0x7FFF
  MAX_VALUE = 0xFFFF
  REGISTER_MASK = 0x8000
  VALUE_MASK = 0x7FFF

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

protected

  def validate_address(addr)
    raise MemoryError, 'negative address' if addr < 0x0
    raise MemoryError, 'address outside address space' if addr > MAX_ADDRESS
  end

  # Details from architecture spec:
  # - all numbers are unsigned integers 0..32767 (15-bit)
  # - numbers 0..32767 mean a literal value
  # - numbers 32768..32775 instead mean registers 0..7
  # - numbers 32776..65535 are invalid
  def validate_value(value)
    raise MemoryError, 'negative value' if value < 0x0
    raise MemoryError, 'value overflow' if value > MAX_VALUE
    raise MemoryError, 'invalid value' if ((value & REGISTER_MASK) != 0x0) && ((value & VALUE_MASK) > 0x7)
  end
end
