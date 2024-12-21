defmodule Keypad do
  @moduledoc """
  Documentation for `Keypad`.
  """

  import Keypad.Parser
  import History.CLI

  def code_sequences(codes) do
    codes
    |> Enum.reduce({{?A, ?A, ?A}, []}, fn code, {positions, sequences} ->
      {positions, sequence} = code_sequence(positions, code)
      {positions, [sequence | sequences]}
      #|> IO.inspect(label: "reduce")
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  defp code_sequence({vac_pos, rad_pos, cold_pos}, buttons) do
    #buttons
    #|> IO.inspect(label: "code")
    if vac_pos != ?A do
      raise "vacuum not starting from A"
    end
    {vac_pos, vac_motions} =
      buttons
      |> Enum.reduce({vac_pos, []}, fn to, {from, acc} ->
        Keypad.Numeric.motions({from, to})
        |> then(&({to, acc ++ &1 ++ [?A]}))
      end)
      #|> IO.inspect(label: "vacuum")
    if rad_pos != ?A do
      raise "radiation not starting from A"
    end
    {rad_pos, rad_motions} =
      vac_motions
      |> Enum.reduce({rad_pos, []}, fn to, {from, acc} ->
        Keypad.Directional.motions({from, to})
        |> then(&({to, acc ++ &1 ++ [?A]}))
      end)
      #|> IO.inspect(label: "radiation")
    if cold_pos != ?A do
      raise "cold not starting from A"
    end
    {cold_pos, cold_motions} =
      rad_motions
      |> Enum.reduce({cold_pos, []}, fn to, {from, acc} ->
        #{List.to_string([from]), List.to_string([to]), acc}
        #|> IO.inspect(label: "from, to, acc")
        Keypad.Directional.motions({from, to})
        |> then(&({to, acc ++ &1 ++ [?A]}))
        #|> dbg()
      end)
      #|> IO.inspect(label: "cold")
    {{vac_pos, rad_pos, cold_pos}, cold_motions}
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
