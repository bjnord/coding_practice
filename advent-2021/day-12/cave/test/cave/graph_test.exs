defmodule Cave.GraphTest do
  use ExUnit.Case
  doctest Cave.Graph

  describe "puzzle example" do
    setup do
      [
        sm_input: """
        start-A
        start-b
        A-c
        A-b
        b-d
        A-end
        b-end
        """,
        exp_sm_graph: %{
          "start" => [{:big, "A"}, {:small, "b"}],
          "A" => [{:small, "start"}, {:small, "c"}, {:small, "b"}, {:end, "end"}],
          "b" => [{:small, "start"}, {:big, "A"}, {:small, "d"}, {:end, "end"}],
          "c" => [{:big, "A"}],
          "d" => [{:small, "b"}],
          "end" => [{:big, "A"}, {:small, "b"}],
        },
        exp_sm_paths: """
        start,A,b,A,c,A,end
        start,A,b,A,end
        start,A,b,end
        start,A,c,A,b,A,end
        start,A,c,A,b,end
        start,A,c,A,end
        start,A,end
        start,b,A,c,A,end
        start,b,A,end
        start,b,end
        """,
        exp_sm_paths_2: """
        start,A,b,A,b,A,c,A,end
        start,A,b,A,b,A,end
        start,A,b,A,b,end
        start,A,b,A,c,A,b,A,end
        start,A,b,A,c,A,b,end
        start,A,b,A,c,A,c,A,end
        start,A,b,A,c,A,end
        start,A,b,A,end
        start,A,b,d,b,A,c,A,end
        start,A,b,d,b,A,end
        start,A,b,d,b,end
        start,A,b,end
        start,A,c,A,b,A,b,A,end
        start,A,c,A,b,A,b,end
        start,A,c,A,b,A,c,A,end
        start,A,c,A,b,A,end
        start,A,c,A,b,d,b,A,end
        start,A,c,A,b,d,b,end
        start,A,c,A,b,end
        start,A,c,A,c,A,b,A,end
        start,A,c,A,c,A,b,end
        start,A,c,A,c,A,end
        start,A,c,A,end
        start,A,end
        start,b,A,b,A,c,A,end
        start,b,A,b,A,end
        start,b,A,b,end
        start,b,A,c,A,b,A,end
        start,b,A,c,A,b,end
        start,b,A,c,A,c,A,end
        start,b,A,c,A,end
        start,b,A,end
        start,b,d,b,A,c,A,end
        start,b,d,b,A,end
        start,b,d,b,end
        start,b,end
        """,
        md_input: """
        dc-end
        HN-start
        start-kj
        dc-start
        dc-HN
        LN-dc
        HN-end
        kj-sa
        kj-HN
        kj-dc
        """,
        exp_md_paths: """
        start,HN,dc,HN,end
        start,HN,dc,HN,kj,HN,end
        start,HN,dc,end
        start,HN,dc,kj,HN,end
        start,HN,end
        start,HN,kj,HN,dc,HN,end
        start,HN,kj,HN,dc,end
        start,HN,kj,HN,end
        start,HN,kj,dc,HN,end
        start,HN,kj,dc,end
        start,dc,HN,end
        start,dc,HN,kj,HN,end
        start,dc,end
        start,dc,kj,HN,end
        start,kj,HN,dc,HN,end
        start,kj,HN,dc,end
        start,kj,HN,end
        start,kj,dc,HN,end
        start,kj,dc,end
        """,
        exp_md_path_count_2: 103,
        lg_input: """
        fs-end
        he-DX
        fs-he
        start-DX
        pj-DX
        end-zg
        zg-sl
        zg-pj
        pj-he
        RW-he
        fs-DX
        pj-RW
        zg-RW
        start-pj
        he-WI
        zg-he
        pj-fs
        start-RW
        """,
        exp_lg_path_count: 226,
        exp_lg_path_count_2: 3509,
      ]
    end

    test "parser gets expected graph", fixture do
      assert Cave.Graph.parse_input_string(fixture.sm_input) == fixture.exp_sm_graph
    end

    test "walker gets expected paths (small graph)", fixture do
      act_sm_paths =
        Cave.Graph.paths(fixture.exp_sm_graph)
        |> Enum.sort()
      assert act_sm_paths == String.split(fixture.exp_sm_paths, "\n", trim: true)
    end

    test "walker gets expected paths (medium graph)", fixture do
      act_md_paths =
        Cave.Graph.parse_input_string(fixture.md_input)
        |> Cave.Graph.paths()
        |> Enum.sort()
      assert act_md_paths == String.split(fixture.exp_md_paths, "\n", trim: true)
    end

    test "walker gets expected path count (large graph)", fixture do
      act_lg_path_count =
        Cave.Graph.parse_input_string(fixture.lg_input)
        |> Cave.Graph.paths()
        |> Enum.count()
      assert act_lg_path_count == fixture.exp_lg_path_count
    end

    test "walker gets expected paths (small graph, two-visit rule)", fixture do
      act_sm_paths_2 =
        Cave.Graph.paths_twice(fixture.exp_sm_graph)
        |> Enum.sort()
      assert act_sm_paths_2 == String.split(fixture.exp_sm_paths_2, "\n", trim: true)
    end

    test "walker gets expected path count (medium graph, two-visit rule)", fixture do
      act_md_path_count_2 =
        Cave.Graph.parse_input_string(fixture.md_input)
        |> Cave.Graph.paths_twice()
        |> Enum.count()
      assert act_md_path_count_2 == fixture.exp_md_path_count_2
    end

    test "walker gets expected path count (large graph, two-visit rule)", fixture do
      act_lg_path_count_2 =
        Cave.Graph.parse_input_string(fixture.lg_input)
        |> Cave.Graph.paths_twice()
        |> Enum.count()
      assert act_lg_path_count_2 == fixture.exp_lg_path_count_2
    end
  end
end
