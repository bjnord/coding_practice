defmodule Cube.ParserTest do
  use ExUnit.Case
  doctest Cube.Parser, import: true

  import Cube.Parser
  alias Cube.Game, as: Game

  describe "puzzle example" do
    setup do
      [
        input: """
        Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
        Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
        Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
        Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
        Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
        """,
        exp_games: [
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
      ]
    end

    test "parser gets expected games", fixture do
      act_games = fixture.input
                  |> parse_input_string()
                  |> Enum.to_list()
      assert act_games == fixture.exp_games
    end
  end
end
