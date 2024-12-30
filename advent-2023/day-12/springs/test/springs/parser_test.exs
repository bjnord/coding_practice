defmodule Springs.ParserTest do
  use ExUnit.Case
  doctest Springs.Parser, import: true

  import Springs.Parser
  alias Springs.Row

  describe "puzzle example" do
    setup do
      [
        input: """
        ???.### 1,1,3
        .??..??...?##. 1,1,3
        ?#?#?#?#?#?#?#? 1,3,1,6
        ????.#...#... 4,1,1
        ????.######..#####. 1,6,5
        ?###???????? 3,2,1
        ?#.?..?.##.###? 2,1,2,3
        #???????.??.?.??.? 8,2,1,1
        ?.?#?.?????.?.?.. 1,2,5,1
        ??.?????.?.##.? 1,1,3,2
        .?.?.??#?.#.?.???? 1,4,1,1,2
        ?.#.???.??.??? 1,3,1,2
        ?.##?.???.??.? 1,3,2,2
        """,
        exp_rows: [
          %Row{
            clusters: ['???', '###'],
            counts: [1, 1, 3],
          },
          %Row{
            clusters: ['??', '??', '?##'],
            counts: [1, 1, 3],
          },
          %Row{
            clusters: ['?#?#?#?#?#?#?#?'],
            counts: [1, 3, 1, 6],
          },
          %Row{
            clusters: ['????', '#', '#'],
            counts: [4, 1, 1],
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
            clusters: ['?#', '?', '?', '##', '###?'],
            counts: [2, 1, 2, 3],
          },
          %Row{
            clusters: ['#???????', '??', '?', '??', '?'],
            counts: [8, 2, 1, 1],
          },
          %Row{
            clusters: ['?', '?#?', '?????', '?', '?'],
            counts: [1, 2, 5, 1],
          },
          %Row{
            clusters: ['??', '?????', '?', '##', '?'],
            counts: [1, 1, 3, 2],
          },
          %Row{
            clusters: ['?', '?', '??#?', '#', '?', '????'],
            counts: [1, 4, 1, 1, 2],
          },
          %Row{
            clusters: ['?', '#', '???', '??', '???'],
            counts: [1, 3, 1, 2],
          },
          %Row{
            clusters: ['?', '##?', '???', '??', '?'],
            counts: [1, 3, 2, 2],
          },
        ],
      ]
    end

    test "parser gets expected rows", fixture do
      act_rows = fixture.input
                 |> parse_input_string()
                 |> Enum.to_list()
      assert act_rows == fixture.exp_rows
    end
  end
end
