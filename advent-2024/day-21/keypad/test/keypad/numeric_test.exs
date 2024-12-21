defmodule Keypad.NumericTest do
  use ExUnit.Case
  doctest Keypad.Numeric, import: true

  describe "numeric keypad motion examples" do
    setup do
      [
        motion_tests: [
          {{?A, ?0}, ~c"<"},
          #{{?A, ?2}, ~c"<^"},    # dodge-around
          #{{?A, ?1}, ~c"<^<"},   # dodge-around
          #{{?A, ?4}, ~c"<^^<"},  # dodge-around
          {{?A, ?2}, ~c"^<"},
          {{?A, ?1}, ~c"^<<"},
          {{?A, ?4}, ~c"^^<<"},
          {{?0, ?A}, ~c">"},
          {{?0, ?1}, ~c"^<"},
          {{?0, ?8}, ~c"^^^"},
          {{?1, ?A}, ~c">>v"},
          {{?1, ?0}, ~c">v"},
          {{?6, ?4}, ~c"<<"},
          {{?7, ?9}, ~c">>"},
          {{?7, ?1}, ~c"vv"},
        ],
      ]
    end

    # TODO use property testing here
    test "produce correct gap-avoiding motions", fixture do
      act_motions = fixture.motion_tests
                    |> Enum.map(&(elem(&1, 0)))
                    |> Enum.map(&Keypad.Numeric.motions(&1))
      exp_motions = fixture.motion_tests
                    |> Enum.map(&(elem(&1, 1)))
      assert act_motions == exp_motions
    end
  end
end
