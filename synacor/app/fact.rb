# <https://harfangk.github.io/2017/01/01/how-to-enable-tail-call-recursion-in-ruby.html>

class Fact
  def self.iterator(n)
    (1..n).reduce(:*)
  end

  def self.non_tail_recursive(n)
    1 if n <= 1
    n * non_tail_recursive(n - 1)
  end

  def self.tail_recursive(n, acc = 1)
    return acc if n <= 1
    tail_recursive(n - 1, acc * n)
  end
end
