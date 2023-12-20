defmodule Pulse.NetworkTest do
  use ExUnit.Case
  doctest Pulse.Network, import: true

  alias Pulse.Network

  describe "puzzle example" do
    setup do
      [
        networks: [
          %Network{modules: %{
            :broadcaster => {:broadcast,   [:a, :b, :c]},
            :a           => {:flipflop,    [:b]},
            :b           => {:flipflop,    [:c]},
            :c           => {:flipflop,    [:inv]},
            :inv         => {:conjunction, [:a]},
          }},
          %Network{modules: %{
            :broadcaster => {:broadcast,   [:a]},
            :a           => {:flipflop,    [:inv, :con]},
            :inv         => {:conjunction, [:b]},
            :b           => {:flipflop,    [:con]},
            :con         => {:conjunction, [:output]},
          }},
        ],
        exp_initial_states: [
          %{
            :a           => :low,
            :b           => :low,
            :c           => :low,
            :inv         => [{:c, :low}],
          },
          %{
            :a           => :low,
            :inv         => [{:a, :low}],
            :b           => :low,
            :con         => [{:a, :low}, {:b, :low}],
          },
        ],
        exp_network_dumps: [
          [
            """
            button -low-> broadcaster
            broadcaster -low-> a
            broadcaster -low-> b
            broadcaster -low-> c
            a -high-> b
            b -high-> c
            c -high-> inv
            inv -low-> a
            a -low-> b
            b -low-> c
            c -low-> inv
            inv -high-> a
            """,
          ],
          [
            """
            button -low-> broadcaster
            broadcaster -low-> a
            a -high-> inv
            a -high-> con
            inv -low-> b
            con -high-> output
            b -high-> con
            con -low-> output
            """,
            """
            button -low-> broadcaster
            broadcaster -low-> a
            a -low-> inv
            a -low-> con
            inv -high-> b
            con -high-> output
            """,
            """
            button -low-> broadcaster
            broadcaster -low-> a
            a -high-> inv
            a -high-> con
            inv -low-> b
            con -low-> output
            b -low-> con
            con -high-> output
            """,
            """
            button -low-> broadcaster
            broadcaster -low-> a
            a -low-> inv
            a -low-> con
            inv -high-> b
            con -high-> output
            """,
          ],
        ],
        exp_network_pulses: [
          {1 * 12, {8 * 12, 4 * 12}},
          {4 * 3, {17 * 3, 11 * 3}},
        ],
      ]
    end

    test "network initial states", fixture do
      [fixture.networks, fixture.exp_initial_states]
      |> Enum.zip()
      |> Enum.each(fn {network, exp_initial_state} ->
        assert Network.initial_state(network) == exp_initial_state
      end)
    end

    test "network dumps", fixture do
      [fixture.networks, fixture.exp_network_dumps]
      |> Enum.zip()
      |> Enum.each(fn {network, exp_dumps} ->
        state0 = Network.initial_state(network)
        exp_dumps
        |> Enum.reduce({[], state0}, fn _exp_dump, {dumps, state} ->
          {next_state, dump} = Network.push(network, state)
          {[dump | dumps], next_state}
        end)
        |> then(fn {dumps, _state} ->
          assert Enum.reverse(dumps) == exp_dumps
        end)
      end)
    end

    test "network pulse trains", fixture do
      [fixture.networks, fixture.exp_network_pulses]
      |> Enum.zip()
      |> Enum.each(fn {network, {n_pushes, {exp_lows, exp_highs}}} ->
        {act_lows, act_highs} = Network.n_pushes(network, n_pushes)
        assert act_lows == exp_lows
        assert act_highs == exp_highs
      end)
    end
  end
end
