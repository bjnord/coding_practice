# Stack storage region
#
# Details from architecture spec:
# - [third storage region:] an unbounded stack which holds individual 16-bit values

class StackError < StandardError ; end

class Stack
  MAX_VALUE = 0x7FFF

  def initialize
    @stack = []
  end

  def push(value)
    validate_value value
    @stack.push(value)
  end

  def pop
    raise StackError, 'empty stack' if @stack.empty?
    @stack.pop
  end

  def dump
    $stderr.print "STACK(#{@stack.size}): "
    @stack.each{|sv| $stderr.print "0x%04x " % [sv] }
    $stderr.puts ""
  end

protected

  def validate_value(value)
    raise StackError, 'negative value' if value < 0x0
    raise StackError, 'value overflow' if value > MAX_VALUE
  end
end
