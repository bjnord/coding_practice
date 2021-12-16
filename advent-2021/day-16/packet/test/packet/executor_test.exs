defmodule Packet.ExecutorTest do
  use ExUnit.Case
  doctest Packet.Executor

  describe "puzzle example" do
    setup do
      [
        input1: "8A004A801A8002F478620080001611562C8802118E34C0015000016115A2E0802F182340A0016C880162017C3686B18A3D4780\n",
        exp_version_sums1: [16, 12, 23, 31],
      ]
    end

    test "executor gets expected version sums", fixture do
      act_version_sum =
        fixture.input1
        |> Packet.Decoder.decode()
        |> Packet.Executor.version_sum()
      assert act_version_sum == Enum.sum(fixture.exp_version_sums1)
    end
  end
end
