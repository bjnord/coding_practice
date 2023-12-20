defmodule Pulse.Network do
  @moduledoc """
  Network functions for `Pulse`.
  """

  defstruct modules: %{}

  @doc ~S"""
  Produce an initial state map for a `Network`.

  ## Parameters

  - `network`: the `Network`

  Returns the initial network state (map).
  """
  def initial_state(network) do
    network.modules
    |> Map.keys()
    |> Enum.map(fn k -> initial_state(network, k) end)
    |> Enum.filter(fn {_k, state0} -> state0 end)
    |> Enum.into(%{})
  end

  defp initial_state(network, k) do
    initial_state(network, k, elem(network.modules[k], 0))
  end

  defp initial_state(_network, ff, :flipflop), do: {ff, :low}

  defp initial_state(network, con, :conjunction) do
    inputs =
      network.modules
      |> Enum.filter(fn {_k, {_type, dests}} ->
        Enum.find(dests, fn d -> d == con end)
      end)
      |> Enum.map(fn {k, _v} -> {k, :low} end)
      |> Enum.sort()
    {con, inputs}
  end

  defp initial_state(_network, k, _type), do: {k, nil}

  @doc ~S"""
  Process one button push for a `Network`.

  ## Parameters

  - `network`: the `Network`
  - `state`: the current network state (map)

  Returns a tuple with these elements:
  - `state`: the new network state (map)
  - `dump`: the pulse record (string)
  """
  def push(network, state) do
    # "Here at Desert Machine Headquarters, there is a module with a
    # single button on it called, aptly, the **button module**. When you
    # push the button, a single **low pulse** is sent directly to the
    # `broadcaster` module."
    initial_q = [{:button, :low, :broadcaster}]
    {final_state, lines} = send_pulses(network, state, initial_q, [])
    dump = Enum.reverse(lines)
           |> Enum.join("\n")
           |> then(fn s -> "#{s}\n" end)
    {final_state, dump}
  end

  defp send_pulses(_network, state, [], lines), do: {state, lines}
  defp send_pulses(network, state, [next_pulse | rem_q], lines) do
    {new_state, add_q, new_lines} = send_pulse(network, state, next_pulse, lines)
    send_pulses(network, new_state, rem_q ++ add_q, new_lines)
  end

  defp send_pulse(network, state, pulse, lines) do
    new_lines = [pulse_line(pulse) | lines]
    {new_state, add_q} = process_pulse(network, state, pulse)
    {new_state, add_q, new_lines}
  end

  defp pulse_line({source, signal, dest}) do
    "#{source} -#{signal}-> #{dest}"
  end

  defp process_pulse(network, state, {source, signal, dest}) do
    {type, new_dests} = type_new_dests(network, dest)
    process_pulse_type(state, source, dest, type, signal, new_dests)
  end

  defp type_new_dests(network, dest) do
    if network.modules[dest] do
      network.modules[dest]
    else
      # sink destination (like `output`): pick any module type that doesn't
      # mess with state, and have it send no further signals
      {:broadcast, []}
    end
  end

  # "There is a single **broadcast module** (named `broadcaster`). When
  # it receives a pulse, it sends the same pulse to all of its destination
  # modules."
  defp process_pulse_type(state, _input, source, :broadcast, signal, dests) do
    add_q =
      dests
      |> Enum.map(fn dest -> {source, signal, dest} end)
    {state, add_q}
  end

  # "**Flip-flop modules** (prefix `%`) are either **on** or **off**; they
  # are initially **off**. If a flip-flop module receives a high pulse, it
  # is ignored and nothing happens. However, if a flip-flop module receives
  # a low pulse, it **flips between on and off**. If it was off, it turns
  # on and sends a high pulse. If it was on, it turns off and sends a low
  # pulse."
  defp process_pulse_type(state, _input, source, :flipflop, signal, dests) do
    if signal == :high do
      {state, []}
    else
      {new_signal, new_state} = flip_state(state, source)
      add_q =
        dests
        |> Enum.map(fn dest -> {source, new_signal, dest} end)
      {new_state, add_q}
    end
  end

  # "**Conjunction** modules (prefix `&`) **remember** the type of
  # the most recent pulse received from **each** of their connected input
  # modules; they initially default to remembering a **low pulse** for each
  # input. When a pulse is received, the conjunction module first updates
  # its memory for that input. Then, if it remembers **high pulses** for
  # all inputs, it sends a **low pulse**; otherwise, it sends a **high
  # pulse**."
  defp process_pulse_type(state, input, source, :conjunction, signal, dests) do
    new_input_state = update_state(state, input, source, signal)
    new_signal = all_high_signal(new_input_state)
    new_state = %{state | source => new_input_state}
    add_q =
      dests
      |> Enum.map(fn dest -> {source, new_signal, dest} end)
    {new_state, add_q}
  end

  defp process_pulse_type(_state, _input, source, type, _signal, _dests) do
    raise "unsupported #{source} module type #{type}"
  end

  defp flip_state(state, source) do
    new_signal_state = flip(state[source])
    {
      new_signal_state,
      %{state | source => new_signal_state},
    }
  end

  defp flip(:low), do: :high
  defp flip(:high), do: :low

  defp update_state(state, input, source, signal) do
    state[source]
    |> Enum.map(fn {inp, sig} ->
      if inp == input, do: {inp, signal}, else: {inp, sig}
    end)
  end

  defp all_high_signal(input_states) do
    all_high =
      input_states
      |> Enum.all?(fn {_inp, sig} -> sig == :high end)
    if all_high, do: :low, else: :high
  end
end
