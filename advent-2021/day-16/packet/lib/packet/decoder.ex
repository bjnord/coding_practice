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
    |> take_packets_and_zeros([])
  end

  ###
  # The following functions all consume from the head of `bits` until empty.
  # Essentially it's a big reduce on `bits` yielding a list of `packets`.
  ###

  # at the top level, we take zeroes to "round off" to a full byte
  defp take_packets_and_zeros(bits, r_packets) when bits == [], do: Enum.reverse(r_packets)
  defp take_packets_and_zeros(bits, r_packets) do
    ###
    # take the next packet
    {bits, packet, length} = take_packet(bits)
    ###
    # take trailing 0s from last byte
    {_zeros, bits} = Enum.split(bits, 8 - rem(length, 8))
    ###
    # continue taking packets recursively
    take_packets_and_zeros(bits, [packet | r_packets])
  end

  # at lower levels (subpackets), we ignore length and don't take zeroes
  defp take_packets(bits, r_packets) when bits == [], do: Enum.reverse(r_packets)
  defp take_packets(bits, r_packets) do
    ###
    # take the next packet
    {bits, packet, _length} = take_packet(bits)
    ###
    # continue taking packets recursively
    take_packets(bits, [packet | r_packets])
  end

  @doc ~S"""
  Take a packet.

  ## Examples
      iex> Packet.Parser.parse("D2FE28\n") |> Packet.Decoder.take_packet()
      {[0, 0, 0], {6, {:literal, nil, 2021}}, 21}

      iex> Packet.Parser.parse("38006F45291200\n") |> Packet.Decoder.take_packet()
      {[0, 0, 0, 0, 0, 0, 0], {1, {:operator, 6, [{6, {:literal, nil, 10}}, {2, {:literal, nil, 20}}]}}, 49}

      iex> Packet.Parser.parse("EE00D40C823060\n") |> Packet.Decoder.take_packet()
      {[0, 0, 0, 0, 0], {7, {:operator, 3, [{2, {:literal, nil, 1}}, {4, {:literal, nil, 2}}, {1, {:literal, nil, 3}}]}}, 51}
  """
  def take_packet(bits) do
    {bits, version} = take_integer(bits, 3)
    {bits, type} = take_integer(bits, 3)
    {bits, packet, length} =
      case type do
        4 -> take_literal_packet(bits, version)
        _ -> take_operator_packet(bits, version, type)
      end
    {bits, packet, 3 + 3 + length}
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
    # return remaining bits, decoded packet, and consumed payload length
    {
      bits,
      {version, {:literal, nil, literal}},
      n_digits * 5,
    }
  end

  defp take_operator_packet(bits, version, type) do
    {bits, mode} = take_integer(bits, 1)
    {bits, subpkts, length} =
      case mode do
        0 -> take_fixed_operator_packet(bits)
        1 -> take_counted_operator_packet(bits)
      end
    {
      bits,
      {version, {:operator, type, subpkts}},
      1 + length,
    }
  end

  defp take_fixed_operator_packet(bits) do
    {bits, subpkt_length} = take_integer(bits, 15)
    {subpkt_bits, bits} = Enum.split(bits, subpkt_length)
    {bits, take_packets(subpkt_bits, []), 15 + subpkt_length}
  end

  defp take_counted_operator_packet(bits) do
    {bits, subpkt_count} = take_integer(bits, 11)
    {bits, r_subpkts, subpkt_length} =
      1..subpkt_count
      |> Enum.reduce({bits, [], 0}, fn (_n, {bits, r_subpkts, subpkt_length}) ->
        {bits, subpkt, length} = take_packet(bits)
        {bits, [subpkt | r_subpkts], subpkt_length + length}
      end)
    {bits, Enum.reverse(r_subpkts), 11 + subpkt_length}
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
