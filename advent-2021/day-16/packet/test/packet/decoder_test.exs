defmodule Packet.DecoderTest do
  use ExUnit.Case
  doctest Packet.Decoder

  describe "puzzle example" do
    setup do
      [
        inputs: ["D2FE28\n", "38006F45291200\n", "EE00D40C823060\n"],
        exp_packets: [
          {6, {:literal, nil, 2021}},
          {1, {:operator, 6, [{6, {:literal, nil, 10}}, {2, {:literal, nil, 20}}]}},
          {7, {:operator, 3, [{2, {:literal, nil, 1}}, {4, {:literal, nil, 2}}, {1, {:literal, nil, 3}}]}},
        ],
      ]
    end

    test "decoder gets expected packets", fixture do
      [fixture.inputs, fixture.exp_packets]
      |> Enum.zip()
      |> Enum.each(fn {input, exp_packet} ->
        act_packet =
          Packet.Decoder.decode(input)
          |> List.first()  # FIXME decode() should return singleton
        assert act_packet == exp_packet
      end)
    end
  end
end
