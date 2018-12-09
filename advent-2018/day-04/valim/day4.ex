# Puzzle: https://adventofcode.com/2018/day/4
# Stream: https://www.twitch.tv/videos/344946932
defmodule FrequencyMap do
  defstruct data: %{}

  def new do
    %FrequencyMap{}
  end

  def most_frequent(%FrequencyMap{data: data}) do
    if data != %{} do
      Enum.max_by(data, fn {_, count} -> count end)
    else
      :error
    end
  end

  defimpl Collectable do
    def into(%FrequencyMap{data: data}) do
      collector_fun = fn
        data, {:cont, elem} -> Map.update(data, elem, 1, &(&1 + 1))
        data, :done -> %FrequencyMap{data: data}
        _, :halt -> :ok
      end

      {data, collector_fun}
    end
  end
end

defmodule Day4 do
  import NimbleParsec

  guard_command =
    ignore(string("Guard #"))
    |> integer(2)
    |> ignore(string(" begins shift"))
    |> unwrap_and_tag(:shift)

  asleep_command = string("falls asleep") |> replace(:down)

  wakeup_command = string("wakes up") |> replace(:up)

  defparsecp :parsec_log,
             ignore(string("["))
             |> integer(4)
             |> ignore(string("-"))
             |> integer(2)
             |> ignore(string("-"))
             |> integer(2)
             |> ignore(string(" "))
             |> integer(2)
             |> ignore(string(":"))
             |> integer(2)
             |> ignore(string("] "))
             |> choice([guard_command, asleep_command, wakeup_command])

  @doc """
  Parses the log.

      iex> Day4.parse_log("[1518-09-09 00:04] Guard #1543 begins shift")
      {{1518, 09, 09}, 00, 04, {:shift, 1543}}

      iex> Day4.parse_log("[1518-09-12 00:54] falls asleep")
      {{1518, 09, 12}, 00, 54, :down}

      iex> Day4.parse_log("[1518-06-06 00:25] wakes up")
      {{1518, 06, 06}, 00, 25, :up}

  """
  def parse_log(string) when is_binary(string) do
    {:ok, [year, month, day, hour, minute, id], "", _, _, _} = parsec_log(string)
    {{year, month, day}, hour, minute, id}
  end

  @doc """
  Groups unsorted log entries by id and date with asleep time as ranges.

      iex> Day4.group_by_id_and_date([
      ...>   "[1518-11-03 00:29] wakes up",
      ...>   "[1518-11-03 00:24] falls asleep",
      ...>   "[1518-11-04 00:46] wakes up",
      ...>   "[1518-11-05 00:03] Guard #99 begins shift",
      ...>   "[1518-11-05 00:55] wakes up",
      ...>   "[1518-11-04 00:02] Guard #99 begins shift",
      ...>   "[1518-11-03 00:05] Guard #10 begins shift",
      ...>   "[1518-11-02 00:40] falls asleep",
      ...>   "[1518-11-01 00:05] falls asleep",
      ...>   "[1518-11-05 00:45] falls asleep",
      ...>   "[1518-11-01 00:25] wakes up",
      ...>   "[1518-11-01 00:00] Guard #10 begins shift",
      ...>   "[1518-11-01 00:55] wakes up",
      ...>   "[1518-11-01 00:30] falls asleep",
      ...>   "[1518-11-04 00:36] falls asleep",
      ...>   "[1518-11-01 23:58] Guard #99 begins shift",
      ...>   "[1518-11-02 00:50] wakes up"
      ...> ])
      [
        {10, {1518, 11, 1}, [5..24, 30..54]},
        {99, {1518, 11, 1}, [40..49]},
        {10, {1518, 11, 3}, [24..28]},
        {99, {1518, 11, 4}, [36..45]},
        {99, {1518, 11, 5}, [45..54]}
      ]

  """
  def group_by_id_and_date(unsorted_logs_as_strings) do
    unsorted_logs_as_strings
    |> Enum.map(&parse_log/1)
    |> Enum.sort()
    |> group_by_id_and_date([])
  end

  defp group_by_id_and_date([{date, _hour, _minute, {:shift, id}} | rest], groups) do
    {rest, ranges} = get_asleep_ranges(rest, [])
    group_by_id_and_date(rest, [{id, date, ranges} | groups])
  end

  defp group_by_id_and_date([], groups) do
    Enum.reverse(groups)
  end

  defp get_asleep_ranges([{_, _, down_minute, :down}, {_, _, up_minute, :up} | rest], ranges) do
    get_asleep_ranges(rest, [down_minute..(up_minute - 1) | ranges])
  end

  defp get_asleep_ranges(rest, ranges) do
    {rest, Enum.reverse(ranges)}
  end

  @doc """
  Sums the asleep times from the grouped entries.

      iex> Day4.sum_asleep_times_by_id([
      ...>   {10, {1518, 11, 1}, [5..24, 30..54]},
      ...>   {99, {1518, 11, 1}, [40..49]},
      ...>   {10, {1518, 11, 3}, [24..28]},
      ...>   {99, {1518, 11, 4}, [36..45]},
      ...>   {99, {1518, 11, 5}, [45..54]}
      ...> ])
      %{
        99 => 30,
        10 => 50,
      }

  """
  def sum_asleep_times_by_id(grouped_entries) do
    Enum.reduce(grouped_entries, %{}, fn {id, _date, ranges}, acc ->
      time_asleep = ranges |> Enum.map(&Enum.count/1) |> Enum.sum()
      Map.update(acc, id, time_asleep, &(&1 + time_asleep))
    end)
  end

  @doc """
  Gets the id that is asleep the most.

      iex> Day4.id_asleep_the_most(%{99 => 30, 10 => 50})
      10

  """
  def id_asleep_the_most(map) do
    {id, _} = Enum.max_by(map, fn {_, time_asleep} -> time_asleep end)
    id
  end

  @doc """
  Gets the id that is asleep the most.

      iex> Day4.minute_asleep_the_most([
      ...>   {10, {1518, 11, 1}, [5..24, 30..54]},
      ...>   {99, {1518, 11, 1}, [40..49]},
      ...>   {10, {1518, 11, 3}, [24..28]},
      ...>   {99, {1518, 11, 4}, [36..45]},
      ...>   {99, {1518, 11, 5}, [45..54]}
      ...> ])
      {99, 45}

  """
  def minute_asleep_the_most(grouped_entries) do
    {current_id, current_minute, _, _} =
      Enum.reduce(grouped_entries, {0, 0, 0, MapSet.new()}, fn {id, _, _}, acc ->
        {current_id, current_minute, current_count, seen_ids} = acc

        if id in seen_ids do
          acc
        else
          case minute_asleep_the_most_by_id(grouped_entries, id) do
            {minute, count} when count > current_count ->
              {id, minute, count, MapSet.put(seen_ids, id)}

            _ ->
              {current_id, current_minute, current_count, MapSet.put(seen_ids, id)}
          end
        end
      end)

    {current_id, current_minute}
  end

  @doc """
  Gets the id that is asleep the most.

      iex> Day4.minute_asleep_the_most_by_id([
      ...>   {10, {1518, 11, 1}, [5..24, 30..54]},
      ...>   {99, {1518, 11, 1}, [40..49]},
      ...>   {10, {1518, 11, 3}, [24..28]},
      ...>   {99, {1518, 11, 4}, [36..45]},
      ...>   {99, {1518, 11, 5}, [45..54]}
      ...> ], 10)
      {24, 2}

      iex> Day4.minute_asleep_the_most_by_id([
      ...>   {10, {1518, 11, 1}, []},
      ...> ], 10)
      :error

  """
  def minute_asleep_the_most_by_id(grouped_entries, id) do
    frequency_map =
      for {^id, _, ranges} <- grouped_entries,
          range <- ranges,
          minute <- range,
          do: minute,
          into: FrequencyMap.new()

    FrequencyMap.most_frequent(frequency_map)
  end

  @doc """
  Entry point for part 1.
  """
  def part1(input) do
    grouped_entries = group_by_id_and_date_on_input(input)

    id_asleep_the_most =
      grouped_entries
      |> sum_asleep_times_by_id()
      |> id_asleep_the_most()

    {minute_asleep_the_most, _times} =
      minute_asleep_the_most_by_id(grouped_entries, id_asleep_the_most)

    id_asleep_the_most * minute_asleep_the_most
  end

  @doc """
  Entry point for part 2.
  """
  def part2(input) do
    {id, minute} =
      input
      |> group_by_id_and_date_on_input()
      |> minute_asleep_the_most()

    id * minute
  end

  defp group_by_id_and_date_on_input(input) do
    input
    |> File.read!()
    |> String.split("\n", trim: true)
    |> group_by_id_and_date()
  end
end
