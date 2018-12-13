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
    {x, y} = drive_carts(grid, carts)
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
      [first_crashed_cart | _tail] ->
        {{x, y}, :crashed, _} = first_crashed_cart
        {x, y}
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

      iex> MineCart.move_cart({{2, 4}, :right, :left})
      {{3, 4}, :right, :left}

      iex> MineCart.move_cart({{2, 4}, :left, :straight})
      {{1, 4}, :left, :straight}

      iex> MineCart.move_cart({{2, 4}, :up, :right})
      {{2, 3}, :up, :right}

      iex> MineCart.move_cart({{2, 4}, :down, :straight})
      {{2, 5}, :down, :straight}

  """
  def move_cart({{x, y}, :right, next_turn}),
    do: {{x+1, y}, :right, next_turn}
  def move_cart({{x, y}, :up, next_turn}),
    do: {{x, y-1}, :up, next_turn}
  def move_cart({{x, y}, :left, next_turn}),
    do: {{x-1, y}, :left, next_turn}
  def move_cart({{x, y}, :down, next_turn}),
    do: {{x, y+1}, :down, next_turn}

  @doc ~S"""
  Turn a cart according to its state (and the grid).

  TODO too many examples here; move to MineCartTester

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
  def turn_cart({{x, y}, direction, next_turn}, grid) do
    #IO.inspect({{x, y}, direction, next_turn}, label: "turn_cart")
    #IO.inspect(grid[{x, y}], label: "square")
    turn_cart_for({{x, y}, direction, next_turn}, grid[{x, y}])
  end

  # FIXME elide "square" except the "in [a, b]" one
  defp turn_cart_for({{x, y}, direction, next_turn}, square) when square == :curve_ne do
    new_direction =
      case direction do
        :up -> :right
        :left -> :down
        :down -> :left
        :right -> :up
      end
    {{x, y}, new_direction, next_turn}
  end
  defp turn_cart_for({{x, y}, direction, next_turn}, square) when square == :curve_nw do
    new_direction =
      case direction do
        :up -> :left
        :right -> :down
        :down -> :right
        :left -> :up
      end
    {{x, y}, new_direction, next_turn}
  end
  defp turn_cart_for({{x, y}, direction, next_turn}, square) when square == :intersect do
    {{x, y}, change_direction(direction, next_turn), cycle_next_turn(next_turn)}
  end
  defp turn_cart_for({{x, y}, direction, next_turn}, square) when square in [:horiz, :vert],
    do: {{x, y}, direction, next_turn}

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
      iex> MineCart.update_for_crash({{2, 0}, :down, :straight}, carts)
      {{2, 0}, :down, :straight}

      iex> carts = [
      ...>   {{2, 0}, :down, :straight},
      ...> ]
      iex> MineCart.update_for_crash({{2, 2}, :up, :straight}, carts)
      {{2, 2}, :up, :straight}

      iex> carts = [
      ...>   {{2, 1}, :down, :straight},
      ...> ]
      iex> MineCart.update_for_crash({{2, 1}, :up, :straight}, carts)
      {{2, 1}, :crashed, :straight}

  """
  def update_for_crash({{x, y}, direction, next_turn}, carts) do
    crashes = Enum.filter(carts, fn ({{x0, y0}, _d0, _t0}) -> {x0, y0} == {x, y} end)
              #|> IO.inspect(label: "crashes for #{x},#{y}")
    case crashes do
      [] ->
        {{x, y}, direction, next_turn}
      _ ->
        {{x, y}, :crashed, next_turn}
    end
  end
end
