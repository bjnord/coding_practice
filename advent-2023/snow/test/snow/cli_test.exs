defmodule Snow.CLITest do
  use ExUnit.Case
  doctest Snow.CLI

  test "parts list" do
    ["--parts=12", [1, 2], "--parts=3", [3]]
    |> Enum.chunk_every(2)
    |> Enum.each(fn [arg, exp_parts] ->
      {_, opts} = Snow.CLI.parse_args([arg, "bacon.txt"])
      assert opts[:parts] == exp_parts
    end)
  end

  test "verbose flag, default parts" do
    {_, opts} = Snow.CLI.parse_args(["--verbose", "eggs.txt"])
    assert opts[:verbose] == true
    assert opts[:parts] == [1, 2]
  end

  test "input file" do
    {input_file, _} = Snow.CLI.parse_args(["pancakes.txt"])
    assert input_file == "pancakes.txt"
  end
end
