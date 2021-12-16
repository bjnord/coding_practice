defmodule Packet.Decoder do
  @moduledoc """
  Decoding for `Packet`.
  """

  use Bitwise

  @doc ~S"""
  Decode a packet input string.

  Returns list of decoded packets.
  """
  def decode(input) do
    input
    |> Packet.Parser.parse()
    |> take_packets([])
  end

  ###
  # The following functions all consume from the head of `bits` until empty.
  # Essentially it's a big reduce on `bits` yielding a list of `packets`.
  ###

  defp take_packets(bits, packets) when bits == [], do: Enum.reverse(packets)
  defp take_packets(bits, packets) do
    {bits, packet} = take_packet(bits)
    take_packets(bits, [packet | packets])
  end

  defp take_packet(bits) do
    {bits, version} = take_integer(bits, 3)
    {bits, type} = take_integer(bits, 3)
    case type do
      4 -> take_literal_packet(bits, version)
      _ -> take_todo(bits, version)
    end
  end

  defp take_literal_packet(bits, version) do
    ###
    # take digits (each 5 bits long) until prefix bit tells us to stop
    {bits, literal, n_digits} =
      Stream.cycle([true])
      |> Enum.reduce_while({bits, 0, 0}, fn (_, {bits, literal, n_digits}) ->
        {bits, bitvalue} = take_integer(bits, 5)
        wile = if (bitvalue &&& 0x10) == 0x10, do: :cont, else: :halt
        {wile, {bits, literal * 0x10 + (bitvalue &&& 0x0F), n_digits + 1}}
      end)
    ###
    # remove trailing 0s from last hex digit
    {_zeros, bits} = Enum.split(bits, 4 - rem((3 + 3 + n_digits*5), 4))
    ###
    # return remaining bits and resulting packet
    {
      bits,
      {version, {:literal, literal}},
    }
  end

  defp take_todo(_bits, version) do
    {
      [],
      {version, {:todo}}
    }
  end

  defp take_integer(bits, n) do
    {taken_bits, bits} = Enum.split(bits, n)
    value = bits_to_integer(taken_bits)
    {bits, value}
  end

  defp bits_to_integer(bits) do
    bits
    |> Enum.reduce(0, fn (b, acc) -> acc * 2 + b end)
  end
end
