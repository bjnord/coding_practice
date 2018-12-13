defmodule MineCart do
  @moduledoc """
  Documentation for MineCart.
  """

  import MineCart.CLI

  @doc """
  Process input file and display part 1 solution.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    input_file = parse_args(argv)
    part1(input_file)
    part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Correct Answer

  - Part 1 answer is: "71,121"
  """
  def part1(input_file) do
    {_y, {grid, carts}} =
      input_file
      |> File.stream!
      |> Enum.reduce({0, {%{}, []}}, fn (line, {y, {grid, carts}}) ->
        {y+1, MineCart.InputParser.parse_line(line, y, grid, carts)}
      end)
    {y, x} = drive_carts(grid, carts)
    # coordinates submitted to the puzzle web site must not have spaces!
    IO.inspect("#{x},#{y}", label: "Part 1 first crash location is")
  end

  # TODO too complex; refactor
  # execute one "tick":
  defp drive_carts(grid, carts) do
    carts = Enum.sort(carts, &(elem(&1, 0) <= elem(&2, 0)))
    driven_carts =
      Enum.reduce(carts, {carts, []}, fn (_c, {pending_a, done_a}) ->
        [cart | pending_a] = pending_a
        moved_cart =
          move_cart(cart)
          |> turn_cart(grid)
          |> update_for_crash(pending_a)
          |> update_for_crash(done_a)
        done_a = [moved_cart | done_a]
        {pending_a, done_a}
      end)
      |> elem(1)
      #|> IO.inspect(label: "driven carts")
    case Enum.filter(driven_carts, &(elem(&1, 1) == :crashed)) do
      [head | tail] ->
        {{y, x}, :crashed, _} = List.last([head | tail])
        {y, x}
      [] ->
        drive_carts(grid, driven_carts)  # tail recursion
    end
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(input_file) do
    input_file
    |> IO.inspect(label: "Part 2 #{false} is")
  end

  @doc ~S"""
  Move a cart according to its direction.

  ## Examples

      iex> MineCart.move_cart({{4, 2}, :right, :left})
      {{4, 3}, :right, :left}

      iex> MineCart.move_cart({{4, 2}, :left, :straight})
      {{4, 1}, :left, :straight}

      iex> MineCart.move_cart({{4, 2}, :up, :right})
      {{3, 2}, :up, :right}

      iex> MineCart.move_cart({{4, 2}, :down, :straight})
      {{5, 2}, :down, :straight}

  """
  def move_cart({{y, x}, :right, next_turn}),
    do: {{y, x+1}, :right, next_turn}
  def move_cart({{y, x}, :up, next_turn}),
    do: {{y-1, x}, :up, next_turn}
  def move_cart({{y, x}, :left, next_turn}),
    do: {{y, x-1}, :left, next_turn}
  def move_cart({{y, x}, :down, next_turn}),
    do: {{y+1, x}, :down, next_turn}

  @doc ~S"""
  Turn a cart according to its state (and the grid).

  TODO too many examples here; move to MineCartTest

  ## Intersection Examples

      iex> grid = %{{1, 1} => :intersect}
      iex> MineCart.turn_cart({{1, 1}, :up, :left}, grid)
      {{1, 1}, :left, :straight}

      iex> grid = %{{1, 1} => :intersect}
      iex> MineCart.turn_cart({{1, 1}, :down, :left}, grid)
      {{1, 1}, :right, :straight}

      iex> grid = %{{1, 1} => :intersect}
      iex> MineCart.turn_cart({{1, 1}, :left, :straight}, grid)
      {{1, 1}, :left, :right}

      iex> grid = %{{1, 1} => :intersect}
      iex> MineCart.turn_cart({{1, 1}, :down, :right}, grid)
      {{1, 1}, :left, :left}

      iex> grid = %{{1, 1} => :intersect}
      iex> MineCart.turn_cart({{1, 1}, :left, :right}, grid)
      {{1, 1}, :up, :left}

  ## Curve Examples

      iex> grid = %{{1, 1} => :curve_ne}
      iex> MineCart.turn_cart({{1, 1}, :left, :straight}, grid)
      {{1, 1}, :down, :straight}

      iex> grid = %{{1, 1} => :curve_ne}
      iex> MineCart.turn_cart({{1, 1}, :up, :straight}, grid)
      {{1, 1}, :right, :straight}

      iex> grid = %{{1, 1} => :curve_nw}
      iex> MineCart.turn_cart({{1, 1}, :right, :straight}, grid)
      {{1, 1}, :down, :straight}

      iex> grid = %{{1, 1} => :curve_nw}
      iex> MineCart.turn_cart({{1, 1}, :up, :straight}, grid)
      {{1, 1}, :left, :straight}

  ## Straight Examples

      iex> grid = %{{1, 1} => :horiz}
      iex> MineCart.turn_cart({{1, 1}, :left, :straight}, grid)
      {{1, 1}, :left, :straight}

      iex> grid = %{{1, 1} => :vert}
      iex> MineCart.turn_cart({{1, 1}, :down, :straight}, grid)
      {{1, 1}, :down, :straight}

  """
  def turn_cart({{y, x}, direction, next_turn}, grid) do
    #IO.inspect({{y, x}, direction, next_turn}, label: "turn_cart")
    #IO.inspect(grid[{y, x}], label: "square")
    turn_cart_for({{y, x}, direction, next_turn}, grid[{y, x}])
  end

  defp turn_cart_for({{y, x}, direction, next_turn}, :curve_ne) do
    new_direction =
      case direction do
        :up -> :right
        :left -> :down
        :down -> :left
        :right -> :up
      end
    {{y, x}, new_direction, next_turn}
  end
  defp turn_cart_for({{y, x}, direction, next_turn}, :curve_nw) do
    new_direction =
      case direction do
        :up -> :left
        :right -> :down
        :down -> :right
        :left -> :up
      end
    {{y, x}, new_direction, next_turn}
  end
  defp turn_cart_for({{y, x}, direction, next_turn}, :intersect) do
    {{y, x}, change_direction(direction, next_turn), cycle_next_turn(next_turn)}
  end
  defp turn_cart_for({{y, x}, direction, next_turn}, square)
    when square in [:horiz, :vert],
    do: {{y, x}, direction, next_turn}

  # TODO is there a circular-list mechanism that would be more elegant?
  defp change_direction(direction, :left) do
    case direction do
      :left -> :down
      :down -> :right
      :right -> :up
      :up -> :left
    end
  end
  defp change_direction(direction, :right) do
    case direction do
      :left -> :up
      :up -> :right
      :right -> :down
      :down -> :left
    end
  end
  defp change_direction(direction, :straight), do: direction

  defp cycle_next_turn(:left), do: :straight
  defp cycle_next_turn(:straight), do: :right
  defp cycle_next_turn(:right), do: :left

  @doc ~S"""
  Update a cart if it crashed with other carts.

  ## Examples

      iex> carts = [
      ...>   {{2, 2}, :up, :straight},
      ...> ]
      iex> MineCart.update_for_crash({{0, 2}, :down, :straight}, carts)
      {{0, 2}, :down, :straight}

      iex> carts = [
      ...>   {{0, 2}, :down, :straight},
      ...> ]
      iex> MineCart.update_for_crash({{2, 2}, :up, :straight}, carts)
      {{2, 2}, :up, :straight}

      iex> carts = [
      ...>   {{1, 2}, :down, :straight},
      ...> ]
      iex> MineCart.update_for_crash({{1, 2}, :up, :straight}, carts)
      {{1, 2}, :crashed, :straight}

  """
  def update_for_crash({{y, x}, direction, next_turn}, carts) do
    crashes = Enum.filter(carts, fn ({{x0, y0}, _d0, _t0}) -> {x0, y0} == {y, x} end)
              #|> IO.inspect(label: "crashes for #{x},#{y}")
    case crashes do
      [] ->
        {{y, x}, direction, next_turn}
      _ ->
        {{y, x}, :crashed, next_turn}
    end
  end
end
