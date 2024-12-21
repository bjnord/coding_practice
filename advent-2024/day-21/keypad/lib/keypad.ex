defmodule Keypad do
  @moduledoc """
  Documentation for `Keypad`.
  """

  import Keypad.Parser
  import History.CLI

  def code_sequences(codes) do
    codes
    |> Enum.reduce([], fn code, sequences ->
      [code_sequence(code) | sequences]
      #|> IO.inspect(label: "reduce")
    end)
    |> Enum.reverse()
  end

  defp code_sequence(buttons) do
    #buttons
    #|> IO.inspect(label: "code")
    vac_moves =
      buttons
      |> Enum.reduce({?A, []}, fn to, {from, moves} ->
        Keypad.Numeric.move_permutations({from, to})
        |> Enum.map(&({to, moves ++ &1 ++ [?A]}))
        |> hd()  # FIXME
      end)
      |> elem(1)
      #|> IO.inspect(label: "vacuum")
    rad_moves =
      vac_moves
      |> Enum.reduce({?A, []}, fn to, {from, moves} ->
        Keypad.Directional.move_permutations({from, to})
        |> Enum.map(&({to, moves ++ &1 ++ [?A]}))
        |> hd()  # FIXME
      end)
      |> elem(1)
      #|> IO.inspect(label: "radiation")
    cold_moves =
      rad_moves
      |> Enum.reduce({?A, []}, fn to, {from, moves} ->
        #{List.to_string([from]), List.to_string([to]), moves}
        #|> IO.inspect(label: "from, to, moves")
        Keypad.Directional.move_permutations({from, to})
        |> Enum.map(&({to, moves ++ &1 ++ [?A]}))
        |> hd()  # FIXME
        #|> dbg()
      end)
      |> elem(1)
      #|> IO.inspect(label: "cold")
    cold_moves
  end

  def complexity(codes) do
    codes
    |> code_sequences()
    |> Enum.zip(codes)
    |> Enum.map(fn {sequence, code} -> complexity(code, sequence) end)
    |> Enum.sum()
  end

  defp complexity(code, sequence) do
    sequence
    |> Enum.count()
    |> then(&(&1 * numeric_part(code)))
  end

  defp numeric_part(code) do
    code
    |> Enum.slice(0..2)
    |> List.to_string()
    |> String.to_integer()
  end

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_path) do
    parse_input_file(input_path)
    |> Keypad.complexity()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
