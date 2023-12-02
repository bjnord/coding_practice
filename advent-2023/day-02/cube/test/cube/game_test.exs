defmodule Cube.GameTest do
  use ExUnit.Case
  doctest Cube.Game

  alias Cube.Game, as: Game

  describe "puzzle example" do
    setup do
      [
        games: [
          %Game{id: 1, reveals: [
            %{blue: 3, red: 4},
            %{red: 1, green: 2, blue: 6},
            %{green: 2},
          ]},
          %Game{id: 2, reveals: [
            %{blue: 1, green: 2},
            %{green: 3, blue: 4, red: 1},
            %{green: 1, blue: 1},
          ]},
          %Game{id: 3, reveals: [
            %{green: 8, blue: 6, red: 20},
            %{blue: 5, red: 4, green: 13},
            %{green: 5, red: 1},
          ]},
          %Game{id: 4, reveals: [
            %{green: 1, red: 3, blue: 6},
            %{green: 3, red: 6},
            %{green: 3, blue: 15, red: 14},
          ]},
          %Game{id: 5, reveals: [
            %{red: 6, blue: 1, green: 3},
            %{blue: 2, red: 1, green: 2},
          ]},
        ],
        exp_max_reveals: [
          %Game{id: 1, max_reveal: %{red: 4, green: 2, blue: 6}},
          %Game{id: 2, max_reveal: %{green: 3, blue: 4, red: 1}},
          %Game{id: 3, max_reveal: %{blue: 6, red: 20, green: 13}},
          %Game{id: 4, max_reveal: %{green: 3, blue: 15, red: 14}},
          %Game{id: 5, max_reveal: %{red: 6, blue: 2, green: 3}},
        ],
        exp_possibles: [
          true,
          true,
          false,
          false,
          true
        ],
      ]
    end

    test "calculate maximum cubes revealed", fixture do
      act_max_reveals = fixture.games
                        |> Enum.map(&Game.max/1)
      assert act_max_reveals == fixture.exp_max_reveals
    end

    test "calculate possible games", fixture do
      act_possibles = fixture.exp_max_reveals
                      |> Enum.map(&Game.possible?/1)
      assert act_possibles == fixture.exp_possibles
    end
  end
end
