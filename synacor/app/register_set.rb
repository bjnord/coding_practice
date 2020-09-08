# Register set storage region
#
# Details from architecture spec:
# - [second storage region:] eight registers
# - all numbers are unsigned integers 0..32767 (15-bit)

class RegisterSetError < StandardError ; end

class RegisterSet
  MAX_NUMBER = 7
  MAX_VALUE = 0x7FFF

  def initialize
    @registers = Array.new(MAX_NUMBER+1, 0x0)
  end

  def get(num)
    validate_number num
    @registers[num]
  end

  def set(num, value)
    validate_number num
    validate_value value
    @registers[num] = value
  end

protected

  def validate_number(addr)
    raise RegisterSetError, 'negative register number' if addr < 0
    raise RegisterSetError, 'register number above maximum' if addr > MAX_NUMBER
  end

  def validate_value(value)
    raise RegisterSetError, 'negative value' if value < 0x0
    raise RegisterSetError, 'value overflow' if value > MAX_VALUE
  end
end
