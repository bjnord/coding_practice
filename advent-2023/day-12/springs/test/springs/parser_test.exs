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
        """,
        addl: """
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
            tokens: [3, '.###'],
            counts: [1, 1, 3],
          },
          %Row{
            tokens: ['.', 2, '..', 2, '...', 1, '##.'],
            counts: [1, 1, 3],
          },
          %Row{
            tokens: [1, '#', 1, '#', 1, '#', 1, '#', 1, '#', 1, '#', 1, '#', 1],
            counts: [1, 3, 1, 6],
          },
          %Row{
            tokens: [4, '.#...#...'],
            counts: [4, 1, 1],
          },
          %Row{
            tokens: [4, '.######..#####.'],
            counts: [1, 6, 5],
          },
          %Row{
            tokens: [1, '###', 8],
            counts: [3, 2, 1],
          },
        ],
        exp_addl_rows: [
          %Row{
            tokens: [1, '#.', 1, '..', 1, '.##.###', 1],
            counts: [2, 1, 2, 3],
          },
          %Row{
            tokens: ['#', 7, '.', 2, '.', 1, '.', 2, '.', 1],
            counts: [8, 2, 1, 1],
          },
          %Row{
            tokens: [1, '.', 1, '#', 1, '.', 5, '.', 1, '.', 1, '..'],
            counts: [1, 2, 5, 1],
          },
          %Row{
            tokens: [2, '.', 5, '.', 1, '.##.', 1],
            counts: [1, 1, 3, 2],
          },
          %Row{
            tokens: ['.', 1, '.', 1, '.', 2, '#', 1, '.#.', 1, '.', 4],
            counts: [1, 4, 1, 1, 2],
          },
          %Row{
            tokens: [1, '.#.', 3, '.', 2, '.', 3],
            counts: [1, 3, 1, 2],
          },
          %Row{
            tokens: [1, '.##', 1, '.', 3, '.', 2, '.', 1],
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

    test "parser gets expected add'l rows", fixture do
      act_rows = fixture.addl
                 |> parse_input_string()
                 |> Enum.to_list()
      assert act_rows == fixture.exp_addl_rows
    end
  end
end
