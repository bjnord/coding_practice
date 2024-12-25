defmodule Wire.Dumper do
  @moduledoc """
  Documentation for `Wire.Dumper`.
  """

  import Wire, only: [swap: 2, swap_list: 1, word_width: 1, xyz_wire?: 1, z_wire?: 1]
  alias Wire.Adder
  alias Wire.Deobfuscator

  def dump_adders(diagram) do
    diagram = swap(diagram, swap_list(diagram))
    catalog = Deobfuscator.build_catalog(diagram)
    dump("log/dump.out", diagram, catalog, both: true)
    #
    adder_diagram =
      word_width(diagram)
      |> Adder.generate()
    dump("log/adder.out", adder_diagram, {%{}, %{}})
  end

  def dump(path, diagram, {_f_mapping, mapping}, opts \\ []) do
    {:ok, f} = File.open(path, [:write])
    IO.binwrite(f, "--\n")
    Map.keys(diagram)
    |> Enum.filter(&z_wire?/1)
    |> Enum.sort()
    |> Enum.reduce(%{}, fn wire, seen ->
      IO.binwrite(f, "#{wire}\n")
      dump_subtree(f, diagram, Map.get(diagram, wire), 3, mapping, seen, opts)
    end)
    IO.binwrite(f, "--\n")
    File.close(f)
  end

  defp dump_subtree(f, _diagram, value = rhs, indent, _mapping, seen, _opts) when is_integer(rhs) do
    Integer.to_string(value)
    |> String.pad_leading(indent, " ")
    |> then(fn s -> IO.binwrite(f, "#{s}\n") end)
    seen
  end
  defp dump_subtree(f, diagram, {wire1, gate, wire2} = _rhs, indent, mapping, seen, opts) do
    {deob_wire1, deob_len1} = deobfuscate_wire(mapping, wire1, opts)
    {deob_wire2, deob_len2} = deobfuscate_wire(mapping, wire2, opts)
    {{wire1, deob_wire1, deob_len1}, {wire2, deob_wire2, deob_len2}} =
      flop_ops({wire1, deob_wire1, deob_len1}, {wire2, deob_wire2, deob_len2})
    #
    seen =
      if Map.get(seen, wire1) do
        String.pad_leading(deob_wire1, deob_len1 + indent, " ")
        |> then(fn s -> s <> " #{gate}" end)
        |> then(fn s -> IO.binwrite(f, "#{s}\n") end)
        seen
      else
        String.pad_leading(deob_wire1, deob_len1 + indent, " ")
        |> then(fn s -> s <> " #{gate}" end)
        |> then(fn s -> IO.binwrite(f, "#{s}\n") end)
        seen = Map.put(seen, wire1, true)
        dump_subtree(f, diagram, Map.get(diagram, wire1), indent + 3, mapping, seen, opts)
      end
    #
    seen =
      if Map.get(seen, wire2) do
        String.pad_leading(deob_wire2, deob_len2 + indent, " ")
        |> then(fn s -> IO.binwrite(f, "#{s}\n") end)
        seen
      else
        String.pad_leading(deob_wire2, deob_len2 + indent, " ")
        |> then(fn s -> IO.binwrite(f, "#{s}\n") end)
        seen = Map.put(seen, wire2, true)
        dump_subtree(f, diagram, Map.get(diagram, wire2), indent + 3, mapping, seen, opts)
      end
    #
    seen
  end

  defp flop_ops({wire1, deob_wire1, deob_len1}, {wire2, deob_wire2, deob_len2}) do
    cond do
      String.slice(deob_wire1, 0..9) == "halfcarry_" && String.slice(deob_wire2, 0..7) == "halfadd_" ->
        {{wire2, deob_wire2, deob_len2}, {wire1, deob_wire1, deob_len1}}
      String.slice(deob_wire1, 0..9) == "fullcarry_" && String.slice(deob_wire2, 0..7) == "halfadd_" ->
        {{wire2, deob_wire2, deob_len2}, {wire1, deob_wire1, deob_len1}}
      String.slice(deob_wire1, 0..9) == "halfcarry_" && String.slice(deob_wire2, 0..9) == "fullcarop_" ->
        {{wire2, deob_wire2, deob_len2}, {wire1, deob_wire1, deob_len1}}
      true ->
        {{wire1, deob_wire1, deob_len1}, {wire2, deob_wire2, deob_len2}}
    end
  end

  defp deobfuscate_wire(mapping, wire, opts) do
    deob_wire =
      cond do
        xyz_wire?(wire) ->
          Map.get(mapping, wire, wire)
        opts[:both] ->
          deob_wire = Map.get(mapping, wire, wire)
          if deob_wire != wire do
            "#{deob_wire} [#{wire}]"
          else
            "? [#{wire}]"
          end
        true ->
          Map.get(mapping, wire, wire)
      end
    {deob_wire, deob_length(deob_wire)}
  end

  defp deob_length(w), do: String.length(w)
end
