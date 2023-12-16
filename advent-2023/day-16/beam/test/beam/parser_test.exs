defmodule Beam.ParserTest do
  use ExUnit.Case
  doctest Beam.Parser, import: true

  import Beam.Parser
  alias Beam.Contraption

  describe "puzzle example" do
    setup do
      [
        input: """
        .|...\\....
        |.-.\\.....
        .....|-...
        ........|.
        ..........
        .........\\
        ..../.\\\\..
        .-.-/..|..
        .|....-|.\\
        ..//.|....
        """,
        exp_contraption: %Contraption{
          tiles: %{
            {0, 1} => ?|,
            {0, 5} => ?\\,
            {1, 0} => ?|,
            {1, 2} => ?-,
            {1, 4} => ?\\,
            {2, 5} => ?|,
            {2, 6} => ?-,
            {3, 8} => ?|,
            {5, 9} => ?\\,
            {6, 4} => ?/,
            {6, 6} => ?\\,
            {6, 7} => ?\\,
            {7, 1} => ?-,
            {7, 3} => ?-,
            {7, 4} => ?/,
            {7, 7} => ?|,
            {8, 1} => ?|,
            {8, 6} => ?-,
            {8, 7} => ?|,
            {8, 9} => ?\\,
            {9, 2} => ?/,
            {9, 3} => ?/,
            {9, 5} => ?|
          },
          size: {10, 10},
        },
      ]
    end

    test "parser gets expected contraption", fixture do
      act_contraption = fixture.input
                        |> parse_input_string()
      assert act_contraption == fixture.exp_contraption
    end
  end
end
