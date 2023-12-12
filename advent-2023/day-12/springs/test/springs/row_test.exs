defmodule Springs.RowTest do
  use ExUnit.Case
  doctest Springs.Row, import: true

  alias Springs.Row

  describe "puzzle example" do
    setup do
      [
        rows: [
          %Row{
            clusters: ['????', '#', '#'],
            counts: [4, 1, 1],
          },
          %Row{
            clusters: ['??', '??', '?##'],
            counts: [1, 1, 3],
          },
          %Row{
            clusters: ['????', '######', '#####'],
            counts: [1, 6, 5],
          },
          %Row{
            clusters: ['?###????????'],
            counts: [3, 2, 1],
          },
          %Row{
            clusters: ['?#?#?#?#?#?#?#?'],
            counts: [1, 3, 1, 6],
          },
          %Row{
            clusters: ['???', '###'],
            counts: [1, 1, 3],
          },
        ],
        exp_arrangements: [
          1,
          4,
          4,
          10,
          1,
          1,
        ],
      ]
    end

    test "find arrangementss", fixture do
      act_arrangements = fixture.rows
                         |> Enum.map(&Row.arrangements/1)
      assert act_arrangements == fixture.exp_arrangements
    end
  end
end
