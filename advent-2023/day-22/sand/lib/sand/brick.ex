defmodule Sand.Brick do
  @moduledoc """
  Brick functions for `Sand`.
  """

  defstruct n: 0, from: %{x: 0, y: 0, z: 0}, to: %{x: 0, y: 0, z: 0}, supported_by: []

  @doc ~S"""
  Calculate new brick positions after they fall as far as they can.

  ## Parameters

  - `bricks`: the list of `Brick`s

  Returns the list of updated `Brick`s.
  """
  def drop(bricks) do
    bricks
    |> Enum.sort(&sorter/2)
    |> drop([])
  end

  # sort on highest coord values (`to`), with Z coord most significant
  defp sorter(a, b) do
    (a.to.z < b.to.z) ||
      ((a.to.z == b.to.z) && (a.to.x < b.to.x)) ||
      ((a.to.z == b.to.z) && (a.to.x == b.to.x) && (a.to.y <= b.to.y))
  end

  defp drop([], settled_bricks), do: Enum.reverse(settled_bricks)
  defp drop([brick | rem_bricks], settled_bricks) do
    int_bricks =
      settled_bricks
      |> Enum.filter(fn sb -> would_intersect?(sb, brick) end)
    int_z = Enum.map(int_bricks, fn ib -> ib.to.z end)
    new_z = if int_z == [], do: 1, else: Enum.max(int_z) + 1
    settled_brick =
      drop_to(brick, new_z)
      |> then(fn brick ->
        %Sand.Brick{brick | supported_by: supported_by(int_bricks, new_z - 1)}
      end)
    drop(rem_bricks, [settled_brick | settled_bricks])
  end

  # NOTE order matters: `b` is dropped to overlap Z coord of `a`
  defp would_intersect?(a, b) do
    dropped_b =
      if b.from.z > a.to.z do
        drop_to(b, a.to.z)
      else
        b
      end
    intersects?(a, dropped_b)
  end

  defp supported_by(int_bricks, z) do
    int_bricks
    |> Enum.filter(fn ib -> ib.to.z >= z end)
    |> Enum.map(fn ib -> ib.n end)
  end

  @doc ~S"""
  Update brick position by dropping it to the specified Z coordinate.

  ## Parameters

  - `brick`: the `Brick` to drop
  - `z`: the new Z coordinate

  Returns the updated `Brick`.

  ## Examples
      iex> g = %Sand.Brick{n: 7, from: %{x: 1, y: 1, z: 8}, to: %{x: 1, y: 1, z: 9}}
      iex> drop_to(g, 5)
      %Sand.Brick{n: 7, from: %{x: 1, y: 1, z: 5}, to: %{x: 1, y: 1, z: 6}}
  """
  def drop_to(brick, z) do
    if brick.from.z > brick.to.z do
      raise "drop_to: swapped Z-coord #{brick.from.z}-#{brick.to.z}"
    end
    if z > brick.from.z do
      raise "drop_to: rising Z #{brick.from.z} -> #{z}"
    end
    dz = brick.from.z - z
    %Sand.Brick{
      n:    brick.n,
      from: %{brick.from | z: brick.from.z - dz},
      to:   %{brick.to   | z: brick.to.z   - dz},
    }
  end

  @doc ~S"""
  Do the specified bricks intersect?

  ## Parameters

  - `a`: the first `Brick`
  - `b`: the second `Brick`

  Returns a boolean.

  ## Examples
      iex> b = %Sand.Brick{n: 2, from: %{x: 0, y: 0, z: 2}, to: %{x: 2, y: 0, z: 2}}
      iex> c = %Sand.Brick{n: 3, from: %{x: 0, y: 2, z: 2}, to: %{x: 2, y: 2, z: 2}}
      iex> intersects?(b, c)
      false
      iex> c = %Sand.Brick{n: 3, from: %{x: 0, y: 2, z: 2}, to: %{x: 2, y: 2, z: 2}}
      iex> d = %Sand.Brick{n: 4, from: %{x: 0, y: 0, z: 2}, to: %{x: 0, y: 2, z: 2}}
      iex> intersects?(c, d)
      true
  """
  def intersects?(a, b) do
    [:x, :y, :z]
    |> Enum.all?(fn c -> intersects?(a.from[c], a.to[c], b.from[c], b.to[c]) end)
  end

  defp intersects?(from_a, to_a, from_b, to_b) do
    cond do
      from_a > to_a ->
        raise "swapped A #{from_a}-#{to_a}"
      from_b > to_b ->
        raise "swapped B #{from_b}-#{to_b}"
      (from_a < from_b) && (to_a < from_b) ->
        false
      (from_b < from_a) && (to_b < from_a) ->
        false
      true ->
        true
    end
  end

  def dump(bricks) do
    grid_x = Enum.flat_map(bricks, &coord_x/1)
             |> grid()
    grid_y = Enum.flat_map(bricks, &coord_y/1)
             |> grid()
    IO.puts(" x    y  ")
    for z <- 19..1, do: dump_row(grid_x, grid_y, z)
    IO.puts("---  ---")
  end

  def coord_x(brick), do: coord(brick, :x)
  def coord_y(brick), do: coord(brick, :y)

  def coord(brick, dim) do
    for z <- brick.from.z..brick.to.z,
        xy <- brick.from[dim]..brick.to[dim] do
      {brick_ch(brick.n), {z, xy}}
    end
  end

  def brick_ch(n) do
    cond do
      (n >=  1) && (n <= 26) -> ?A + n - 1
      (n >= 27) && (n <= 52) -> ?a + n - 27
      (n >= 53) && (n <= 61) -> ?1 + n - 53
      true                   -> ?*
    end
  end

  def grid(coord) do
    coord
    |> Enum.reduce(%{}, fn {ch, pos}, acc ->
      Map.update(acc, pos, ch, fn _ -> ?? end)
    end)
  end

  defp dump_row(grid_x, grid_y, z) do
    line_x =
      0..2
      |> Enum.reduce([], fn x, line ->
        [tile_at(grid_x, z, x) | line]
      end)
      |> Enum.reverse()
      |> List.to_string()
    line_y =
      0..2
      |> Enum.reduce([], fn y, line ->
        [tile_at(grid_y, z, y) | line]
      end)
      |> Enum.reverse()
      |> List.to_string()
    IO.puts("#{line_x}  #{line_y}")
  end

  defp tile_at(grid, z, xy) do
    Map.get(grid, {z, xy}, ?.)
  end

  @doc ~S"""
  Determine which bricks are supporting which other bricks.

  ## Parameters

  - `bricks`: the list of `Brick`s

  Returns a map as follows:
  - key: brick number
  - value: list of brick numbers it supports
  """
  def supports(bricks) do
    supports0 =
      bricks
      |> Enum.reduce(%{}, fn brick, acc -> Map.put(acc, brick.n, []) end)
    bricks
    |> Enum.flat_map(fn brick ->
      brick.supported_by
      |> Enum.map(fn sbn -> {sbn, brick.n} end)
    end)
    |> Enum.reduce(supports0, fn {by_n, n}, acc ->
      %{acc | by_n => [n | acc[by_n]]}
    end)
  end

  @doc ~S"""
  Determine which bricks can be safely disintegrated.

  ## Parameters

  - `bricks`: the list of `Brick`s

  Returns a list of brick numbers.
  """
  def disintegratable(bricks) do
    supported_by =
      bricks
      |> Enum.reduce(%{}, fn brick, acc ->
        Map.put(acc, brick.n, brick.supported_by)
      end)
    supports = supports(bricks)
    bricks
    |> Enum.reject(fn brick ->
      # are any of the bricks I support, supported by me alone?
      supports[brick.n]
      |> Enum.any?(fn sn -> lone_list?(supported_by[sn]) end)
    end)
    |> Enum.map(fn brick -> brick.n end)
  end

  def lone_list?([]), do: false
  def lone_list?([_n]), do: true
  def lone_list?([_n | _rem]), do: false
end
