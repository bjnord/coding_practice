defmodule Springs.RowTest do
  use ExUnit.Case
  doctest Springs.Row, import: true

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
        exp_pairings: [
          [
            [[1, 1], [3]],
          ],
          [
            [[1], [1], [3]],
          ],
          [
            [[1, 3, 1, 6]],
          ],
          [
            [[4], [1], [1]],
          ],
          [
            [[1], [6], [5]],
          ],
          [
            [[3, 2, 1]],
          ],
          [
            [[2], [0], [1], [2], [3]],
            [[2], [1], [0], [2], [3]],
          ],
          [
            [[8], [2], [0], [1], [1]],
            [[8], [2], [1], [0], [1]],
            [[8], [2], [1], [1], [0]],
          ],
          [
          ],
          [
          ],
          [
          ],
          [
          ],
          [
          ],
        ],
        exp_arrangements: [
          1,
          4,
          1,
          1,
          4,
          10,
          1 * 2 * 1 * 1,
          1 * 1 * (2 + 1 + 2),
          1 * 2 * 1 * 2,
          2 * 1 * 1,  # `1, 3` must fit in `?????`
          2 * 1 * 1 * 1 * 3,
          1 * 1 * 2 * 2,
          1 * 1 * 2 * 1,
        ],
      ]
    end

    test "find pairings", fixture do
      act_pairings = fixture.input
                     |> parse_input_string()
                     |> Enum.slice(0..7)  # FIXME DEBUG TEMP
                     |> Enum.map(&Row.pairings/1)
      assert act_pairings == fixture.exp_pairings
                             |> Enum.slice(0..7)  # FIXME DEBUG TEMP
    end

    # FIXME uncomment
    #test "find arrangements", fixture do
    #  act_arrangements = fixture.input
    #                     |> parse_input_string()
    #                     |> Enum.map(&Row.arrangements/1)
    #  assert act_arrangements == fixture.exp_arrangements
    #end
  end
end
