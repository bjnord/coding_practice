defmodule Chiton.Cave do
  @moduledoc """
  Parsing for `Chiton`.
  """

  defstruct dimx: 0, dimy: 0, risks: {}

  @doc ~S"""
  Construct a new `Cave` from `input`.

  ## Examples
      iex> Chiton.Cave.new("01\n23\n")
      %Chiton.Cave{dimx: 2, dimy: 2, risks: {{0, 1}, {2, 3}}}
  """
  def new(input) do
    risks= parse(input)
    [dimx] = row_widths(risks)
    %Chiton.Cave{
      risks: risks,
      dimx: dimx,
      dimy: tuple_size(risks),
    }
  end
  defp row_widths(risks) do
    for row <- Tuple.to_list(risks),
      uniq: true,
      do: tuple_size(row)
  end

  @doc false
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_line/1)
    |> List.to_tuple()
  end
  defp parse_line(line) do
    line
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.map(fn d -> d - ?0 end)
    |> List.to_tuple()
  end
end
