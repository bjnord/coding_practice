defmodule Robot do
  @moduledoc """
  Documentation for `Robot`.
  """

  import Robot.Parser
  import History.CLI

  @doc ~S"""
  Calculate robot's position after a number of seconds.

  ## Examples
      iex> location_after({{4, 2}, {-3, 2}}, {7, 11}, 5)
      {3, 1}
  """
  def location_after({{y, x}, {dy, dx}}, {dim_y, dim_x}, secs) do
    {
      neg_mod(y + dy * secs, dim_y),
      neg_mod(x + dx * secs, dim_x),
    }
  end

  defp neg_mod(n, m) when n > 0, do: rem(n, m)
  defp neg_mod(n, m) when n < 0, do: rem(rem(n, m) + m, m)
  defp neg_mod(0, _m), do: 0

  #def location_after_by_adding(robot, dim, secs) do
  #  1..secs
  #  |> Enum.reduce(robot, fn _, robot ->
  #    step(robot, dim)
  #  end)
  #  |> elem(0)
  #end

  #def step({{y, x}, {dy, dx}}, {dim_y, dim_x}) do
  #  y = y + dy
  #  y =
  #    cond do
  #      y >= dim_y ->
  #        y - dim_y
  #      y < 0 ->
  #        y + dim_y
  #      true ->
  #        y
  #    end
  #  x = x + dx
  #  x =
  #    cond do
  #      x >= dim_x ->
  #        x - dim_x
  #      x < 0 ->
  #        x + dim_x
  #      true ->
  #        x
  #    end
  #  {{y, x}, {dy, dx}}
  #end

  def quadrant_count(locations, dim) do
    locations
    |> Enum.reduce(%{}, fn pos, acc ->
      Map.update(acc, pos, 1, &(&1 + 1))
    end)
    |> Enum.map(fn {pos, n} ->
      # TODO extract to function
      q = quadrant_of(pos, dim)
      if q do
        {q, n}
      else
        nil
      end
    end)
    |> Enum.reject(&(&1 == nil))
    |> Enum.group_by(&(elem(&1, 0)), &(elem(&1, 1)))
    |> Enum.map(fn {_q, list} -> Enum.sum(list) end)
  end

  def safety_factor(locations, dim) do
    locations
    |> quadrant_count(dim)
    |> Enum.product()
  end

  def safety_factors(robots, dim, seconds) do
    1..seconds
    |> Enum.reduce({robots, []}, fn s, {robots, acc} ->
      locations =
        robots
        |> Enum.map(&(Robot.location_after(&1, dim, 1)))
      safety_factor =
        locations
        |> Robot.safety_factor(dim)
      robots =
        locations
        |> Enum.zip(robots)
        |> Enum.map(fn {{y, x}, {_, {dy, dx}}} ->
          {{y, x}, {dy, dx}}
        end)
      {robots, [{s, safety_factor} | acc]}
    end)
    |> elem(1)
    |> Enum.reverse()
  end

  @doc ~S"""
  Calculate robot's quadrant.

  ## Examples
      iex> quadrant_of({4, 2}, {7, 11})
      3
      iex> quadrant_of({3, 2}, {7, 11})
      nil
      iex> quadrant_of({2, 2}, {7, 11})
      1
      iex> quadrant_of({4, 6}, {7, 11})
      4
      iex> quadrant_of({2, 6}, {7, 11})
      2
  """
  def quadrant_of({y, x}, {dim_y, dim_x}) do
    cond do
      y == div(dim_y - 1, 2) ->
        nil
      x == div(dim_x - 1, 2) ->
        nil
      y < div(dim_y - 1, 2) && x < div(dim_x - 1, 2) ->
        1
      y < div(dim_y - 1, 2) && x > div(dim_x - 1, 2) ->
        2
      y > div(dim_y - 1, 2) && x < div(dim_x - 1, 2) ->
        3
      y > div(dim_y - 1, 2) && x > div(dim_x - 1, 2) ->
        4
    end
  end

  def create_pnm(robots, second, {dim_y, dim_x}) do
    pixels =
      robots
      |> Enum.reduce(%{}, fn {pos, _vel}, acc ->
        Map.update(acc, pos, 1, &(&1 + 1))
      end)
    header = "P1\n#{dim_x} #{dim_y}\n"
    content =
      0..(dim_y - 1)
      |> Enum.map(&(pnm_line_y(pixels, &1, dim_x)))
      |> Enum.join("\n")
    n0 = Integer.to_string(second)
         |> String.pad_leading(8, "0")
    filename = "images/sec#{n0}.pnm"
    File.write(filename, header <> content)
  end

  defp pnm_line_y(pixels, y, dim_x) do
    0..(dim_x - 1)
    |> Enum.map(fn x ->
      cond do
        Map.get(pixels, {y, x}) -> [?1, 32]
        true                    -> [?0, 32]
      end
    end)
    |> List.flatten()
    |> List.to_string()
  end

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_path) do
    dim = {103, 101}
    parse_input_file(input_path)
    |> Enum.map(&(Robot.location_after(&1, dim, 100)))
    |> Robot.safety_factor(dim)
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    6644  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
