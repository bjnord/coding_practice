defmodule History.Math do
  @moduledoc """
  Math functions for `History`.
  """

  @type coord_2d() :: {integer(), integer()}
  @type coord_3d() :: {integer(), integer(), integer()}

  @doc """
  Compute the Manhattan distance between two positions.

  The positions use integer coordinates.
  """
  @spec manhattan(coord_2d(), coord_2d()) :: integer()
  def manhattan({y1, x1}, {y2, x2}) do
    abs(y1 - y2) + abs(x1 - x2)
  end
  @spec manhattan(coord_3d(), coord_3d()) :: integer()
  def manhattan({z1, y1, x1}, {z2, y2, x2}) do
    abs(z1 - z2) + abs(y1 - y2) + abs(x1 - x2)
  end

  @doc """
  Perform modulo division where the dividend (numerator) can be less
  than 0.

  This is the **mathematical definition** of modulo. It differs from the
  usual `%` or `mod` operator in computer systems, which produce negative
  values for a negative dividend (numerator).

  From this [Geeks for Geeks article](https://www.geeksforgeeks.org/modulus-on-negative-numbers/):

  > A remainder is the **least positive integer** that should be subtracted
  > from `a` to make it divisible by `b` (mathematically, if `a = q*b + r`
  > then `0 <= r < |b|`), where `a` is the dividend (numerator), `b` is the
  > divisor, `q` is the quotient, and `r` is the remainder.

  ## Table
  ```
  x            : -9 -8 -7 -6 -5 -4 -3 -2 -1  0  1  2  3  4  5  6  7  8  9
  f(x) in math :  3  0  1  2  3  0  1  2  3  0  1  2  3  0  1  2  3  0  1
  ```

  ## Examples
      iex> History.Math.modulo(7, 5)
      2
      iex> History.Math.modulo(-7, 5)
      3
  """
  @spec modulo(integer(), integer()) :: integer()
  def modulo(n, m) when n > 0 and m > 0, do: rem(n, m)
  def modulo(n, m) when n < 0 and m > 0, do: rem(rem(n, m) + m, m)
  def modulo(0, m) when m > 0, do: 0

  @doc """
  Return unique pairings from a list.

  (Someday this should be generalized permutation and combination
  functions.)
  """
  def pairings([]), do: []
  def pairings([_]), do: []
  def pairings([h | t]) do
    Enum.map(t, &({h, &1})) ++ pairings(t)
  end

  @doc """
  Count the number of digits in a non-negative integer.

  This can be done efficiently, without converting to strings, using
  base-10 logarithm.

  h/t [this Reddit comment by user ClimberSeb](https://www.reddit.com/r/adventofcode/s/cjeWV3D8yq)

  ## Examples
      iex> History.Math.n_digits(2024)
      4
  """
  @spec n_digits(non_neg_integer()) :: pos_integer()
  def n_digits(n) when is_integer(n) and n < 0 do
    raise "negative numbers not supported"
  end
  def n_digits(n) when is_integer(n) do
    :math.log10(n)
    |> :math.floor()
    |> then(&(round(&1) + 1))
  end
end
