defmodule Runes.Parser do
  @moduledoc """
  Runes parser functions.
  """

  alias Runes.Artifact

  @type option() :: {:debug, boolean()}

  @doc ~S"""
  Parse the input from a file.

  ## Parameters

  - `f`: the puzzle input file descriptor (part number or filename)
  - `opts`: the parsing options

  Returns an `Artifact`.
  """
  @spec parse_input_file(pos_integer() | String.t(), [option()]) :: Artifact.t()
  def parse_input_file(f, opts \\ [])
  def parse_input_file(f, opts) when is_integer(f) do
    "private/everybody_codes_e2024_q02_p#{f}.txt"
    |> File.read!()
    |> parse_input_string(opts)
  end
  def parse_input_file(f, opts) do
    File.read!(f)
    |> parse_input_string(opts)
  end

  @doc ~S"""
  Parse the input from a string.

  ## Parameters

  - `input`: the puzzle input
  - `opts`: the parsing options

  Returns an `Artifact`.
  """
  @spec parse_input_string(String.t(), [option()]) :: Artifact.t()
  def parse_input_string(input, opts \\ []) do
    [words_line, inscription_lines] =
      input
      |> String.split("\n\n", trim: true)
    words =
      words_line
      |> parse_words_line(opts)
    widths =
      inscription_lines
      |> String.split("\n", trim: true)
      |> Enum.map(&(String.length(&1)))
    grid =
      inscription_lines
      |> parse_inscription_lines(opts)
    %Artifact{words: words, height: length(widths), widths: widths, grid: grid}
  end

  @spec parse_words_line(String.t(), [option()]) :: [charlist()]
  defp parse_words_line(line, _opts) do
    line
    |> String.trim_trailing()
    |> String.replace("WORDS:", "")
    |> String.split(",")
    |> Enum.map(&to_charlist/1)
  end

  @spec parse_inscription_lines(String.t(), [option()]) :: map()
  defp parse_inscription_lines(lines, _opts) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {line, y} ->
      to_charlist(line)
      |> Enum.with_index()
      |> Enum.map(fn {ch, x} -> {{y, x}, ch} end)
    end)
    |> List.flatten()
    |> Enum.into(%{})
  end
end
