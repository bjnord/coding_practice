defmodule LanternfishTest do
  use ExUnit.Case
  doctest Lanternfish

  describe "puzzle example" do
    setup do
      [
        fish: [3, 4, 3, 1, 2],
        gen_fish_18: [6, 0, 6, 4, 5, 6, 0, 1, 1, 2, 6, 0, 1, 1, 1, 2, 2, 3, 3, 4, 6, 7, 8, 8, 8, 8],
        gen_count_80: 5934,
      ]
    end

    test "generator gets expected fish", fixture do
      assert Lanternfish.generate(fixture.fish, 18) == fixture.gen_fish_18
      assert Lanternfish.generate(fixture.fish, 80) |> Enum.count == fixture.gen_count_80
    end
  end
end
