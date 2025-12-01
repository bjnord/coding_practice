defmodule Safe do
  @moduledoc """
  Documentation for `Safe`.
  """

  import Safe.Parser
  import History.CLI

  @doc """
  Rotate the dial.
  """
  def rotate(rotations) do
    rotations
    |> Enum.reduce({50, []}, fn {rot_s, rot_i}, {pos, acc} ->
      new_pos = rem(pos + rot_i, 100)
      new_pos =
        cond do
          new_pos < 0 -> new_pos + 100
          true        -> new_pos
        end
      {
        new_pos,
        [{rot_s, rot_i, new_pos} | acc]
      }
    end)
    |> elem(1)
    |> Enum.reverse()
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
    |> rotate()
    |> Enum.count(fn pos -> elem(pos, 2) == 0 end)
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
