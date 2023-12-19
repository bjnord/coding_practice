defmodule Parts.Parser do
  @moduledoc """
  Parsing for `Parts`.
  """

  @doc ~S"""
  Parse the input file.

  Returns a tuple with these elements:
  - `workflows`: the workflows (map)
  - `parts`: the parts (list of keyword maps)
  """
  def parse_input(input_file, _opts \\ []) do
    File.read!(input_file)
    |> parse_input_string()
  end

  @doc ~S"""
  Parse input as a block string.

  Returns a tuple with these elements:
  - `workflows`: the workflows (map)
  - `parts`: the parts (list of keyword maps)
  """
  def parse_input_string(input, _opts \\ []) do
    [workflows_block, parts_block] =
      input
      |> String.split("\n\n", trim: true)
    {
      parse_workflows(workflows_block),
      parse_parts(parts_block),
    }
  end

  defp parse_workflows(block) do
    block
    |> String.trim_trailing()
    |> String.split("\n")
    |> Enum.map(&parse_workflow_line/1)
    |> Enum.into(%{})
  end

  defp parse_parts(block) do
    block
    |> String.trim_trailing()
    |> String.split("\n")
    |> Enum.map(&parse_part_line/1)
  end

  @doc ~S"""
  Parse an input line containing a part description.

  Returns a keyword map representing the part.

  ## Examples
      iex> parse_part_line("{x=787,m=2655,a=1222,s=2876}\n")
      %{x: 787, m: 2655, a: 1222, s: 2876}
  """
  def parse_part_line(line) do
    line
    |> String.trim_trailing()
    |> then(fn s ->
      String.slice(s, 1..(String.length(s) - 2))
    end)
    |> String.split(",")
    |> Enum.map(fn term ->
      [attr, value] = String.split(term, "=")
      {
        String.to_atom(attr),
        String.to_integer(value),
      }
    end)
    |> Enum.into(%{})
  end

  @doc ~S"""
  Parse an input line containing a workflow description.

  Returns a tuple with these elements:
  - the workflow name (atom)
  - a list of rules representing the workflow

  ## Examples
      iex> parse_workflow_line("px{a<2006:qkq,m>2090:A,rfg}\n")
      {:px, [{:a, ?<, 2006, :qkq}, {:m, ?>, 2090, :accept}, :rfg]}
  """
  def parse_workflow_line(line) do
    [name, rest] = String.split(line, "{")
    [rules | _] = String.split(rest, "}")
    {
      String.to_atom(name),
      Enum.map(String.split(rules, ","), &parse_workflow_rule/1),
    }
  end

  defp parse_workflow_rule("A"), do: :accept
  defp parse_workflow_rule("R"), do: :reject
  defp parse_workflow_rule(rule) do
    if Regex.match?(~r/^\w+$/, rule) do
      String.to_atom(rule)
    else
      [_, attr, op, value, next] = Regex.run(~r/^(\w+)(.)(\d+):(\w+)$/, rule)
      {
        String.to_atom(attr),
        List.first(String.to_charlist(op)),
        String.to_integer(value),
        parse_next(next),
      }
    end
  end

  defp parse_next("A"), do: :accept
  defp parse_next("R"), do: :reject
  defp parse_next(next), do: String.to_atom(next)
end
