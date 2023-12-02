defmodule Syntax do
  @moduledoc """
  Documentation for Syntax.
  """

  import Syntax.Parser
  import Submarine.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2), do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    |> Stream.map(&Syntax.entry_status/1)
    |> Stream.filter(fn {status, _chars} -> status == :corrupted end)
    |> Stream.map(&Syntax.entry_score/1)
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Determine status of navigation entry.

  Returns `{status, remaining_charlist}` where `status` is one of:
  - `:ok` - valid line
  - `:corrupted` - corrupted line
  - `:incomplete` - incomplete line

  ## Examples
      iex> Syntax.entry_status('<([{}])>')
      {:ok, ''}
      iex> Syntax.entry_status('((()})')
      {:corrupted, '})'}
      iex> Syntax.entry_status('<([{}]')
      {:incomplete, '(<'}
  """
  def entry_status([first | rem_charlist]), do: entry_status([first | rem_charlist], [])
  def entry_status([], []), do: {:ok, []}
  def entry_status([], openers), do: {:incomplete, openers}
  def entry_status([next | rem_charlist], openers) do
    [opener | rem_openers] =
      if openers == [] do
        [nil]
      else
        openers
      end
    case next do
      ?( -> entry_status(rem_charlist, [next | openers])
      ?[ -> entry_status(rem_charlist, [next | openers])
      ?{ -> entry_status(rem_charlist, [next | openers])
      ?< -> entry_status(rem_charlist, [next | openers])
      ?) when opener == ?( -> entry_status(rem_charlist, rem_openers)
      ?] when opener == ?[ -> entry_status(rem_charlist, rem_openers)
      ?} when opener == ?{ -> entry_status(rem_charlist, rem_openers)
      ?> when opener == ?< -> entry_status(rem_charlist, rem_openers)
      ?) -> {:corrupted, [next | rem_charlist]}
      ?] -> {:corrupted, [next | rem_charlist]}
      ?} -> {:corrupted, [next | rem_charlist]}
      ?> -> {:corrupted, [next | rem_charlist]}
    end
  end

  @doc """
  Calculate score of navigation entry.

  ## Examples
      iex> Syntax.entry_score({:corrupted, '})'})
      1197
      iex> Syntax.entry_score({:completion, '])}>'})
      294
  """
  def entry_score({:corrupted, [next | _rem_charlist]}) do
    case next do
      ?) -> 3
      ?] -> 57
      ?} -> 1197
      ?> -> 25137
    end
  end
  def entry_score({:completion, closers}), do: completion_entry_score(closers, 0)
  defp completion_entry_score([closer], score), do: 5*score + char_score(closer)
  defp completion_entry_score([closer | rem_closers], score) do
    completion_entry_score(rem_closers, 5*score + char_score(closer))
  end
  defp char_score(char) do
    case char do
      ?) -> 1
      ?] -> 2
      ?} -> 3
      ?> -> 4
    end
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    |> Stream.map(&Syntax.entry_status/1)
    |> Stream.filter(fn {status, _chars} -> status == :incomplete end)
    |> Stream.map(&Syntax.entry_completion/1)
    |> Stream.map(&Syntax.entry_score/1)
    |> middle_score()
    |> IO.inspect(label: "Part 2 answer is")
  end
  def middle_score(scores) do
    Enum.sort(scores)
    |> (fn sorted_scores -> Enum.at(sorted_scores, div(length(sorted_scores), 2)) end).()
  end

  @doc """
  Find completion of incomplete navigation entry.

  ## Examples
      iex> Syntax.entry_completion({:incomplete, '(<'})
      {:completion, ')>'}
  """
  def entry_completion({:incomplete, openers}), do: entry_completion(openers, [])
  def entry_completion([], closers), do: {:completion, Enum.reverse(closers)}
  def entry_completion([opener | rem_openers], closers) do
    case opener do
      ?( -> entry_completion(rem_openers, [?) | closers])
      ?[ -> entry_completion(rem_openers, [?] | closers])
      ?{ -> entry_completion(rem_openers, [?} | closers])
      ?< -> entry_completion(rem_openers, [?> | closers])
    end
  end
end
