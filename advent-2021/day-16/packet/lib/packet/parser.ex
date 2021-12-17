defmodule Packet.Parser do
  @moduledoc """
  Parsing for `Packet`.
  """

  @doc ~S"""
  Parse an input string containing a hexadecimal number.

  Returns list of integer bit values.

  ## Examples
      iex> Packet.Parser.parse("B1\n")
      [1, 0, 1, 1, 0, 0, 0, 1]

      iex> Packet.Parser.parse("D2FE28\n")
      [1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0]
  """
  def parse(input) do
    input
    |> String.trim_trailing()
    |> Base.decode16!()
    |> :binary.bin_to_list()
    |> Enum.flat_map(fn byte ->
      Integer.to_string(byte, 2)
      |> String.pad_leading(8, "0")
      |> String.to_charlist()
      |> Enum.map(fn c -> c - ?0 end)
    end)
  end
end
