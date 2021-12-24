defmodule Logic.Unit do
  @moduledoc """
  Executor for `Logic`.
  """

  @doc ~S"""
  Execute `program` with the given list of `input` values.

  Return final variable values `{w, x, y, z}`.
  """
  def run(program, input, opts \\ []) do
    vars = {0, 0, 0, 0}
    if opts[:verbose] do
      IO.inspect(vars, label: "INITIAL")
    end
    program
    |> Enum.reduce({vars, input}, fn (inst, {vars, input}) ->
      execute(inst, vars, input, opts)
    end)
    |> elem(0)
  end

  defp execute(inst, vars, input, opts) do
    {var, value, input} =
      case inst do
        # inp a - Read an input value and write it to variable a.
        {:inp, a} ->
          [iv | input] =
            case input do
              [] ->
                ivs = IO.gets("Enter integer: ")
                [String.to_integer(String.trim_trailing(ivs))]
              _  ->
                input
            end
          {a, iv, input}

        # add a b - Add the value of a to the value of b, then store the
        # result in variable a.
        {:add, a, b} ->
          {av, bv} = read_vars(vars, a, b)
          {a, av + bv, input}

        # mul a b - Multiply the value of a by the value of b, then store
        # the result in variable a.
        {:mul, a, b} ->
          {av, bv} = read_vars(vars, a, b)
          {a, av * bv, input}

        # div a b - Divide the value of a by the value of b, truncate the
        # result to an integer, then store the result in variable a. (Here,
        # "truncate" means to round the value toward zero.)
        {:div, a, b} ->
          {av, bv} = read_vars(vars, a, b)
          {a, div(av, bv), input}

        # mod a b - Divide the value of a by the value of b, then store the
        # remainder in variable a. (This is also called the modulo operation.)
        {:mod, a, b} ->
          {av, bv} = read_vars(vars, a, b)
          {a, rem(av, bv), input}

        # eql a b - If the value of a and b are equal, then store the value
        # 1 in variable a. Otherwise, store the value 0 in variable a.
        {:eql, a, b} ->
          {av, bv} = read_vars(vars, a, b)
          av =
            cond do
              av == bv -> 1
              true     -> 0
            end
          {a, av, input}
      end
    vars = write_var(vars, var, value)
    if opts[:verbose] do
      IO.inspect({inst, vars}, label: "INST")
    end
    {vars, input}
  end

  defp read_vars({w, x, y, z}, a, b) do
    {
      read_var({w, x, y, z}, a, false),
      read_var({w, x, y, z}, b, true),
    }
  end

  defp read_var({w, x, y, z}, var, _int_ok) when is_atom(var) do
    case var do
      :w -> w
      :x -> x
      :y -> y
      :z -> z
    end
  end
  defp read_var(_vars, var, int_ok) when is_integer(var) and int_ok do
    var
  end

  defp write_var({w, x, y, z}, var, n) when is_atom(var) and is_integer(n) do
    case var do
      :w -> {n, x, y, z}
      :x -> {w, n, y, z}
      :y -> {w, x, n, z}
      :z -> {w, x, y, n}
    end
  end
end
