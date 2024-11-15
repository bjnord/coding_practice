defmodule Kingdom.CLITest do
  use ExUnit.Case
  doctest Kingdom.CLI

  test "parts list" do
    ["--parts=12", [1, 2], "--parts=3", [3]]
    |> Enum.chunk_every(2)
    |> Enum.each(fn [arg, exp_parts] ->
      opts = Kingdom.CLI.parse_args([arg])
      assert opts[:parts] == exp_parts
    end)
  end

  test "verbose flag, default parts" do
    opts = Kingdom.CLI.parse_args(["--verbose"])
    assert opts[:verbose] == true
    assert opts[:parts] == [1, 2, 3]
  end
end
