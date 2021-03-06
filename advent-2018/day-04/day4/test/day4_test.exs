defmodule Day4Test do
  use ExUnit.Case
  doctest Day4

  import Day4

  test "parses input filename from command-line arguments" do
    argv = [
      "input/input.txt",
      ]
    assert input_file(argv) == "input/input.txt"
  end

  test "sorts input lines chronologically" do
    lines = [
      "[1518-11-02 00:50] wakes up",
      "[1518-11-02 00:40] falls asleep",
      "[1518-11-01 23:58] Guard #99 begins shift",
      ]
    assert sort_lines(lines) == [
      "[1518-11-01 23:58] Guard #99 begins shift",
      "[1518-11-02 00:40] falls asleep",
      "[1518-11-02 00:50] wakes up",
      ]
  end

  test "gets minute of input line (leading 0)" do
    assert minute_of("[1518-11-01 00:05] falls asleep") == 5
  end

  test "gets minute of input line (no leading 0)" do
    assert minute_of("[1518-11-01 23:58] Guard #99 begins shift") == 58
  end

  test "parses chronological lines to sleep tuples" do
    chron_lines = [
      "[1518-11-01 00:00] Guard #10 begins shift",
      "[1518-11-01 00:05] falls asleep",
      "[1518-11-01 00:25] wakes up",
      "[1518-11-01 00:30] falls asleep",
      "[1518-11-01 00:55] wakes up",
      "[1518-11-01 23:58] Guard #99 begins shift",
      "[1518-11-02 00:40] falls asleep",
      "[1518-11-02 00:50] wakes up",
      ]
    assert sleepy_times(chron_lines) == [
      {10, 5, 25}, {10, 30, 55},
      {99, 40, 50},
    ]
  end

  test "parses Guard line" do
    assert parse_line("[1518-11-01 23:58] Guard #99 begins shift") == {58, "Guard", "#99 begins shift"}
  end

  test "parses falls-asleep line" do
    assert parse_line("[1518-11-02 00:40] falls asleep") == {40, "falls", "asleep"}
  end

  test "parses wakes-up line" do
    assert parse_line("[1518-11-02 00:50] wakes up") == {50, "wakes", "up"}
  end

  test "summarizes total minutes asleep by guard from sleep-time tuples" do
    times = [
      {10, 5, 25}, {10, 30, 55},
      {99, 40, 50},
    ]
    assert total_minutes_asleep(times) == %{10 => 45, 99 => 10}
  end

  test "creates minute breakdown by guard from sleep-time tuples" do
    times = [
      {10, 22, 25}, {10, 30, 32},
      {99, 40, 43},
      {10, 24, 27},
    ]
    assert sleep_minute_breakdown(times) == %{
      10 => %{22 => 1, 23 => 1, 24 => 2, 25 => 1, 26 => 1, 30 => 1, 31 => 1},
      99 => %{40 => 1, 41 => 1, 42 => 1},
    }
  end
end
