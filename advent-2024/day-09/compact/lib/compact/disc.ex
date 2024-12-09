defmodule Compact.Disc do
  @moduledoc """
  Compact disc functions.
  """

  require Logger

  defstruct blocks: %{}, n_blocks: 0, files: [],  spaces: []

  @type t :: %__MODULE__{
    blocks: %{integer() => integer()},
    n_blocks: integer(),
    files: [{integer(), integer(), integer()}],
    spaces: [{integer(), integer()}],
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
    {files, spaces, _n_blocks} =
      layout
      |> Enum.reduce({[], [], 0}, fn entry, {files, spaces, n_blocks} ->
        case entry do
          {:file, size, id} ->
            {
              [{n_blocks, size, id} | files],
              spaces,
              n_blocks + size,
            }
          {:space, size} ->
            {
              files,
              [{n_blocks, size} | spaces],
              n_blocks + size,
            }
        end
      end)
    %__MODULE__{
      blocks: blocks,
      n_blocks: n_blocks,
      files: files,
      spaces: Enum.reverse(spaces),
    }
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

  defp debug(), do: !!System.get_env("DEBUG")

  @spec compact(__MODULE__.t()) :: __MODULE__.t()
  def compact(disc) do
    compact(disc, next_free(disc, 0), last_used(disc, disc.n_blocks - 1))
  end

  defp compact(disc, free_n, used_n) when free_n > used_n, do: disc
  defp compact(disc, free_n, used_n) do
    blocks =
      disc.blocks
      |> Map.put(free_n, disc.blocks[used_n])
      |> Map.delete(used_n)
    disc = %__MODULE__{disc | blocks: blocks}
    if debug(), do: Logger.debug(__MODULE__.to_string(disc))
    compact(disc, next_free(disc, free_n + 1), last_used(disc, used_n - 1))
  end

  defp next_free(disc, n) do
    cond do
      n >= disc.n_blocks ->
        raise "next_free overrun"
      Map.get(disc.blocks, n) == nil ->
        n
      true ->
        next_free(disc, n + 1)
    end
  end

  defp last_used(disc, n) do
    cond do
      n < 0 ->
        raise "last_used underrun"
      Map.get(disc.blocks, n) != nil ->
        n
      true ->
        last_used(disc, n - 1)
    end
  end

  def checksum(disc) do
    0..(disc.n_blocks - 1)
    |> Enum.map(&(checksum_block(disc, &1)))
    |> Enum.sum()
  end

  defp checksum_block(disc, k) do
    if disc.blocks[k] do
      disc.blocks[k] * k
    else
      0
    end
  end

  @spec compact2(__MODULE__.t()) :: __MODULE__.t()
  def compact2(disc) do
    compact2(disc, disc.files, disc.spaces)
  end

  defp compact2(disc, [], _spaces), do: disc
  defp compact2(disc, files, spaces) do
    [{_f_loc, f_size, _f_id} = file | files] = files
    space_i =
      Enum.find_index(spaces, fn {_s_loc, s_size} ->
        s_size >= f_size
      end)
    if space_i do
      space = Enum.at(spaces, space_i)
      {disc, new_space} = move_file(disc, file, space)
      # costly! h/t <https://stackoverflow.com/a/66696910/291754>
      replace_at =
        fn list, index, value ->
          list
          |> Enum.with_index()
          |> Enum.map(fn
            {_, ^index} -> value  # match index
            {value, _}  -> value  # anything else
          end)
        end
      compact2(disc, files, replace_at.(spaces, space_i, new_space))
    else
      #IO.puts("don't move f_id:#{f_id} f_loc:#{f_loc} f_size:#{f_size}")
      compact2(disc, files, spaces)
    end
  end

  defp move_file(disc, {f_loc, _, _}, {s_loc, _} = space) when s_loc >= f_loc do
    #IO.puts("don't slide f_id:#{f_id} f_loc:#{f_loc}")
    # don't move file forwards
    {disc, space}
  end
  defp move_file(disc, {f_loc, f_size, _f_id}, {s_loc, s_size}) do
    #IO.puts("move f_id:#{f_id} f_loc:#{f_loc} f_size:#{f_size} to s_loc:#{s_loc} s_size:#{s_size}")
    blocks =
      f_loc..(f_loc + f_size - 1)
      |> Enum.reduce({disc.blocks, s_loc}, fn from, {blocks, to} ->
        {
          Map.put(blocks, to, blocks[from]) |> Map.delete(from),
          to + 1
        }
      end)
      |> elem(0)
    disc = %__MODULE__{disc | blocks: blocks}
    new_space = {s_loc + f_size, s_size - f_size}
    {disc, new_space}
  end
end
