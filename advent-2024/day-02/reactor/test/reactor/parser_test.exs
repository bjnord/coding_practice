defmodule Reactor.ParserTest do
  use ExUnit.Case
  doctest Reactor.Parser, import: true

  import Reactor.Parser

  describe "puzzle example" do
    setup do
      [
        input: """
        7 6 4 2 1
        1 2 7 8 9
        9 7 6 2 1
        1 3 2 4 5
        8 6 4 4 1
        1 3 6 7 9
        """,
        exp_reports: [
          [7, 6, 4, 2, 1],
          [1, 2, 7, 8, 9],
          [9, 7, 6, 2, 1],
          [1, 3, 2, 4, 5],
          [8, 6, 4, 4, 1],
          [1, 3, 6, 7, 9],
        ],
      ]
    end

    test "parser gets expected reports", fixture do
      act_reports = fixture.input
                    |> parse_input_string()
                    |> Enum.to_list()
      assert act_reports == fixture.exp_reports
    end
  end
end
