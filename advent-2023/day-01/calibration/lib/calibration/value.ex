defmodule Calibration.Value do
  @moduledoc """
  Value calculation for `Calibration`.
  """

  @doc """
  Calculate calibration value (part 1 rules).

  ## Examples

      iex> Calibration.Value.naïve_value('ab1c2de')
      12
      iex> Calibration.Value.naïve_value('two4six8nine')
      48
  """
  def naïve_value(chars) do
    first = chars |> Enum.find(fn (ch) -> (ch >= ?0) && (ch <= ?9) end)
    last = chars |> Enum.reverse() |> Enum.find(fn (ch) -> (ch >= ?0) && (ch <= ?9) end)
    ((first - ?0) * 10) + (last - ?0)
  end

  @doc """
  Calculate calibration value (part 2 rules).

  ## Examples

      iex> Calibration.Value.value('1two3four5')
      15
      iex> Calibration.Value.value('two4six8nine')
      29
      iex> Calibration.Value.value('xthree5seventeen')
      37
  """
  def value(chars) do
    first = chars |> first_digit()
    last = chars |> last_digit()
    (first * 10) + last
  end

  @doc """
  Find first digit (literal or name).

  ## Examples

      iex> Calibration.Value.first_digit('1two3four5')
      1
      iex> Calibration.Value.first_digit('two4six8nine')
      2
      iex> Calibration.Value.first_digit('xthree5seventeen')
      3
  """
  def first_digit([ch | _rem_chars]) when (ch >= ?0) and (ch <= ?9) do
    ch - ?0
  end
  def first_digit(chars) do
    cond do
      Enum.take(chars, 3) == 'one'   -> 1
      Enum.take(chars, 3) == 'two'   -> 2
      Enum.take(chars, 5) == 'three' -> 3
      Enum.take(chars, 4) == 'four'  -> 4
      Enum.take(chars, 4) == 'five'  -> 5
      Enum.take(chars, 3) == 'six'   -> 6
      Enum.take(chars, 5) == 'seven' -> 7
      Enum.take(chars, 5) == 'eight' -> 8
      Enum.take(chars, 4) == 'nine'  -> 9
      true                           ->
        [_ch | rem_chars] = chars
        first_digit(rem_chars)
    end
  end

  @doc """
  Find last digit (literal or name).

  ## Examples

      iex> Calibration.Value.last_digit('1two3four5')
      5
      iex> Calibration.Value.last_digit('two4six8nine')
      9
      iex> Calibration.Value.last_digit('xthree5seventeen')
      7
  """
  def last_digit(chars), do: last_rdigit(Enum.reverse(chars))
  defp last_rdigit([ch | _rem_rchars]) when (ch >= ?0) and (ch <= ?9) do
    ch - ?0
  end
  defp last_rdigit(rchars) do
    cond do
      Enum.take(rchars, 3) == 'eno'   -> 1
      Enum.take(rchars, 3) == 'owt'   -> 2
      Enum.take(rchars, 5) == 'eerht' -> 3
      Enum.take(rchars, 4) == 'ruof'  -> 4
      Enum.take(rchars, 4) == 'evif'  -> 5
      Enum.take(rchars, 3) == 'xis'   -> 6
      Enum.take(rchars, 5) == 'neves' -> 7
      Enum.take(rchars, 5) == 'thgie' -> 8
      Enum.take(rchars, 4) == 'enin'  -> 9
      true                            ->
        [_ch | rem_rchars] = rchars
        last_rdigit(rem_rchars)
    end
  end
end
