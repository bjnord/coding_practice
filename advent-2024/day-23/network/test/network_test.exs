defmodule NetworkTest do
  use ExUnit.Case
  doctest Network

  describe "puzzle example" do
    setup do
      [
        connections: [
          {"kh", "tc"},
          {"qp", "kh"},
          {"de", "cg"},
          {"ka", "co"},
          {"yn", "aq"},
          {"qp", "ub"},
          {"cg", "tb"},
          {"vc", "aq"},
          {"tb", "ka"},
          {"wh", "tc"},
          {"yn", "cg"},
          {"kh", "ub"},
          {"ta", "co"},
          {"de", "co"},
          {"tc", "td"},
          {"tb", "wq"},
          {"wh", "td"},
          {"ta", "ka"},
          {"td", "qp"},
          {"aq", "cg"},
          {"wq", "ub"},
          {"ub", "vc"},
          {"de", "ta"},
          {"wq", "aq"},
          {"wq", "vc"},
          {"wh", "yn"},
          {"ka", "de"},
          {"kh", "ta"},
          {"co", "tc"},
          {"wh", "qp"},
          {"tb", "vc"},
          {"td", "yn"},
        ],
        exp_t_triads: [
          ["co", "de", "ta"],
          ["co", "ka", "ta"],
          ["de", "ka", "ta"],
          ["qp", "td", "wh"],
          ["tb", "vc", "wq"],
          ["tc", "td", "wh"],
          ["td", "wh", "yn"],
        ],
      ]
    end

    test "find triads with 't' computers", fixture do
      act_t_triads = fixture.connections
                     |> Network.t_triads()
      assert act_t_triads == fixture.exp_t_triads
    end
  end
end
