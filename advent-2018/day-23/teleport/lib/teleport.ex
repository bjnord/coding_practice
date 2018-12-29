defmodule Teleport do
  @moduledoc """
  Documentation for Teleport.
  """

  import Nanobot
  import Teleport.CLI

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

  - Part 1 answer is: 613
  """
  def part1(input_file, opts \\ []) do
    bots =
      input_file
      |> parse_input(opts)
    {max_bot_pos, max_bot_r} =
      bots
      |> Enum.max_by(fn ({_pos, r}) -> r end)
    bots_in_range =
      bots
      |> Enum.filter(fn ({pos, _r}) ->
        manhattan(max_bot_pos, pos) <= max_bot_r
      end)
      |> Enum.count
    IO.inspect(bots_in_range, label: "Part 1 nanobots in range is")
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 Python answer (613 bots in range) is: 101599540
  - Part 2 answer is: ...
  """
  def part2(input_file, opts \\ []) do
    {closest_point, count} =
      input_file
      |> parse_input(opts)
      |> find_closest_point()
      #|> IO.inspect(label: "closest point, count")
    manhattan(closest_point, {0, 0, 0})
    |> IO.inspect(label: "Part 2 distance to closest point (bots=#{count}) is")
  end

  defp find_closest_point(bots) do
    initial_entry = encompassing_space(bots)
                    |> entry_for_space(bots)
                    #|> IO.inspect(label: "initial entry")
    initial_pqueue = Teleport.PriorityQueue.new([initial_entry])
    {{x..x, y..y, z..z}, count} =
      Stream.cycle([true])
      |> Enum.reduce_while(initial_pqueue, fn (_t, pqueue) ->
        {pqueue, {{count, _distance, size}, space}} =
          Teleport.PriorityQueue.pop(pqueue)
        #IO.inspect({{count, distance, size}, space}, label: "head entry")
        if size == 1 do
          {:halt, {space, -count}}
        else
          new_entries = split_space_to_entries(space, bots)
                        #|> IO.inspect(label: "new entries")
          {:cont, Teleport.PriorityQueue.add(pqueue, new_entries)}
        end
      end)
      #|> IO.inspect(label: "final entry (size=1)")
    {{x, y, z}, count}
  end

  defp entry_for_space(space, bots) do
    {{-in_range_count(bots, space), space_distance_to_0(space), space_size(space)}, space}
  end

  defp split_space_to_entries(space, bots) do
    space_partitions(space)
    |> Enum.map(fn (part) -> entry_for_space(part, bots) end)
  end
end
