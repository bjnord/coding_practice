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
      any_word_match?(artifact, y, x)
    end
    |> Enum.count(&(&1))
  end

  @spec any_word_match?(__MODULE__.t(), integer(), integer()) :: boolean()
  defp any_word_match?(artifact, y, x) do
    artifact.words
    |> Enum.any?(&(word_match?(artifact, &1, y, x)))
  end

  @spec word_match?(__MODULE__.t(), charlist(), integer(), integer()) :: boolean()
  defp word_match?(artifact, word, y, x) do
    word
    |> Enum.with_index()
    |> Enum.all?(fn {ch, i} ->
      artifact.grid[{y, x + i}] == ch
    end)
  end

  @spec rune_row_matches(__MODULE__.t(), integer()) :: [{integer(), integer()}]
  def rune_row_matches(artifact, y) do
    for x <- 0..(Enum.at(artifact.widths, y) - 1),
        word <- artifact.words do
          cond do
            word_match?(artifact, word, y, x) ->
              x..(x + length(word) - 1)
              |> Enum.map(&({y, &1}))
            word_match?(artifact, Enum.reverse(word), y, x) ->
              x..(x + length(word) - 1)
              |> Enum.map(&({y, &1}))
            true ->
              []
          end
    end
    |> List.flatten()
    |> Enum.uniq()
  end
end
