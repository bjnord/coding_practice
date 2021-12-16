defmodule Packet.DecoderTest do
  use ExUnit.Case
  doctest Packet.Decoder

  describe "puzzle example" do
    setup do
      [
        input: "D2FE2838006F45291200EE00D40C823060\n",
        exp_packets: [
          {6, {:literal, 2021}},
          {1, {:operator, 6, [10, 20]}},
          {7, {:operator, 3, [1, 2, 3]}},
        ],
      ]
    end

    # Here are a few more examples of hexadecimal-encoded transmissions:
    #
    # 8A004A801A8002F478 represents an operator packet (version 4) which contains an operator packet (version 1) which contains an operator packet (version 5) which contains a literal value (version 6); this packet has a version sum of 16.
    # 620080001611562C8802118E34 represents an operator packet (version 3) which contains two sub-packets; each sub-packet is an operator packet that contains two literal values. This packet has a version sum of 12.
    # C0015000016115A2E0802F182340 has the same structure as the previous example, but the outermost packet uses a different length type ID. This packet has a version sum of 23.
    # A0016C880162017C3686B18A3D4780 is an operator packet that contains an operator packet that contains an operator packet that contains five literal values; it has a version sum of 31.

    test "decoder gets expected packets", fixture do
      assert Packet.Decoder.decode(fixture.input) == fixture.exp_packets
    end
  end
end
