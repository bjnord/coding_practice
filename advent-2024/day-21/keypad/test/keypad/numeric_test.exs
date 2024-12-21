defmodule Keypad.NumericTest do
  use ExUnit.Case
  doctest Keypad.Numeric, import: true

  describe "numeric keypad move examples" do
    setup do
      [
        move_tests: [
          {{?A, ?0}, [~c"<"]},
          {{?A, ?2}, [~c"<^", ~c"^<"]},
          {{?A, ?1}, [~c"^<<"]},
          {{?A, ?4}, [~c"^^<<"]},
          {{?A, ?8}, [~c"<^^^", ~c"^^^<"]},
          {{?0, ?A}, [~c">"]},
          {{?0, ?1}, [~c"^<"]},
          {{?0, ?8}, [~c"^^^"]},
          {{?1, ?A}, [~c">>v"]},
          {{?1, ?0}, [~c">v"]},
          {{?3, ?1}, [~c"<<"]},
          {{?3, ?4}, [~c"<<^", ~c"^<<"]},
          {{?4, ?3}, [~c">>v", ~c"v>>"]},
          {{?6, ?4}, [~c"<<"]},
          {{?7, ?9}, [~c">>"]},
          {{?7, ?1}, [~c"vv"]},
          {{?8, ?0}, [~c"vvv"]},
          {{?8, ?A}, [~c">vvv", ~c"vvv>"]},
        ],
      ]
    end

    # TODO use property testing here
    test "produce correct gap-avoiding moves", fixture do
      act_moves = fixture.move_tests
                    |> Enum.map(&(elem(&1, 0)))
                    |> Enum.map(&Keypad.Numeric.move_permutations(&1))
      exp_moves = fixture.move_tests
                    |> Enum.map(&(elem(&1, 1)))
      assert act_moves == exp_moves
    end
  end
end
