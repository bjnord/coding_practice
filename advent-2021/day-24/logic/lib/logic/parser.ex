defmodule Logic.Parser do
  @moduledoc """
  Parsing for `Logic`.
  """

  @doc ~S"""
  Parse input as a block string.
  """
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.split()
    |> Enum.with_index()
    |> Enum.map(&decode_op_or_int/1)
    |> List.to_tuple()
  end

  def decode_op_or_int({token, i}) do
    case i do
      0 ->
        String.to_atom(token)
      1 ->
        String.to_atom(token)
      2 ->
        case Integer.parse(token) do
          :error -> String.to_atom(token)
          _      -> String.to_integer(token)
        end
    end
  end
end
