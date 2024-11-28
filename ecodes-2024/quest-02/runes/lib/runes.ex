defmodule Runes do
  @moduledoc """
  Documentation for `Runes`.
  """

  import Kingdom.CLI
  import Runes.Parser

  defp solve(1) do
    nil
  end

  defp solve(2) do
    nil
  end

  defp solve(3) do
    nil
  end

  def main(argv) do
    opts = parse_args(argv)
    opts[:parts]
    |> Enum.each(fn part ->
      solve(part)
      |> IO.inspect(label: "Part #{part}")
    end)
  end
end
