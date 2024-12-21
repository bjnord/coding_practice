defmodule Keypad.DirectionalTest do
  use ExUnit.Case
  doctest Keypad.Directional, import: true

  describe "directional keypad move examples" do
    setup do
      [
        move_tests: [
          {{?A, ?<}, [~c"v<<"]},
          {{?A, ?v}, [~c"<v", ~c"v<"]},
          {{?<, ?A}, [~c">>^"]},
          {{?^, ?<}, [~c"v<"]},
          {{?<, ?^}, [~c">^"]},
          {{?^, ?v}, [~c"v"]},
          {{?>, ?A}, [~c"^"]},
          {{?<, ?>}, [~c">>"]},
          {{?A, ?^}, [~c"<"]},
        ],
      ]
    end

    # TODO use property testing here
    test "produce correct gap-avoiding moves", fixture do
      act_moves = fixture.move_tests
                  |> Enum.map(&(elem(&1, 0)))
                  |> Enum.map(&Keypad.Directional.move_permutations(&1))
      exp_moves = fixture.move_tests
                  |> Enum.map(&(elem(&1, 1)))
      assert act_moves == exp_moves
    end
  end
end
