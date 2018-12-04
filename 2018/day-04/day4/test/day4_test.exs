defmodule Day4Test do
  use ExUnit.Case
  doctest Day4

  test "parses input filename from command-line arguments" do
    argv = [
      "input/input.txt",
      ]
    assert Day4.input_file(argv) == "input/input.txt"
  end

  test "sorts input lines chronologically" do
    lines = [
      "[1518-11-02 00:50] wakes up",
      "[1518-11-02 00:40] falls asleep",
      "[1518-11-01 23:58] Guard #99 begins shift",
      ]
    assert Day4.sort_lines(lines) == [
      "[1518-11-01 23:58] Guard #99 begins shift",
      "[1518-11-02 00:40] falls asleep",
      "[1518-11-02 00:50] wakes up",
      ]
  end

  test "gets minute of input line (leading 0)" do
    assert Day4.minute_of("[1518-11-01 00:05] falls asleep") == 5
  end

  test "gets minute of input line (no leading 0)" do
    assert Day4.minute_of("[1518-11-01 23:58] Guard #99 begins shift") == 58
  end
end
