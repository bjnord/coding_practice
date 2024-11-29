defmodule Runes do
  @moduledoc """
  Documentation for `Runes`.
  """

  import Kingdom.CLI
  import Runes.Artifact
  import Runes.Parser

  defp solve(1) do
    parse_input_file(1)
    |> word_row_count(0)
  end

  defp solve(2) do
    artifact = parse_input_file(2)
    0..(artifact.height - 1)
    |> Enum.map(&(rune_row_matches(artifact, &1)))
    |> List.flatten()
    |> Enum.count()
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
