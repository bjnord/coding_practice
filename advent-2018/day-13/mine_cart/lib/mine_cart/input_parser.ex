defmodule MineCart.InputParser do
  @doc ~S"""
  Parses a line from the initial state, adding its data to accumulators.

  ## Parameters

  - line: input line (String)
  - y: line number (integer, 0-relative)
  - grid: squares from mine cart diagram (Map w/key=`{y, x}`)
  - carts: list of carts (`{{y, x}, dir, state}`)

  ## Returns

  Tuple:
  - grid: squares from mine cart diagram (Map w/key=`{y, x}`)
  - carts: list of carts (`{{y, x}, direction, next_turn}`)

  ## Example

      iex> {grid, carts} = MineCart.InputParser.parse_line("/-\\ |+ <^>v   \n", 42, %{}, [])
      iex> grid
      %{
        {42, 0} => :curve_ne,
        {42, 1} => :horiz,
        {42, 2} => :curve_nw,
        {42, 4} => :vert,
        {42, 5} => :intersect,
        {42, 7} => :horiz,
        {42, 8} => :vert,
        {42, 9} => :horiz,
        {42, 10} => :vert,
      }
      iex> carts
      [
        {{42, 10}, :down, :left},
        {{42, 9}, :right, :left},
        {{42, 8}, :up, :left},
        {{42, 7}, :left, :left},
      ]

  """
  def parse_line(line, y, grid, carts) when is_binary(line) do
    line
    |> String.trim_trailing
    |> String.graphemes
    |> Enum.with_index
    |> Enum.reduce({grid, carts}, fn ({square, x}, {grid_a, carts_a}) ->
      case square_type(square) do
        {:track, track_kind} ->
          {Map.put(grid_a, {y, x}, track_kind), carts_a}
        {:cart, direction} ->
          track_kind = track_of_cart(direction)
          {
            Map.put(grid_a, {y, x}, track_kind),
            [{{y, x}, direction, :left} | carts_a]
          }
        _ ->
          {grid_a, carts_a}
      end
    end)
  end

  defp square_type(square) do
    case square do
      "-" -> {:track, :horiz}
      "|" -> {:track, :vert}
      "/" -> {:track, :curve_ne}
      "\\" -> {:track, :curve_nw}
      "+" -> {:track, :intersect}
      "<" -> {:cart, :left}
      "^" -> {:cart, :up}
      ">" -> {:cart, :right}
      "v" -> {:cart, :down}
      _ -> {:empty}
    end
  end

  defp track_of_cart(dir) when dir in [:up, :down],
    do: :vert
  defp track_of_cart(dir) when dir in [:left, :right],
    do: :horiz
end
