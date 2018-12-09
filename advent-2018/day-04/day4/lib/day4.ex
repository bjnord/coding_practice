defmodule Day4 do
  @moduledoc """
  Documentation for Day4.
  """

  defp abort(message, excode) do
    IO.puts(:stderr, message)
    System.halt(excode)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 1 checksum is: 95199
  """
  def part1(argv) do
    times = argv
            |> input_file
            |> File.stream!
            |> sort_lines
            |> sleepy_times
    sleepiest_guard_id = times
                         |> total_minutes_asleep
                         |> Enum.max_by(fn ({_k, v}) -> v end)
                         |> elem(0)
    sleepiest_minute = times
                       |> sleep_minute_breakdown
                       |> Map.get(sleepiest_guard_id)
                       |> Enum.max_by(fn ({_k, v}) -> v end)
                       |> elem(0)
    IO.inspect(sleepiest_guard_id * sleepiest_minute, label: "Part 1 checksum is")
  end

  @doc """
  Process input file and display part 2 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 2 checksum is: 7887
  """
  def part2(argv) do
    times = argv
            |> input_file
            |> File.stream!
            |> sort_lines
            |> sleepy_times
    {sleepiest_guard_id, sleepiest_minute} = times
                                             |> sleep_minute_breakdown
                                             |> Enum.reduce(%{}, fn ({guard_id, breakdown}, acc) ->
                                                  {min, count} = Enum.max_by(breakdown, fn ({_k, v}) -> v end)
                                                  Map.put(acc, {guard_id, min}, count)
                                                end)
                                             |> Enum.max_by(fn ({_k, v}) -> v end)
                                             |> elem(0)
    IO.inspect(sleepiest_guard_id * sleepiest_minute, label: "Part 2 checksum is")
  end

  @doc """
  Get name of input file from command-line arguments.

  ## Parameters

  - argv: Command-line arguments

  ## Returns

  Input filename (or aborts if argv invalid)
  """
  def input_file(argv) do
    case argv do
      [filename] -> filename
      _          -> abort('Usage: day4 filename', 64)
    end
  end

  @doc """
  Chronologically sort input lines of the form:

  `[1518-11-01 23:58] Guard #99 begins shift`

  ## Parameters

  - lines: List of input lines (strings)

  ## Returns

  - List of chronologically-sorted input lines (strings)

  """
  def sort_lines(lines) do
    Enum.sort(lines)
  end

  @doc """
  Extract minute from timestamp of the form:

  `[1518-11-01 23:58] …`

  ## Parameters

  - line: Input line (string)

  ## Returns

  - Minute (integer)

  """
  def minute_of(line) do
    String.slice(line, 15..16)
    |> String.to_integer
  end

  @doc """
  Parse chronological lines in the following form to sleep/wake times:

  ```
  [1518-11-01 23:58] Guard #99 begins shift
  [1518-11-01 00:05] falls asleep
  [1518-11-01 00:25] wakes up
  ```

  ## Parameters

  - chron_lines: List of chronologically-sorted input lines (strings)

  ## Returns

  - List of tuples of the form {guard_id, sleep_minute, wake_minute} (integers)

  """
  def sleepy_times(chron_lines) do
    Enum.map(chron_lines, &parse_line/1)
    |> Enum.reduce({-1, -1, []}, fn ({min, type, rem}, {guard_id, sleep_min, result}) ->
         case {min, type, rem} do
           {_, "Guard", _} ->
             # FIXME replace with first-capture
             r = Regex.named_captures(~r/#(?<guard>\d+)/, rem)
             {String.to_integer(r["guard"]), sleep_min, result}
           {_, "falls", "asleep"} ->
             {guard_id, min, result}
           {_, "wakes", "up"} ->
             {guard_id, sleep_min, [{guard_id, sleep_min, min} | result]}
         end
       end)
    |> elem(2)
    |> Enum.reverse
  end

  @doc """
  Parse line in the following form to get required tokens:

  `[1518-11-01 23:58] Guard #99 begins shift`

  ## Parameters

  - line: Input line (string)

  ## Returns

  - List of tuples of the form {minute, type, remainder}

  ## Examples

  ```
  Day4.parse_line "[1518-11-01 23:58] Guard #99 begins shift"
  #=> {58, "Guard", "#99 begins shift"}

  Day4.parse_line "[1518-11-02 00:40] falls asleep"
  #=> {40, "falls", "asleep"}
  ```
  """
  def parse_line(line) do
    r = Regex.named_captures(~r/\[\d{4}-[^:]*:(?<minute>\d{2})\]\s+(?<type>\S+)\s+(?<remainder>.*)/, line)
    {String.to_integer(r["minute"]), r["type"], r["remainder"]}
  end

  @doc """
  Parse sleep-time tuples to summarize minutes asleep for each guard.

  ## Parameters

  - times: List of tuples of the form {guard_id, sleep_minute, wake_minute} (integers)

  ## Returns

  - map (keyed by guard_id) of total minutes asleep for each guard

  """
  def total_minutes_asleep(times) do
    Enum.reduce(times, %{}, fn ({guard_id, sleep_min, wake_min}, acc) ->
      min = wake_min - sleep_min
      Map.update(acc, guard_id, min, &(&1 + min))
    end)
  end

  @doc """
  Parse sleep-time tuples to create minute breakdown for each guard.

  ## Parameters

  - times: List of tuples of the form {guard_id, sleep_minute, wake_minute} (integers)

  ## Returns

  - two-level map (keyed by guard_id, minute) with minute breakdown for each guard

  """
  def sleep_minute_breakdown(times) do
    Enum.reduce(times, %{}, fn ({guard_id, sleep_min, wake_min}, acc) ->
      mm = minute_map(sleep_min, wake_min)
      if acc[guard_id] do
        new_mm = Map.merge(acc[guard_id], mm, fn (_key, old, new) -> old + new end)
        Map.replace!(acc, guard_id, new_mm)
      else
        Map.put(acc, guard_id, mm)
      end
    end)
  end

  # produce the 2nd-level minute breakdown map
  # e.g. (sleep_min=2, wake_min=5) => %{2 => 1, 3 => 1, 4 => 1}
  defp minute_map(sleep_min, wake_min) do
    Enum.reduce(sleep_min..(wake_min-1), %{}, fn (min, acc) -> Map.put(acc, min, 1) end)
  end
end
