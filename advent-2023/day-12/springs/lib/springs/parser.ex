defmodule Springs.Parser do
  @moduledoc """
  Parsing for `Springs`.
  """

  alias Springs.Row

  @doc ~S"""
  Parse the input file.

  Returns a list of `Row`s (one per line).
  """
  def parse_input(input_file, _opts \\ []) do
    input_file
    |> File.stream!
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a list of `Row`s (one per line).
  """
  def parse_input_string(input, _opts \\ []) do
    input
    |> String.splitter("\n", trim: true)
    |> Stream.map(&parse_line/1)
  end

  @doc ~S"""
  Parse an input line containing a row of springs and counts.

  Returns a `Row`.

  ## Examples
      iex> parse_line(".??..??...?##. 1,1,3\n")
      %Springs.Row{
        tokens: ['.', 2, '..', 2, '...', 1, '##.'],
        counts: [1, 1, 3],
      }
  """
  def parse_line(line) do
    [tokens_str, counts_str] =
      line
      |> String.trim_trailing()
      |> String.split()
    %Row{
      tokens: parse_tokens(tokens_str),
      counts: parse_counts(counts_str),
    }
  end

  defp parse_tokens(tokens_str) do
    {rtokens, last_q, last_rfixed} =
      tokens_str
      |> String.to_charlist()
      |> Enum.reduce({[], 0, ''}, fn ch, {rtokens, q, rfixed} ->
        if ch == ?? do
          {new_rtokens, new_rfixed} =
            if List.first(rfixed) do
              fixed = Enum.reverse(rfixed)
              {[fixed | rtokens], ''}  # switch from .# to ?
            else
              {rtokens, ''}
            end
          {new_rtokens, q + 1, new_rfixed}
        else
          {new_rtokens, new_q} =
            if q > 0 do
              {[q | rtokens], 0}  # switch from ? to .#
            else
              {rtokens, 0}
            end
          {new_rtokens, new_q, [ch | rfixed]}
        end
      end)
    if last_q > 0 do
      [last_q | rtokens]
    else
      last_fixed = Enum.reverse(last_rfixed)
      [last_fixed | rtokens]
    end
    |> Enum.reverse()
  end

  defp parse_counts(counts_str) do
    counts_str
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
end
