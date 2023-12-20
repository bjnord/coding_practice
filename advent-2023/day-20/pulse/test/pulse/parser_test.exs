defmodule Pulse.ParserTest do
  use ExUnit.Case
  doctest Pulse.Parser, import: true

  import Pulse.Parser
  alias Pulse.Network

  describe "puzzle example" do
    setup do
      [
        input: """
        broadcaster -> a
        %a -> inv, con
        &inv -> b
        %b -> con
        &con -> output
        """,
        exp_network: %Network{
          modules: %{
            :broadcaster => {:broadcast,   [:a]},
            :a           => {:flipflop,    [:inv, :con]},
            :inv         => {:conjunction, [:b]},
            :b           => {:flipflop,    [:con]},
            :con         => {:conjunction, [:output]},
          },
        },
      ]
    end

    test "parser gets expected network", fixture do
      act_network = fixture.input
                    |> parse_input_string()
      assert act_network == fixture.exp_network
    end
  end
end
