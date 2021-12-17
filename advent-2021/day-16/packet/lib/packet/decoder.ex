defmodule Packet.Decoder do
  @moduledoc """
  Decoding for `Packet`.
  """

  use Bitwise

  @doc ~S"""
  Decode a packet input string (hexadecimal number).

  Returns decoded packet (including any nested packets).

  ## Examples
      iex> Packet.Decoder.decode("D2FE28\n")
      {6, {:literal, nil, 2021}}

      iex> Packet.Decoder.decode("38006F45291200\n")
      {1, {:operator, 6, [{6, {:literal, nil, 10}}, {2, {:literal, nil, 20}}]}}
  """
  def decode(input) do
    input
    |> Packet.Parser.parse()
    |> take_packet()
    |> elem(1)
  end

  ###
  # The following functions all consume from the head of `bits`.
  # Essentially it's a big reduce on `bits` yielding the top-level packet.
  ###

  defp take_packet(bits) do
    ###
    # take version and type (3 bits each)
    # (common to all packet types)
    {bits, version} = take_integer(bits, 3)
    {bits, type} = take_integer(bits, 3)
    ###
    # delegate decoding of the rest of the packet
    # (one of two kinds based on `type`)
    case type do
      4 -> take_literal_packet(bits, version)
      _ -> take_operator_packet(bits, version, type)
    end
  end

  defp take_literal_packet(bits, version) do
    ###
    # take digits (each 5 bits long) until prefix bit tells us to stop
    # convert the digits to literal (integer) value
    {bits, literal} =
      Stream.cycle([true])
      |> Enum.reduce_while({bits, 0}, fn (_, {bits, literal}) ->
        {bits, bitvalue} = take_integer(bits, 5)
        wile = if (bitvalue &&& 0x10) == 0x10, do: :cont, else: :halt
        {wile, {bits, literal * 0x10 + (bitvalue &&& 0x0F)}}
      end)
    ###
    # return remaining bits, and decoded packet
    {bits, {version, {:literal, nil, literal}}}
  end

  defp take_operator_packet(bits, version, type) do
    ###
    # take `mode` bit, and delegate decoding of the rest of the packet
    # (one of two kinds based on `mode` bit)
    {bits, mode} = take_integer(bits, 1)
    {bits, subpkts} =
      case mode do
        0 -> take_fixed_operator_packet(bits)
        1 -> take_counted_operator_packet(bits)
      end
    ###
    # return remaining bits, and decoded packet
    {bits, {version, {:operator, type, subpkts}}}
  end

  defp take_fixed_operator_packet(bits) do
    ###
    # take 15-bit length of subpacket segment
    # take that many bits (the subpacket segment)
    {bits, subpkt_length} = take_integer(bits, 15)
    {subpkt_bits, bits} = Enum.split(bits, subpkt_length)
    ###
    # decode subpacket segment into subpackets
    # return remaining bits, and decoded subpackets
    {bits, take_packets(subpkt_bits)}
  end

  defp take_packets(bits), do: take_packets(bits, [])
  defp take_packets(bits, r_packets) when bits == [], do: Enum.reverse(r_packets)
  defp take_packets(bits, r_packets) do
    ###
    # take the next packet
    {bits, packet} = take_packet(bits)
    ###
    # continue taking packets recursively
    take_packets(bits, [packet | r_packets])
  end

  defp take_counted_operator_packet(bits) do
    ###
    # take 11-bit count of subpackets in subpacket segment
    {bits, subpkt_count} = take_integer(bits, 11)
    ###
    # decode subpacket segment into that many subpackets
    {bits, r_subpkts} =
      1..subpkt_count
      |> Enum.reduce({bits, []}, fn (_n, {bits, r_subpkts}) ->
        {bits, subpkt} = take_packet(bits)
        {bits, [subpkt | r_subpkts]}
      end)
    ###
    # return remaining bits, and decoded subpackets
    {bits, Enum.reverse(r_subpkts)}
  end

  defp take_integer(bits, n) do
    ###
    # take `n` bits and convert to integer value
    {taken_bits, bits} = Enum.split(bits, n)
    value = bits_to_integer(taken_bits)
    ###
    # return remaining bits and integer value
    {bits, value}
  end

  defp bits_to_integer(bits) do
    bits
    |> Enum.reduce(0, fn (b, acc) -> acc * 2 + b end)
  end
end
