defmodule Packet.DecoderTest do
  use ExUnit.Case
  doctest Packet.Decoder

  describe "puzzle example" do
    setup do
      [
        input: "D2FE2838006F45291200EE00D40C823060\n",
        exp_packets: [
          {6, {:literal, nil, 2021}},
          {1, {:operator, 6, [{6, {:literal, nil, 10}}, {2, {:literal, nil, 20}}]}},
          {7, {:operator, 3, [{2, {:literal, nil, 1}}, {4, {:literal, nil, 2}}, {1, {:literal, nil, 3}}]}},
        ],
      ]
    end

    test "decoder gets expected packets", fixture do
      assert Packet.Decoder.decode(fixture.input) == fixture.exp_packets
    end
  end
end
