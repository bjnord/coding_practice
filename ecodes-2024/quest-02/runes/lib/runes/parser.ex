defmodule Runes.Parser do
  @moduledoc """
  Runes map parser functions.
  """

  @doc ~S"""
  Parse the input from a file.

  Returns a tuple containing:
  - the runic words (list of `String`)
  - the inscription text (`String`)
  """
  def parse_input_file(f, opts \\ []) when is_number(f) do
    "private/everybody_codes_e2024_q02_p#{f}.txt"
    |> File.read!()
    |> parse_input_string(opts)
  end

  @doc ~S"""
  Parse the input from a string.

  Returns a tuple containing:
  - the runic words (list of `String`)
  - the inscription text (`String`)
  """
  def parse_input_string(input, opts \\ []) do
    [words_line, inscription] =
      input
      |> String.split("\n\n", trim: true)
    words =
      words_line
      |> parse_words_line(opts)
    {words, String.trim_trailing(inscription)}
  end

  @doc ~S"""
  Parse an input line containing a list of runic words.

  Returns the runic words (list of `String`).
  """
  def parse_words_line(line, _opts \\ []) do
    line
    |> String.trim_trailing()
    |> String.replace("WORDS:", "")
    |> String.split(",")
  end
end
