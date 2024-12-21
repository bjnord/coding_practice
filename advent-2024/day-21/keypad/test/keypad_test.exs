defmodule KeypadTest do
  use ExUnit.Case
  doctest Keypad

  describe "puzzle example" do
    setup do
      [
        examples: [
          {~c"029A", ~c"<vA<AA>>^AvAA<^A>A<v<A>>^AvA^A<vA>^A<v<A>^A>AAvA^A<v<A>A>^AAAvA<^A>A"},
          {~c"980A", ~c"<v<A>>^AAAvA^A<vA<AA>>^AvAA<^A>A<v<A>A>^AAAvA<^A>A<vA>^A<A>A"},
          {~c"179A", ~c"<v<A>>^A<vA<A>>^AAvAA<^A>A<v<A>>^AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A"},
          {~c"456A", ~c"<v<A>>^AA<vA<A>>^AAvAA<^A>A<vA>^A<A>A<vA>^A<A>A<v<A>A>^AAvA<^A>A"},
          {~c"379A", ~c"<v<A>>^AvA^A<vA<AA>>^AAvA<^A>AAvA^A<vA>^AA<A>A<v<A>A>^AAAvA<^A>A"},
        ],
        exp_complexity: 126384,
      ]
    end

    test "calculate correct minimal lengths", fixture do
      exp_lengths = fixture.examples
                    |> Enum.map(&(elem(&1, 1)))
                    |> Enum.map(&(Enum.count(&1)))
      act_lengths = fixture.examples
                    |> Enum.map(&(elem(&1, 0)))
                    |> Keypad.code_sequences()
                    |> Enum.map(&Enum.count/1)
      assert act_lengths == exp_lengths
    end

    test "calculate correct total complexity from chain of codes", fixture do
      act_complexity = fixture.examples
                       |> Enum.map(&(elem(&1, 0)))
                       |> Keypad.complexity()
      assert act_complexity == fixture.exp_complexity
    end
  end
end
