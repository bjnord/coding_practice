defmodule Compact.Parser do
  @moduledoc """
  Parsing for `Compact`.
  """

  @type layout() :: [{:file, integer(), integer()} | {:space, integer()}]

  @doc ~S"""
  Parse an input file.

  See `parse_input_string/1` for details.

  ## Parameters

  - `path`: the puzzle input file path

  ## Returns

  a file/space layout list
  """
  @spec parse_input_file(String.t()) :: layout()
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

  a file/space layout list
  """
  @spec parse_input_string(String.t()) :: layout()
  def parse_input_string(input) do
    input
    |> String.trim_trailing()
    |> String.to_charlist()
    |> Enum.reduce({:file, 0, []}, fn ch, {type, id, acc} ->
      {this, new_type, new_id} =
        case type do
          :file  -> {{:file, ch - ?0, id}, :space, id + 1}
          :space -> {{:space, ch - ?0}, :file, id}
        end
      {new_type, new_id, [this | acc]}
    end)
    |> elem(2)
    |> Enum.reverse()
  end
end
