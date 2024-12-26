defmodule History.MathTest do
  use ExUnit.Case
  use PropCheck, default_opts: [numtests: 100]
  doctest History.Math

  alias History.TestSupport

  # no AoC year is complete without...:
  test "Manhattan distance (3D)" do
    pos1 = {1105, -1205, 1229}
    pos2 = {-92, -2380, -20}
    assert History.Math.manhattan(pos1, pos2) == 3621
  end
  test "Manhattan distance (2D)" do
    pos1 = {1105, -1205}
    pos2 = {-92, -2380}
    assert History.Math.manhattan(pos1, pos2) == 2372
  end

  ###
  # modulo function
  ###

  property "modulo is correct for non-negative and negative numerators" do
    forall {n, m} <- gen_numerator_divisor() do
      History.Math.modulo(n, m) == alt_modulo(n, m)
    end
  end

  # "A remainder is the least positive integer that should be subtracted
  # from a to make it divisible by b."
  def alt_modulo(a, b) do
    {a, b}
    0..(b - 1)
    |> Enum.find(&(divisible_by?(a - &1, b)))
  end

  defp divisible_by?(a, b) do
    rem(abs(a), b) == 0
  end

  def gen_numerator_divisor() do
    {oneof([non_neg_integer(), neg_integer()]), pos_integer()}
  end

  ###
  # pairings function
  ###

  test "pairings" do
    entries = [:a, :b, :c, :d]
    pairings = [
      {:a, :b}, {:a, :c}, {:a, :d},
      {:b, :c}, {:b, :d},
      {:c, :d}
    ]
    assert History.Math.pairings(entries) == pairings
    assert History.Math.pairings([:z]) == []
    assert History.Math.pairings([]) == []
  end

  ###
  # n_digits function
  ###

  property "n_digits is correct for non-negative integers" do
    forall n <- sized(s, resize(2 ** (s + 2), non_neg_integer())) do
      #collect(true, TestSupport.string_n_digits(n))
      History.Math.n_digits(n) == TestSupport.string_n_digits(n)
    end
  end
end
