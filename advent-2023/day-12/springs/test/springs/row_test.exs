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
        rows_addl: [
          %Row{
            clusters: ['?#', '?', '?', '##', '###?'],
            counts: [2, 1, 2, 3],
          },
          %Row{
            clusters: [~c"#???????", ~c"??", ~c"?", ~c"??", ~c"?"],
            counts: [8, 2, 1, 1]
          },
          %Row{
            clusters: [~c"?", ~c"?#?", ~c"?????", ~c"?", ~c"?"],
            counts: [1, 2, 5, 1]
          },
          %Row{
            clusters: [~c"??", ~c"?????", ~c"?", ~c"##", ~c"?"],
            counts: [1, 1, 3, 2]
          },
          %Row{
            clusters: ['?', '?', '??#?', '#', '?', '????'],
            counts: [1, 4, 1, 1, 2],
          },
          %Row{
            clusters: [~c"?", ~c"#", ~c"???", ~c"??", ~c"???"],
            counts: [1, 3, 1, 2]
          },
          %Row{
            clusters: [~c"?", ~c"##?", ~c"???", ~c"??", ~c"?"],
            counts: [1, 3, 2, 2]
          },
        ],
        exp_arrangements_addl: [
          1 * 2 * 1 * 1,
          1 * 1 * (3 + 2),
          1 * 2 * 1 * 2,
          2 * 1 * 1,  # `1, 3` must fit in `?????`
          2 * 1 * 1 * 1 * 3,
          1 * 1 * 2 * 2,
          1 * 1 * 2 * 1,
        ],
      ]
    end

    test "find arrangements", fixture do
      act_arrangements = fixture.rows
                         |> Enum.map(&Row.arrangements/1)
      assert act_arrangements == fixture.exp_arrangements
    end

    test "find arrangements (add'l test cases)", fixture do
      act_arrangements = fixture.rows_addl
                         |> Enum.map(&Row.arrangements/1)
      assert act_arrangements == fixture.exp_arrangements_addl
    end
  end
end
