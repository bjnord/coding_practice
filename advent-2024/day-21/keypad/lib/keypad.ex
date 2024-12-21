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

  defp code_sequence(moves) do
    #moves
    #|> IO.inspect(label: "code")
    vac_perms =
      moves
      |> Enum.reduce({?A, [~c""]}, fn to, {from, from_perms} ->
        #{from, to, from_perms}
        #|> IO.inspect(label: "from, to, from_perms")
        perms =
          Keypad.Numeric.move_permutations({from, to})
          |> Enum.flat_map(fn to_perm ->
            next_robot(to_perm ++ [?A], 2)
          end)
          |> Enum.flat_map(fn deep_perm ->
            #{deep_perm, from_perms}
            #|> IO.inspect(label: "deep_perm, from_perms")
            from_perms
            |> Enum.map(&(&1 ++ deep_perm))
            #|> dbg()
          end)
          #|> dbg()
        {to, perms}
        #|> IO.inspect(label: "code reduce")
      end)
      |> elem(1)
      #|> IO.inspect(label: "vacuum perms")
    vac_perms
    |> Enum.min_by(&Enum.count/1)
    #|> IO.inspect(label: "vacuum min perm")
  end

  defp next_robot(moves, 0), do: [moves]
  defp next_robot(moves, level) do
    #moves
    #|> IO.inspect(label: "robot[#{level}] moves")
    moves
    |> Enum.reduce({?A, [~c""]}, fn to, {from, from_perms} ->
      #{from, to, from_perms}
      #|> IO.inspect(label: "R from, to, from_perms")
      perms =
        Keypad.Directional.move_permutations({from, to})
        |> Enum.flat_map(fn to_perm ->
          next_robot(to_perm ++ [?A], level - 1)
        end)
        |> Enum.flat_map(fn deep_perm ->
          #{deep_perm, from_perms}
          #|> IO.inspect(label: "R deep_perm, from_perms")
          from_perms
          |> Enum.map(&(&1 ++ deep_perm))
          #|> dbg()
        end)
        #|> dbg()
      {to, perms}
      #|> IO.inspect(label: "R reduce")
    end)
    |> elem(1)
    #|> IO.inspect(label: "robot[#{level}] perms")
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
