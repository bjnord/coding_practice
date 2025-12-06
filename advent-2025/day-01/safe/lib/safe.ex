defmodule Safe do
  @moduledoc """
  Documentation for `Safe`.
  """

  import Decor.CLI
  import Safe.Parser

  @opaque streamable(t) :: list(t) | Enum.t() | Enumerable.t()
  @type rotation() :: {String.t(), integer()}
  @type position() :: {String.t(), integer(), non_neg_integer(), non_neg_integer()}

  @doc """
  Rotate the dial.
  """
  @spec rotate(streamable([rotation()])) :: [position()]
  def rotate(rotations) do
    rotations
    |> Enum.reduce({50, []}, fn {rot_s, rot_i}, {pos, acc} ->
      {new_pos, clicks} = pos_and_clicks(pos, rot_i)
      {
        new_pos,
        [{rot_s, rot_i, new_pos, clicks} | acc]
      }
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  @doc """
  Update dial position and calculate number of clicks.
  """
  @spec pos_and_clicks(integer(), integer()) :: {integer(), non_neg_integer()}
  def pos_and_clicks(pos, rot_i) when rot_i > 0 do
    clicks = div(rot_i, 100)
    rot_i = rem(rot_i, 100)
    if (pos + rot_i) >= 100 do
      {rem(pos + rot_i, 100), clicks + 1}
    else
      {pos + rot_i, clicks}
    end
  end
  def pos_and_clicks(pos, rot_i) when rot_i < 0 do
    clicks = div(-rot_i, 100)
    rot_i = -rem(-rot_i, 100)
    if (pos + rot_i) <= 0 do
      if pos == 0 do
        {rem(pos + rot_i + 100, 100), clicks}
      else
        {rem(pos + rot_i + 100, 100), clicks + 1}
      end
    else
      {pos + rot_i, clicks}
    end
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
    |> rotate()
    |> Enum.map(fn pos -> elem(pos, 3) end)
    |> Enum.sum()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
