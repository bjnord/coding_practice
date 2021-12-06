defmodule Lanternfish do
  @moduledoc """
  Documentation for Lanternfish.
  """

  import Lanternfish.Parser
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
    |> generate(80, opts)
    |> Enum.count()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Simulate lanternfish generation with starting list `fish`.
  (Each `fish` is an integer timer value which ticks down from 8 to 0.)

  Returns final list of `fish` after `days` days of generation.
  """
  def generate(fish, days, opts \\ []), do: generate(fish, days, 0, opts)
  def generate(fish, days, day, opts) do
    if opts[:verbose] && (day <= 18) do
      IO.puts "#{label(day)}#{Enum.join(fish, ",")}"
    end
    if day < days do
      {fish, gen_fish} =
        fish
        |> Enum.reduce({[], []}, fn (f, {fish, gen_fish}) ->
          new_f = next_timer(f)
          new_fish = [new_f | fish]
          new_gen_fish = if f == 0, do: [8 | gen_fish], else: gen_fish
          {new_fish, new_gen_fish}
        end)
      new_fish = gen_fish ++ fish
                 |> Enum.reverse()
      generate(new_fish, days, day + 1, opts)
    else
      fish
    end
  end
  defp next_timer(f) do
    case f do
      0 -> 6
      n -> n - 1
    end
  end
  defp label(day) do
    case day do
      0 -> "Initial state: "
      1 -> "After  1 day:  "
      _ -> "After #{Integer.to_string(day) |> String.pad_leading(2)} days: "
    end
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file, opts \\ []) do
    input_file
    |> parse_input(opts)
    |> generate(256, opts)
    |> Enum.count()
    |> IO.inspect(label: "Part 2 answer is")
  end
end
