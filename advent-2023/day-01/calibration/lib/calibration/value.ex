defmodule Calibration.Value do
  @moduledoc """
  Value calculation for `Calibration`.
  """

  @doc """
  Calculate calibration value (part 1 rules).

  ## Examples

      iex> Calibration.Value.naïve_value('ab1c2de')
      12
      iex> Calibration.Value.naïve_value('two4six8ten')
      48
  """
  def naïve_value(chars) do
    first = chars |> Enum.find(fn (ch) -> (ch >= ?0) && (ch <= ?9) end)
    last = chars |> Enum.reverse() |> Enum.find(fn (ch) -> (ch >= ?0) && (ch <= ?9) end)
    ((first - ?0) * 10) + (last - ?0)
  end
end
