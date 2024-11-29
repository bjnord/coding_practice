defmodule Runes.Artifact do
  @moduledoc """
  Runes artifact functions.
  """

  defstruct words: [], height: 0, widths: [], grid: %{}

  @type t :: %__MODULE__{
    words: [charlist()],
    height: integer(),
    widths: [integer()],
    grid: %{{integer(), integer()} => char()}
  }

  @spec word_row_count(__MODULE__.t(), integer()) :: integer()
  def word_row_count(artifact, y) do
    for x <- 0..(Enum.at(artifact.widths, y) - 1) do
      word_match?(artifact, y, x)
    end
    |> Enum.count(&(&1))
  end

  @spec word_match?(__MODULE__.t(), integer(), integer()) :: boolean()
  defp word_match?(artifact, y, x) do
    artifact.words
    |> Enum.any?(fn word ->
      word
      |> Enum.with_index()
      |> Enum.all?(fn {ch, i} ->
        artifact.grid[{y, x + i}] == ch
      end)
    end)
  end
end
