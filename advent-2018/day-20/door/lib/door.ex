defmodule Door do
  @moduledoc """
  Documentation for Door.
  """

  import Door.CLI
  import Door.InputParser
  import Door.Path

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1),
      do: part1(input_file, opts)
    if Enum.member?(opts[:parts], 2),
      do: part2(input_file, opts)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Correct Answer

  - Part 1 answer is: 3839
  """
  def part1(input_file, _opts \\ []) do
    {{y, x}, doors} =
      input_file
      |> read_pattern()
      |> parse_pattern()
      |> reversed_shortest_paths()
      |> Enum.max_by(fn ({_k, v}) ->
        Enum.count(v)
      end)
    IO.inspect(Enum.count(doors), label: "Part 1 room #{y},#{x} doors passed")
  end

  defp read_pattern(input_file) do
    {:ok, file} = File.open(input_file, [:read])
    line = IO.read(file, :line)
    File.close(file)
    String.trim(line)
  end

  @doc """
  Process input file and display part 2 solution.

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(input_file, _opts \\ []) do
    ans_type = "???"
    input_file
    |> IO.inspect(label: "Part 2 #{ans_type} is")
  end

  @doc """
  Hello world.

  ## Examples

      iex> Door.hello
      :world

  """
  def hello do
    :world
  end
end
