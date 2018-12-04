defmodule Day4Test do
  use ExUnit.Case
  doctest Day4

  test "parses input filename from command-line arguments" do
    argv = [
      "input/input.txt",
      ]
    assert Day4.input_file(argv) == "input/input.txt"
  end
end
