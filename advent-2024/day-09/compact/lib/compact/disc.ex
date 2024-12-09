defmodule Compact.Disc do
  @moduledoc """
  Compact disc functions.
  """

  defstruct blocks: %{}, n_blocks: 0

  @type t :: %__MODULE__{
    blocks: %{integer() => integer()},
    n_blocks: integer(),
  }

  @spec create(String.t()) :: __MODULE__.t()
  def create(layout) do
    {blocks, n_blocks} =
      layout
      |> Enum.reduce({%{}, 0}, fn entry, {blocks, n_blocks} ->
        case entry do
          {:file, size, id} ->
            0..(size - 1)
            |> Enum.reduce({blocks, n_blocks}, fn b, {acc, n} ->
              {Map.put(acc, b + n_blocks, id), n + 1}
            end)
          {:space, size} ->
            {blocks, n_blocks + size}
        end
      end)
    %__MODULE__{blocks: blocks, n_blocks: n_blocks}
  end

  @spec to_string(__MODULE__.t()) :: String.t()
  def to_string(disc) do
    0..(disc.n_blocks - 1)
    |> Enum.map(&(to_char(disc, &1)))
    |> List.to_string()
  end

  defp to_char(disc, k) do
    if disc.blocks[k] do
      disc.blocks[k] + ?0
    else
      ?.
    end
  end
end
