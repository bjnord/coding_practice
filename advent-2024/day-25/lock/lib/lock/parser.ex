defmodule Lock.Parser do
  @moduledoc """
  Parsing for `Lock`.
  """

  @type lk_type() :: :lock | :key
  @type lock_or_key() :: {lk_type(), [{integer(), integer()}]}

  @doc ~S"""
  Parse an input file.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a list of lock-or-key
  """
  @spec parse_input_file(String.t()) :: [lock_or_key()]
  def parse_input_file(path) do
    path
    |> File.read!()
    |> parse_input_string()
  end

  @doc ~S"""
  Parse an input string.

  ## Parameters

  - `input`: the puzzle input

  ## Returns

  a list of lock-or-key
  """
  @spec parse_input_string(String.t()) :: [lock_or_key()]
  def parse_input_string(input) do
    input
    |> String.split("\n\n", trim: true)
    |> Enum.map(&parse_lock_or_key/1)
  end

  @doc ~S"""
  Parse a block of input lines containing a lock or key.

  ## Parameters

  - `line`: the puzzle input line

  ## Returns

  a lock-or-key

  ## Examples
      iex> parse_lock_or_key("###\n#.#\n#..\n...\n")
      {:lock, [{2, 0b1110}, {0, 0b1000}, {1, 0b1100}]}
      iex> parse_lock_or_key("...\n.#.\n.##\n###\n")
      {:key, [{0, 0b0001}, {2, 0b0111}, {1, 0b0011}]}
  """
  @spec parse_lock_or_key(String.t()) :: lock_or_key()
  def parse_lock_or_key(lock_or_key) do
    lines =
      lock_or_key
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_charlist/1)
    _max_height = Enum.count(lines) - 2
    {obj_type, n_slots} = obj_type(hd(lines))
    {obj_type, height_binary(lines, n_slots)}
  end

  defp obj_type([?# | rest]), do: {:lock, length(rest) + 1}
  defp obj_type([?. | rest]), do: {:key, length(rest) + 1}

  defp height_binary(lines, n_slots) do
    lines
    |> Enum.reduce(List.duplicate({-1, 0b0}, n_slots), fn line, slots ->
      Enum.zip(line, slots)
      |> Enum.map(fn {ch, {height, bitmap}} ->
        case ch do
          ?# ->
            {height + 1, bitmap * 2 + 1}
          ?. ->
            {height, bitmap * 2}
        end
      end)
    end)
  end
end
