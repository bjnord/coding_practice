defmodule Tree do
  @moduledoc """
  Documentation for Tree.
  """

  defp abort(message, excode) do
    IO.puts(:stderr, message)
    System.halt(excode)
  end

  @doc """
  Process input file and display part 1 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 1 answer is: 41760
  """
  def part1(argv) do
    argv
    |> input_file
    |> File.read!
    |> parse_integers
    |> build_tree
    |> meta_sum
    |> IO.inspect(label: "Part 1 metadata sum is")
  end

  @doc """
  Parse string to list of integers.

  ## Parameters

  - str: The string

  ## Returns

  The list of integers
  """
  def parse_integers(str) do
    str
    |> String.trim
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  defp meta_sum({children, metas}) do
    child_sum = children
                |> Enum.reduce(0, fn (child, acc) -> acc + meta_sum(child) end)
    child_sum + Enum.sum(metas)
  end

  @doc """
  Process input file and display part 2 solution.

  ## Parameters

  - argv: Command-line arguments (should be name of input file)

  ## Correct Answer

  - Part 2 answer is: ...
  """
  def part2(argv) do
    argv
    |> input_file
    |> File.read!
    |> parse_integers
  end

  @doc """
  Get name of input file from command-line arguments.

  ## Parameters

  - argv: Command-line arguments

  ## Returns

  Input filename (or aborts if argv invalid)
  """
  def input_file(argv) do
    case argv do
      [filename] -> filename
      _          -> abort('Usage: sleigh filename', 64)
    end
  end

  @doc """
  Reduce input list to node tree structure. The input takes the form:

  ```
  n_children n_meta [child_1] [child_2] ... [child_n] meta_1 meta_2 ... meta_n
  ```

  where each `[child_x]` is a nested example of the same form.

  ## Parameters

  - input: Input values (list of integers)

  ## Returns

  Node structure in the form {[<children>], [<metas>]}
  """
  def build_tree(input) do
    {children, metas, remainder} = build_node(input)
    if remainder != [] do
      raise "non-empty remainder: implementation or input error?"
    end
    {children, metas}
  end

  defp build_node([n_children | [n_meta | input]]) do
    #IO.inspect(input, label: "build_node: initial input")
    {children, input} = build_children(n_children, input)
                        #|> IO.inspect(label: "> built children(#{n_children}) + remaining input")
    {metas, input} = Enum.split(input, n_meta)
                     #|> IO.inspect(label: "> extracted metas(#{n_meta}) + remaining input")
    {Enum.reverse(children), metas, input}
  end

  defp build_children(0, input) do
    {[], input}
  end

  defp build_children(n_children, input) do
    1..n_children
    |> Enum.reduce({[], input}, fn (_child_n, {children, remainder}) ->
      {child, metas, remainder} = build_node(remainder)
                                  #|> IO.inspect(label: "build_tree result")
      {[{child, metas} | children], remainder}
    end)
  end
end
