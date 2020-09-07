# Complex memory value parser
#
# Details from architecture spec:
# - all numbers are unsigned integers 0..32767 (15-bit)
# - numbers 0..32767 mean a literal value
# - numbers 32768..32775 instead mean registers 0..7
# - numbers 32776..65535 are invalid

class ComplexValueError < StandardError ; end

class ComplexValue
  REGISTER_MASK = 0x8000
  VALUE_MASK = 0x7FFF

  attr_reader :value

  def initialize(cvalue)
    @is_register = ((cvalue & REGISTER_MASK) != 0x0)
    @value = (cvalue & VALUE_MASK)
    validate_self
  end

  def register? ; @is_register ; end

protected

  def validate_self
    raise ComplexValueError, 'invalid value' if register? && (value > 0x7)
  end
end
