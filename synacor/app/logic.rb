# Arithmetic and logic

# Details from architecture spec:
# - all numbers are unsigned integers 0..32767 (15-bit)
# - all math is modulo 32768; 32758 + 15 => 5

class Logic
  def self.add(b, c)
    (b + c) & 0x7fff
  end
end
