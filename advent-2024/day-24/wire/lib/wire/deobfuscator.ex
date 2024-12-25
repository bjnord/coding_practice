defmodule Wire.Deobfuscator do
  @moduledoc """
  Documentation for `Wire.Deobfuscator`.
  """

  import Wire, only: [wire_name: 2, word_width: 1, xyz_wire?: 1, z_wire?: 1]

  def build_catalog(diagram) do
    new_catalog()
    |> add_halfadds_to_catalog(diagram)
    |> add_halfcarries_to_catalog(diagram)
    |> add_fulls_to_catalog(diagram)
  end

  defp new_catalog(), do: {%{}, %{}}

  defp add_halfadds_to_catalog(catalog, diagram) do
    xy_gates(diagram, :XOR)
    |> Enum.reduce(catalog, fn {i, wire}, catalog ->
      if wire != nil do
        add_to_catalog(catalog, {wire_name("halfadd_", i), wire})
      else
        catalog
      end
    end)
  end

  defp add_halfcarries_to_catalog(catalog, diagram) do
    xy_gates(diagram, :AND)
    |> Enum.reduce(catalog, fn {i, wire}, catalog ->
      if wire != nil do
        add_to_catalog(catalog, {wire_name("halfcarry_", i), wire})
      else
        catalog
      end
    end)
  end

  defp add_fulls_to_catalog(catalog, diagram) do
    ww = word_width(diagram)
    1..(ww - 1)
    |> Enum.reduce(catalog, fn i, catalog ->
      full_gates(catalog, diagram, i)
      |> Enum.reduce(catalog, fn {wire_name, wire}, catalog ->
        if wire != nil do
          add_to_catalog(catalog, {wire_name, wire})
        else
          catalog
        end
      end)
    end)
  end

  defp add_to_catalog({fwd, rev}, {a_wire, b_wire}) do
    {
      Map.put_new(fwd, a_wire, b_wire),
      Map.put_new(rev, b_wire, a_wire),
    }
  end

  defp xy_gates(diagram, gate) do
    ww = word_width(diagram)
    0..(ww - 1)
    |> Enum.map(fn i ->
      Enum.find(diagram, fn {k, v} ->
        k_ok =
          if (i == 0) && (gate == :XOR) do
            z_wire?(k)
          else
            !z_wire?(k)
          end
        v_ok =
          (v == {wire_name("x", i), gate, wire_name("y", i)})
        k_ok && v_ok
      end)
      |> then(&(wire_or_nil(i, &1)))
    end)
  end

  defp full_gates(catalog, diagram, i) do
    fulladd =
      Enum.find(diagram, fn {k, v} ->
        carry_wire_name = fullcarry_wire_name(i)
        k_match = !xyz_wire?(k)
        deob_v = deobfuscate_rhs(catalog, v)
        v_match1 = (deob_v == {wire_name("halfadd_", i), :XOR, carry_wire_name})
        v_match2 = (deob_v == {carry_wire_name, :XOR, wire_name("halfadd_", i)})
        k_match && (v_match1 || v_match2)
      end)
      |> then(&(wire_or_nil(wire_name("fulladd_", i), &1)))
    #
    {_, fco_name} = fullcarry_op =
      Enum.find(diagram, fn {k, v} ->
        carry_wire_name = fullcarry_wire_name(i)
        k_match = !xyz_wire?(k)
        deob_v = deobfuscate_rhs(catalog, v)
        v_match1 = (deob_v == {wire_name("halfadd_", i), :AND, carry_wire_name})
        v_match2 = (deob_v == {carry_wire_name, :AND, wire_name("halfadd_", i)})
        k_match && (v_match1 || v_match2)
      end)
      |> then(&(wire_or_nil(wire_name("fullcarop_", i), &1)))
    #
    fullcarry =
      Enum.find(diagram, fn {k, v} ->
        k_match = !xyz_wire?(k)
        deob_v = deobfuscate_rhs(catalog, v)
        v_match1 = (deob_v == {fco_name, :OR, wire_name("halfcarry_", i)})
        v_match2 = (deob_v == {wire_name("halfcarry_", i), :OR, fco_name})
        k_match && (v_match1 || v_match2)
      end)
      |> then(&(wire_or_nil(wire_name("fullcarry_", i), &1)))
    #
    [fulladd, fullcarry_op, fullcarry]
  end

  defp fullcarry_wire_name(1), do: wire_name("halfcarry_", 0)
  defp fullcarry_wire_name(i), do: wire_name("fullcarry_", i - 1)

  defp deobfuscate_rhs(_catalog, value = _rhs) when is_integer(value), do: value
  defp deobfuscate_rhs({_f_mapping, mapping} = _catalog, {wire1, gate, wire2} = _rhs) do
    {
      Map.get(mapping, wire1, wire1),
      gate,
      Map.get(mapping, wire2, wire2),
    }
  end

  defp wire_or_nil(w, nil), do: {w, nil}
  defp wire_or_nil(w, {k, _v}), do: {w, k}

  #defp debug_key(k, v, deob_v, i, matches) do
  #  if k == "htw" do
  #    {k, v}
  #    |> IO.inspect(label: "htw {k, v}")
  #    {deob_v, i}
  #    |> IO.inspect(label: "htw {deob_v, i}")
  #    matches
  #    |> IO.inspect(label: "htw matches")
  #  end
  #end
end
