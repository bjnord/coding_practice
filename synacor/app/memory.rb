# Memory storage region
#
# Details from architecture spec:
# - [first storage region:] memory with 15-bit address space storing 16-bit values
# - all numbers are unsigned integers 0..32767 (15-bit)
# - address 0 is the first 16-bit value, address 1 is the second 16-bit value, etc

class Memory
  def initialize
    @memory = Array.new(0x8000, 0)
  end

  def get(addr)
    @memory[addr]
  end

  def set(addr, value)
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
end
