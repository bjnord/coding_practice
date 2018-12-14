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
    {y, x} =
      parse_input(input_file)
      |> execute_ticks_part1()
    # coordinates submitted to the puzzle web site must not have spaces!
    IO.inspect("#{x},#{y}", label: "Part 1 first crash location is")
  end

  defp parse_input(input_file) do
    input_file
    |> File.stream!
    |> Enum.reduce({0, {%{}, []}}, fn (line, {y, {grid, carts}}) ->
      {y+1, MineCart.InputParser.parse_line(line, y, grid, carts)}
    end)
    |> elem(1)
  end

  # returns position of first cart to crash
  defp execute_ticks_part1({grid, carts}) do
    Enum.sort(carts, &(elem(&1, 0) <= elem(&2, 0)))
    |> drive_carts(grid)
    |> case do
      {driven_carts, []} ->
        execute_ticks_part1({grid, driven_carts})  # tail recursion
      {_, crashed_carts} ->
        List.first(crashed_carts)
        |> elem(0)
    end
  end

  defp drive_carts(carts, grid) do
    1..1_000_000
    |> Enum.reduce_while({carts, [], []}, fn (_c, {pending_a, done_a, crashed_a}) ->
      [cart | pending_a] = pending_a
      cart = move_cart(cart)
             |> turn_cart(grid)
      # note how we don't pass cart (self) in the list of candidates:
      case {cart_crashed_into_by(cart, pending_a ++ done_a), pending_a} do
        {nil, []} ->          # no crash, all carts now processed
          {:halt, {[cart | done_a], Enum.reverse(crashed_a)}}
        {nil, [_ | _]} ->     # no crash, carts remaining
          {:cont, {pending_a, [cart | done_a], crashed_a}}
        {crashed_cart, _} ->  # crash
          {pending_a, done_a, crashed_a} =
            move_crashed_carts([cart, crashed_cart], pending_a, done_a, crashed_a)
          if pending_a == [] do
            {:halt, {done_a, Enum.reverse(crashed_a)}}
          else
            {:cont, {pending_a, done_a, crashed_a}}
          end
      end
    end)
  end

  defp move_crashed_carts(new_crashed, pending_a, done_a, crashed_a) do
    pending_a = Enum.reject(pending_a, fn (cart) -> Enum.member?(new_crashed, cart) end)
    done_a = Enum.reject(done_a, fn (cart) -> Enum.member?(new_crashed, cart) end)
    crashed_a = new_crashed ++ crashed_a
    {pending_a, done_a, crashed_a}
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: "71,76"
  """
  def part2(input_file) do
    {y, x} =
      parse_input(input_file)
      |> execute_ticks_part2()
      |> elem(0)
    # coordinates submitted to the puzzle web site must not have spaces!
    IO.inspect("#{x},#{y}", label: "Part 2 remaining cart location is")
  end

  # returns lone surviving cart after all others have crashed
  defp execute_ticks_part2({grid, carts}) do
    driven_carts =
      Enum.sort(carts, &(elem(&1, 0) <= elem(&2, 0)))
      |> drive_carts(grid)
      |> elem(0)
    case driven_carts do
      [lone_survivor] ->
        lone_survivor
      [] ->
        # all carts crashed, none left: this only happens with example1
        # which isn't really meant to be run against puzzle part 2
        {{-1, -1}, nil, nil}
      [head | tail] ->
        execute_ticks_part2({grid, [head | tail]})  # tail recursion
    end
  end

  @doc ~S"""
  Move a cart according to its direction.

  ## Examples

      iex> MineCart.move_cart({{4, 2}, :right, :left})
      {{4, 3}, :right, :left}

      iex> MineCart.move_cart({{4, 2}, :up, :right})
      {{3, 2}, :up, :right}

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

  ## Examples

      iex> grid = %{{1, 1} => :intersect}
      iex> MineCart.turn_cart({{1, 1}, :up, :left}, grid)
      {{1, 1}, :left, :straight}

      iex> grid = %{{1, 1} => :curve_ne}
      iex> MineCart.turn_cart({{1, 1}, :left, :straight}, grid)
      {{1, 1}, :down, :straight}

      iex> grid = %{{1, 1} => :vert}
      iex> MineCart.turn_cart({{1, 1}, :down, :straight}, grid)
      {{1, 1}, :down, :straight}

  """
  def turn_cart({{y, x}, direction, next_turn}, grid) do
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
  Return cart crashed into by input cart. (Return `nil` if none.)

  ## Examples

      iex> carts = [
      ...>   {{2, 2}, :up, :straight},
      ...>   {{0, 0}, :right, :straight},
      ...> ]
      iex> MineCart.cart_crashed_into_by({{0, 2}, :down, :straight}, carts)
      nil

      iex> carts = [
      ...>   {{1, 2}, :down, :straight},
      ...>   {{2, 1}, :right, :straight},
      ...> ]
      iex> MineCart.cart_crashed_into_by({{1, 2}, :up, :straight}, carts)
      {{1, 2}, :down, :straight}

  """
  def cart_crashed_into_by({{y, x}, _direction, _next_turn}, carts) do
    # NB given the take-turns-moving nature of the puzzle, there can't be
    #    more than one
    Enum.find(carts, fn ({{x0, y0}, _d0, _t0}) -> {x0, y0} == {y, x} end)
  end
end
