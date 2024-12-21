defmodule KeypadTest do
  use ExUnit.Case
  doctest Keypad

  describe "puzzle example" do
    setup do
      [
        presses: [
          {~c"029A", "<vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A"},
          {~c"980A", "<v<A>>^AAAvA^A<vA<AA>>^AvAA<^A>A<v<A>A>^AAAvA<^A>A<vA>^A<A>A"},
          {~c"179A", "<v<A>>^A<vA<A>>^AAvAA<^A>A<v<A>>^AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A"},
          {~c"456A", "<v<A>>^AA<vA<A>>^AAvAA<^A>A<vA>^A<A>A<vA>^A<A>A<v<A>A>^AAvA<^A>A"},
          {~c"379A", "<v<A>>^AvA^A<vA<AA>>^AAvA<^A>AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A"},
        ],
        exp_complexity: 126384,
      ]
    end

    test "calculate correct complexity", fixture do
      act_complexity = fixture.presses
                       |> Keypad.complexity()
      assert act_complexity == fixture.exp_complexity
    end
  end
end
