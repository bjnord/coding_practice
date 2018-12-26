defmodule Immunity do
  @moduledoc """
  Documentation for Immunity.
  """

  import Immunity.CLI
  import Immunity.InputParser

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1),
      do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2),
      do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Correct Answer

  - Part 1 answer is: ...
  """
  def part1(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    "?"
    |> IO.inspect(label: "Part 1 winning army units is")
  end

  defp parse_input(input_file, _opts) do
    {:ok, input, _, _, {lines, chars}, parsed_chars} =
      input_file
      |> File.read!
      |> input()
    lines = lines - 1
    if parsed_chars != chars do
      raise "parser didn't consume all of #{input_file}"
    end
    IO.inspect({lines, chars}, label: "lines and characters parsed")
    IO.inspect(input, label: "the input")
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(input_file, _opts \\ []) do
    ans_type = "???"
    input_file
    |> IO.inspect(label: "Part 2 #{ans_type} is")
  end
end
