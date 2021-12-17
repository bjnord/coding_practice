defmodule Packet.Decoder do
  @moduledoc """
  Decoding for `Packet`.
  """

  use Bitwise

  @doc ~S"""
  Decode a packet input string (hexadecimal number).

  Returns decoded packet (including any nested packets).
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

  @doc ~S"""
  Take a packet from a bitlist.

  ## Examples
      iex> Packet.Parser.parse("D2FE28\n") |> Packet.Decoder.take_packet()
      {[0, 0, 0], {6, {:literal, nil, 2021}}, 21}

      iex> Packet.Parser.parse("38006F45291200\n") |> Packet.Decoder.take_packet()
      {[0, 0, 0, 0, 0, 0, 0], {1, {:operator, 6, [{6, {:literal, nil, 10}}, {2, {:literal, nil, 20}}]}}, 49}

      iex> Packet.Parser.parse("EE00D40C823060\n") |> Packet.Decoder.take_packet()
      {[0, 0, 0, 0, 0], {7, {:operator, 3, [{2, {:literal, nil, 1}}, {4, {:literal, nil, 2}}, {1, {:literal, nil, 3}}]}}, 51}
  """
  def take_packet(bits) do
    ###
    # take version and type (3 bits each)
    {bits, version} = take_integer(bits, 3)
    {bits, type} = take_integer(bits, 3)
    ###
    # take rest of packet (one of two kinds based on `type`)
    {bits, packet, length} =
      case type do
        4 -> take_literal_packet(bits, version)
        _ -> take_operator_packet(bits, version, type)
      end
    ###
    # return remaining bits, decoded packet, and consumed packet length
    {bits, packet, 3 + 3 + length}
  end

  defp take_literal_packet(bits, version) do
    ###
    # take digits (each 5 bits long) until prefix bit tells us to stop
    # convert the digits to literal (integer) value
    {bits, literal, n_digits} =
      Stream.cycle([true])
      |> Enum.reduce_while({bits, 0, 0}, fn (_, {bits, literal, n_digits}) ->
        {bits, bitvalue} = take_integer(bits, 5)
        wile = if (bitvalue &&& 0x10) == 0x10, do: :cont, else: :halt
        {wile, {bits, literal * 0x10 + (bitvalue &&& 0x0F), n_digits + 1}}
      end)
    ###
    # return remaining bits, decoded packet, and consumed segment length
    {
      bits,
      {version, {:literal, nil, literal}},
      n_digits * 5,
    }
  end

  defp take_operator_packet(bits, version, type) do
    ###
    # take an operator packet (one of two kinds based on `mode` bit)
    {bits, mode} = take_integer(bits, 1)
    {bits, subpkts, length} =
      case mode do
        0 -> take_fixed_operator_packet(bits)
        1 -> take_counted_operator_packet(bits)
      end
    ###
    # return remaining bits, decoded packet, and consumed segment length
    {
      bits,
      {version, {:operator, type, subpkts}},
      1 + length,
    }
  end

  defp take_fixed_operator_packet(bits) do
    ###
    # take 15-bit length of subpacket segment
    # take that many bits (the subpacket segment)
    {bits, subpkt_length} = take_integer(bits, 15)
    {subpkt_bits, bits} = Enum.split(bits, subpkt_length)
    ###
    # decode subpacket segment into subpackets
    # return remaining bits, subpackets, and consumed segment length
    {bits, take_packets(subpkt_bits, []), 15 + subpkt_length}
  end

  defp take_packets(bits, r_packets) when bits == [], do: Enum.reverse(r_packets)
  defp take_packets(bits, r_packets) do
    ###
    # take the next packet
    {bits, packet, _length} = take_packet(bits)
    ###
    # continue taking packets recursively
    take_packets(bits, [packet | r_packets])
  end

  defp take_counted_operator_packet(bits) do
    ###
    # take 11-bit count of subpackets in subpacket segment
    {bits, subpkt_count} = take_integer(bits, 11)
    ###
    # decode subpacket segment into that many subpackets,
    # summing up the bit length of each
    {bits, r_subpkts, subpkt_length} =
      1..subpkt_count
      |> Enum.reduce({bits, [], 0}, fn (_n, {bits, r_subpkts, subpkt_length}) ->
        {bits, subpkt, length} = take_packet(bits)
        {bits, [subpkt | r_subpkts], subpkt_length + length}
      end)
    ###
    # return remaining bits, subpackets, and total consumed segment length
    {bits, Enum.reverse(r_subpkts), 11 + subpkt_length}
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
