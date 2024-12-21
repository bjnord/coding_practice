defmodule Keypad.DirectionalTest do
  use ExUnit.Case
  doctest Keypad.Directional, import: true

  describe "directional keypad motion examples" do
    setup do
      [
        motion_tests: [
          {{?A, ?<}, ~c"v<<"},
          {{?A, ?v}, ~c"v<"},
          {{?<, ?A}, ~c">>^"},
          {{?^, ?<}, ~c"v<"},
          {{?<, ?^}, ~c">^"},
          {{?^, ?v}, ~c"v"},
          {{?>, ?A}, ~c"^"},
          {{?<, ?>}, ~c">>"},
          {{?A, ?^}, ~c"<"},
        ],
      ]
    end

    # TODO use property testing here
    test "produce correct gap-avoiding motions", fixture do
      act_motions = fixture.motion_tests
                    |> Enum.map(&(elem(&1, 0)))
                    |> Enum.map(&Keypad.Directional.motions(&1))
      exp_motions = fixture.motion_tests
                    |> Enum.map(&(elem(&1, 1)))
      assert act_motions == exp_motions
    end
  end
end
