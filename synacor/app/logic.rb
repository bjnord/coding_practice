# Arithmetic and logic

# Details from architecture spec:
# - all numbers are unsigned integers 0..32767 (15-bit)
# - all math is modulo 32768; 32758 + 15 => 5

class Logic
  def self.eq(b, c)
    (b == c) ? 1 : 0
  end

  def self.gt(b, c)
    (b > c) ? 1 : 0
  end

  def self.add(b, c)
    (b + c) & 0x7fff
  end

  def self.and(b, c)
    (b & 0x7fff) & c
  end

  def self.or(b, c)
    (b & 0x7fff) | (c & 0x7fff)
  end

  def self.not(b)
    ~b & 0x7fff
  end
end
