defmodule Runes.Parser do
  @moduledoc """
  Runes map parser functions.
  """

  @type option() :: {:debug, boolean()}

  @doc ~S"""
  Parse the input from a file.

  ## Parameters

  - `f`: the puzzle input file descriptor (part number or filename)
  - `opts`: the parsing options

  Returns a tuple containing:
  - the runic words (sorted longest first)
  - the inscription texts
  """
  @spec parse_input_file(pos_integer() | String.t(), [option()]) :: {[charlist()], [charlist()]}
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

  Returns a tuple containing:
  - the runic words (sorted longest first)
  - the inscription texts
  """
  @spec parse_input_string(String.t(), [option()]) :: {[charlist()], [charlist()]}
  def parse_input_string(input, opts \\ []) do
    [words_line, inscription_lines] =
      input
      |> String.split("\n\n", trim: true)
    words =
      words_line
      |> parse_words_line(opts)
    inscriptions =
      inscription_lines
      |> String.split("\n", trim: true)
      |> Enum.map(&to_charlist/1)
    {words, inscriptions}
  end

  @spec parse_words_line(String.t(), [option()]) :: [charlist()]
  defp parse_words_line(line, _opts) do
    line
    |> String.trim_trailing()
    |> String.replace("WORDS:", "")
    |> String.split(",")
    |> Enum.map(&to_charlist/1)
    |> Enum.sort(&length_sorter/2)
  end

  # sorts rune words longest-to-shortest
  defp length_sorter(a, b) do
    cond do
      length(a) > length(b) -> true
      length(a) < length(b) -> false
      true                  -> alpha_sorter(a, b)
    end
  end

  # sorts equal-length rune words alphabetically
  defp alpha_sorter([], []), do: true
  defp alpha_sorter(a, b) do
    cond do
      hd(a) < hd(b) -> true
      hd(a) > hd(b) -> false
      true          -> alpha_sorter(tl(a), tl(b))
    end
  end
end
