defmodule MineCart.InputParser do
  @doc ~S"""
  Parses a line from the initial state, adding its data to accumulators.

  ## Parameters

  - line: input line (String)
  - y: line number (integer, 0-relative)
  - grid: squares from mine cart diagram (Map w/key={x, y} tuple)
  - carts: list of carts (`{{x, y}, dir, state}`)

  ## Returns

  Tuple:
  - grid: squares from mine cart diagram (Map w/key={x, y} tuple)
  - carts: list of carts (`{{x, y}, direction, next_turn}`)

  ## Example

      iex> {grid, carts} = MineCart.InputParser.parse_line("/-\\ |+ <^>v", 42, %{}, [])
      iex> grid
      %{
        {0, 42} => :curve_ld,
        {1, 42} => :horiz,
        {2, 42} => :curve_rd,
        {4, 42} => :vert,
        {5, 42} => :intersect,
        {7, 42} => :horiz,
        {8, 42} => :vert,
        {9, 42} => :horiz,
        {10, 42} => :vert,
      }
      iex> carts
      [
        {{10, 42}, :down, :left},
        {{9, 42}, :right, :left},
        {{8, 42}, :up, :left},
        {{7, 42}, :left, :left},
      ]

  """
  def parse_line(line, y, grid, carts) when is_binary(line) do
    line
    |> String.trim
    |> String.graphemes
    |> Enum.with_index
    |> Enum.reduce({grid, carts}, fn ({square, x}, {grid_a, carts_a}) ->
      case square_type(square) do
        {:track, track_kind} ->
          {Map.put(grid_a, {x, y}, track_kind), carts_a}
        {:cart, direction} ->
          track_kind = track_of_cart(direction)
          {
            Map.put(grid_a, {x, y}, track_kind),
            [{{x, y}, direction, :left} | carts_a]
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
      "/" -> {:track, :curve_ld}
      "\\" -> {:track, :curve_rd}
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
