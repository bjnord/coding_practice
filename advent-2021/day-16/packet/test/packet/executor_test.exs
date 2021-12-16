defmodule Packet.ExecutorTest do
  use ExUnit.Case
  doctest Packet.Executor

  describe "puzzle example" do
    setup do
      [
        inputs: [
          "8A004A801A8002F478\n",
          "620080001611562C8802118E34\n",
          "C0015000016115A2E0802F182340\n",
          "A0016C880162017C3686B18A3D4780\n"
        ],
        exp_version_sums: [16, 12, 23, 31],
        examples: [
          {"C200B40A82", 3},
          {"04005AC33890", 54},
          {"880086C3E88112", 7},
          {"CE00C43D881120", 9},
          {"D8005AC2A8F0", 1},
          {"F600BC2D8F", 0},
          {"9C005AC2F8F0", 0},
          {"9C0141080250320F1802104A08", 1},
        ],
      ]
    end

    test "executor gets expected version sums", fixture do
      [fixture.inputs, fixture.exp_version_sums]
      |> Enum.zip()
      |> Enum.each(fn {input, exp_version_sum} ->
        act_version_sum =
          Packet.Decoder.decode(input)
          |> List.first()  # FIXME decode() should return singleton
          |> Packet.Executor.version_sum()
        assert act_version_sum == exp_version_sum
      end)
    end

    test "executor gets expected calculated values", fixture do
      fixture.examples
      |> Enum.each(fn {packet_input, exp_value} ->
        act_value =
          packet_input
          |> Packet.Decoder.decode()
          |> List.first()  # FIXME decode() should return singleton
          |> Packet.Executor.calculate()
        assert act_value == exp_value
      end)
    end
  end
end
