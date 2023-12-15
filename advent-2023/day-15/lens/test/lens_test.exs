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
        exp_iv_hashes: [
          30,
          253,
          97,
          47,
          14,
          180,
          9,
          197,
          48,
          214,
          231,
        ],
      ]
    end

    test "find HASH value of HASH", fixture do
      act_hash = Lens.hash("HASH")
      assert act_hash == fixture.exp_hash
    end

    test "find HASH value of IV", fixture do
      # TODO move to `Lens.Parser`
      act_iv_hashes =
        fixture.input
        |> String.split(",")
        |> Enum.map(&Lens.hash/1)
      assert act_iv_hashes == fixture.exp_iv_hashes
    end
  end
end
