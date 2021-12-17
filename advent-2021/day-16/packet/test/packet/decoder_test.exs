defmodule Packet.DecoderTest do
  use ExUnit.Case
  doctest Packet.Decoder

  alias Packet.Decoder, as: Decoder

  describe "puzzle example" do
    setup do
      [
        inputs: ["D2FE28\n", "38006F45291200\n", "EE00D40C823060\n"],
        exp_packets: [
          {6, {:literal, 2021}},
          {1, {:op_lt, [{6, {:literal, 10}}, {2, {:literal, 20}}]}},
          {7, {:op_max, [{2, {:literal, 1}}, {4, {:literal, 2}}, {1, {:literal, 3}}]}},
        ],
      ]
    end

    test "decoder gets expected packets", fixture do
      [fixture.inputs, fixture.exp_packets]
      |> Enum.zip()
      |> Enum.each(fn {input, exp_packet} ->
        assert Decoder.decode(input) == exp_packet
      end)
    end
  end
end
