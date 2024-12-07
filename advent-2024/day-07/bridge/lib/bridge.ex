defmodule Bridge do
  @moduledoc """
  Documentation for `Bridge`.
  """

  import Bridge.Parser
  import History.CLI

  @doc ~S"""
  Is the given equation solvable?

  ## Parameters

  - `eq`: the equation

  ## Examples
      iex> solvable?({190, [10, 19]})
      true
      iex> solvable?({3267, [81, 40, 27]})
      true
      iex> solvable?({292, [11, 6, 16, 20]})
      true
  """
  # FIXME `{integer(), [integer()]}` as type `equation()`
  @spec solvable?({integer(), [integer()]}) :: [[atom() | integer()]]
  def solvable?({total, [v | t]}) do
    form_equations(t, [v])
    |> my_flatten()
    |> Enum.any?(&(operable?(total, &1)))
  end

  defp form_equations([], elements), do: elements
  defp form_equations([v | t], elements) do
    [
      [v, :+ | elements],
      [v, :* | elements],
    ]
    |> Enum.map(&(form_equations(t, &1)))
  end

  defp my_flatten([a, b]) do
    if length(a) == 2 do
      [my_flatten(a), my_flatten(b)]
      |> Enum.concat()
    else
      [Enum.reverse(a), Enum.reverse(b)]
    end
  end

  defp operable?(total, [a]), do: a == total
  defp operable?(total, [a, op, b | t]) do
    case op do
      :+ -> operable?(total, [a + b | t])
      :* -> operable?(total, [a * b | t])
    end
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
    parse_input_file(input_path)
    |> Enum.filter(&Bridge.solvable?/1)
    |> Enum.map(&(elem(&1, 0)))
    |> Enum.sum()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
