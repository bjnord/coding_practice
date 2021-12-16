defmodule Packet.DecoderTest do
  use ExUnit.Case
  doctest Packet.Decoder

  describe "puzzle example" do
    setup do
      [
        input: "D2FE2838006F45291200EE00D40C823060\n",
        input2: "8A004A801A8002F478620080001611562C8802118E34C0015000016115A2E0802F182340A0016C880162017C3686B18A3D4780\n",
        exp_packets: [
          {6, {:literal, 2021}},
          {1, {:operator, 6, [{6, {:literal, 10}}, {2, {:literal, 20}}]}},
          {7, {:operator, 3, [{2, {:literal, 1}}, {4, {:literal, 2}}, {1, {:literal, 3}}]}},
        ],
        exp_version_sums: [6, 1 + 6 + 2, 7 + 2 + 4 + 1],
        exp_version_sums2: [16, 12, 23, 31],
      ]
    end

    test "decoder gets expected packets", fixture do
      assert Packet.Decoder.decode(fixture.input) == fixture.exp_packets
    end

    test "executor gets expected version sums", fixture do
      [
        {fixture.input, fixture.exp_version_sums},
        {fixture.input2, fixture.exp_version_sums2},
      ]
      |> Enum.each(fn {input, exp_version_sums} ->
        act_version_sum =
          input
          |> Packet.Decoder.decode()
          |> Packet.Executor.version_sum()
        assert act_version_sum == Enum.sum(exp_version_sums)
      end)
    end
  end
end
