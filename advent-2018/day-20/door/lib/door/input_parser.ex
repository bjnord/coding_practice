defmodule Door.InputParser do
  @doc ~S"""
  Parses the input regex.

  ## Returns

  Path tree structure

  ## Examples

      iex> Door.InputParser.parse_pattern("^$")
      %{
        0 => [],
      }

      iex> Door.InputParser.parse_pattern("^WNE$")
      %{
        0 => [:w, :n, :e],
      }

      iex> Door.InputParser.parse_pattern("^WNE(N|EE)S$")
      %{
        0 => [:w, :n, :e],
        ?A => %{0 => [:n]},
        ?B => %{0 => [:e, :e]},
        1 => %{0 => [:s]},
      }

      iex> Door.InputParser.parse_pattern("^W(N|E(SE|SW)W)E$")
      %{
        0 => [:w],
        ?A => %{0 => [:n]},
        ?B => %{
          0 => [:e],
          ?A => %{0 => [:s, :e]},
          ?B => %{0 => [:s, :w]},
          1 => %{0 => [:w]},
        },
        1 => %{0 => [:e]},
      }
  """
  @spec parse_pattern(String.t()) :: map()
  def parse_pattern(line) when is_binary(line) do
    {c, line} = String.next_grapheme(line)
    if c != "^" do
      raise "pattern must start with ^ (found '#{c}')"
    end
    reduce_pattern(%{}, line)
  end

  # populate the given "tree" (Map) with
  #  - key 0 => [:n, :s, ...]
  #      a list of direction steps to follow first
  #  - keys ?A, ?B, ?C, ... => %{...}
  #      a new "tree" (Map) for each branch leading from room
  #      (each having direction steps to follow, etc.)
  #  - key 1 => %{...}
  #      a new "tree" (Map) to follow after each branch
  @spec reduce_pattern(map(), String.t()) :: map()
  defp reduce_pattern(tree, line) when is_binary(line) do
    {tree, r_steps} =
      Stream.cycle([true])
      |> Enum.reduce_while({tree, [], line}, fn (_t, {tree, steps, line}) ->
        {c, line} = String.next_grapheme(line)
        case c do
          "$" ->
            if line != "" do
              raise "more characters found beyond $"
            end
            {:halt, {tree, steps}}
          "(" ->
            tree = reduce_branches(tree, line)
            {:halt, {tree, steps}}
          _ ->
            {:cont, {tree, [step_of(c) | steps], line}}
        end
      end)
    Map.put(tree, 0, Enum.reverse(r_steps))
  end

  # populate the given "tree" (Map) with
  #  - keys ?A, ?B, ?C, ... => %{...}
  #      a new "tree" (Map) for each branch leading from room
  #      (each having direction steps to follow, etc.)
  #  - key 1 => %{...}
  #      a new "tree" (Map) to follow after each branch
  @spec reduce_branches(map(), String.t()) :: map()
  defp reduce_branches(tree, line) do
    {b_chars, line} = split_at_rparen(line)
    tree =
      split_at_pipe(b_chars)
      |> Enum.reduce({tree, ?A}, fn (branch, {tree, i}) ->
        {Map.put(tree, i, reduce_pattern(%{}, branch <> "$")), i + 1}
      end)
      |> elem(0)
    Map.put(tree, 1, reduce_pattern(%{}, line))
  end

  defp step_of(c) do
    case c do
      "N" -> :n
      "S" -> :s
      "E" -> :e
      "W" -> :w
      _   -> raise "unknown direction '#{c}'"
    end
  end

  @doc ~S"""
  Break string into two halves at the outer right-parenthesis.

  ## Examples

      iex> Door.InputParser.split_at_rparen("N|EE)S$")
      {"N|EE", "S$"}

      iex> Door.InputParser.split_at_rparen("N|(SE|SW))E$")
      {"N|(SE|SW)", "E$"}
  """
  def split_at_rparen(line) do
    {left, right, _lpc} =
      Stream.cycle([true])
      |> Enum.reduce_while({"", line, 0}, fn (_t, {left, right, lpc}) ->
        {c, right} = String.next_grapheme(right)
        cond do
          c == "(" ->
            {:cont, {left <> c, right, lpc+1}}
          (c == ")") && (lpc > 0) ->
            {:cont, {left <> c, right, lpc-1}}
          c == ")" ->
            {:halt, {left, right, lpc}}
          true ->
            {:cont, {left <> c, right, lpc}}
        end
      end)
    {left, right}
  end

  @doc ~S"""
  Split string at outer pipes.

  ## Examples

      iex> Door.InputParser.split_at_pipe("N|EE")
      ["N", "EE"]

      iex> Door.InputParser.split_at_pipe("N|EE|")
      ["N", "EE", ""]

      iex> Door.InputParser.split_at_pipe("N|(SE|SW)")
      ["N", "(SE|SW)"]

      iex> Door.InputParser.split_at_pipe("N|(SE|SW)|")
      ["N", "(SE|SW)", ""]
  """
  def split_at_pipe(line) do
    Stream.cycle([true])
    |> Enum.reduce_while({[], "", line, 0}, fn (_t, {chunks, left, right, lpc}) ->
      {c, right} = String.next_grapheme(right)
      cond do
        (right == "") && (c == ")") && (lpc == 1) ->
          {:halt, [left <> c | chunks]}
        (right == "") && (lpc > 0) ->
          raise "missing expected rparen (left=#{left}, right=#{right}, lpc=#{lpc})"
        (right == "") && c == "|" ->
          {:halt, ["", left | chunks]}
        right == "" ->
          {:halt, [left <> c | chunks]}
        c == "(" ->
          {:cont, {chunks, left <> c, right, lpc+1}}
        c == ")" ->
          {:cont, {chunks, left <> c, right, lpc-1}}
        (c == "|") && (lpc > 0) ->
          {:cont, {chunks, left <> c, right, lpc}}
        c == "|" ->
          {:cont, {[left | chunks], "", right, 0}}
        true ->
          {:cont, {chunks, left <> c, right, lpc}}
      end
    end)
    |> Enum.reverse()
  end
end
