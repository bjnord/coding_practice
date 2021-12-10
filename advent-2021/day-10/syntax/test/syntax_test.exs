defmodule SyntaxTest do
  use ExUnit.Case
  doctest Syntax

  describe "puzzle example" do
    setup do
      [
        entries: [
          '[({(<(())[]>[[{[]{<()<>>',
          '[(()[<>])]({[<{<<[]>>(',
          '{([(<{}[<>[]}>{[]{[(<()>',
          '(((({<>}<{<{<>}{[]{[]{}',
          '[[<[([]))<([[{}[[()]]]',
          '[{[{({}]{}}([{[{{{}}([]',
          '{<[[]]>}<{[{[{[]{()[[[]',
          '[<(<(<(<{}))><([]([]()',
          '<{([([[(<>()){}]>(<<{{',
          '<{([{{}}[<[[[<>{}]]]>[]]',
        ],
        exp_corrupted_entries: [
          {:corrupted, '}>{[]{[(<()>'},
          {:corrupted, ')<([[{}[[()]]]'},
          {:corrupted, ']{}}([{[{{{}}([]'},
          {:corrupted, '))><([]([]()'},
          {:corrupted, '>(<<{{'},
        ],
        exp_corrupted_entry_scores: [1197, 3, 57, 3, 25137],
        exp_incomplete_entries: [
          '[({(<(())[]>[[{[]{<()<>>',
          '[(()[<>])]({[<{<<[]>>(',
          '(((({<>}<{<{<>}{[]{[]{}',
          '{<[[]]>}<{[{[{[]{()[[[]',
          '<{([{{}}[<[[[<>{}]]]>[]]',
        ],
        exp_incomplete_completions: [
          {:completion, '}}]])})]'},
          {:completion, ')}>]})'},
          {:completion, '}}>}>))))'},
          {:completion, ']]}}]}]}>'},
          {:completion, '])}>'},
        ],
        exp_incomplete_entry_scores: [288957, 5566, 1480781, 995444, 294],
        exp_incomplete_entry_middle_score: 288957,
      ]
    end

    test "status checker finds corrupted entries", fixture do
      act_corrupted = fixture.entries
                      |> Enum.map(&Syntax.entry_status/1)
                      |> Enum.filter(fn {status, _chars} -> status == :corrupted end)
      assert act_corrupted == fixture.exp_corrupted_entries
    end

    test "corrupted entry scorer finds correct scores", fixture do
      act_scores = fixture.entries
                   |> Enum.map(&Syntax.entry_status/1)
                   |> Enum.filter(fn {status, _chars} -> status == :corrupted end)
                   |> Enum.map(&Syntax.entry_score/1)
      assert act_scores == fixture.exp_corrupted_entry_scores
    end

    test "incomplete entry scorer finds correct scores", fixture do
      act_scores = fixture.entries
                   |> Enum.map(&Syntax.entry_status/1)
                   |> Enum.filter(fn {status, _chars} -> status == :incomplete end)
                   |> Enum.map(&Syntax.entry_completion/1)
                   |> Enum.map(&Syntax.entry_score/1)
      act_score =
        act_scores
        |> Enum.sort()
        |> (fn sorted_scores -> Enum.at(sorted_scores, div(length(sorted_scores), 2)) end).()
      assert act_scores == fixture.exp_incomplete_entry_scores
      assert act_score == fixture.exp_incomplete_entry_middle_score
    end
  end
end
