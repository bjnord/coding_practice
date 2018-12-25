defmodule Teleport.CLITest do
  use ExUnit.Case
  doctest Teleport.CLI

  import Teleport.CLI

  test "parse line with negative coordinates" do
    assert parse_line("pos=<0,-5,3>, r=4") == {{0, -5, 3}, 4}
  end

  test "parse line with big coordinates" do
    assert parse_line("pos=<99663890,15679983,37262396>, r=53694281") == {{99663890, 15679983, 37262396}, 53694281}
  end
end
