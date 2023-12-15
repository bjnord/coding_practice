defmodule LensTest do
  use ExUnit.Case
  doctest Lens

  describe "puzzle example" do
    setup do
      [
        input: """
        rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
        """,
        exp_hash: 52,
      ]
    end

    test "find HASH value of HASH", fixture do
      act_hash = Lens.hash("HASH")
      assert act_hash == fixture.exp_hash
    end
  end
end
