defmodule ElfTasksError do
  defexception message: "an ElfTasks error has occurred"
end

defmodule ElfTasks do
  @moduledoc """
  This is a module suitable for keeping track of elves and the tasks assigned
  to them (each having a task ID and duration), as well as simulating time
  and task completion order.
  """

  @doc """
  Create a new ElfTasks map, keyed on elf ID (1..n), with all elves having
  no task assigned.

  ## Parameters

  - n_elves: The number of elves available for tasks (integer)

  ## Returns

  New ElfTasks map
  """
  def new(n_elves) do
    if n_elves < 1 do
      raise ArgumentError, message: "invalid number of elves"
    end
    1..n_elves
    |> Enum.reduce(Map.new(), fn (elf_n, acc) -> Map.put(acc, elf_n, nil) end)
  end

  @doc """
  Are one or more elves free to take a task?

  ## Parameters

  - elf_tasks: ElfTasks map

  ## Returns

  Boolean indicating whether an elf is free or not
  """
  def free_elf?(elf_tasks) do
    case free_elf_id(elf_tasks) do
      nil -> false
      _   -> true   # "Dobby is a free elf!"
    end
  end

  defp free_elf_id(elf_tasks) do
    elf_tasks
    |> Enum.find({nil, nil}, fn ({_k, v}) -> v == nil end)
    |> elem(0)
  end

  @doc """
  Assign a task to a free elf.

  ## Parameters

  - elf_tasks: ElfTasks map
  - task: {task_id, duration} tuple (any, integer)

  ## Returns

  New ElfTasks map
  """
  def assign_task(elf_tasks, {task_id, duration}) do
    case {duration < 1, free_elf_id(elf_tasks)} do
      {true, _}        -> raise ArgumentError, message: "invalid task duration #{duration}"
      {false, nil}     -> raise ElfTasksError, message: "no elves free"
      {false, elf_id}  -> Map.replace!(elf_tasks, elf_id, {task_id, duration})
    end
  end

  @doc """
  Find the task which will complete the soonest.

  ## Parameters

  - elf_tasks: ElfTasks map

  ## Returns

  {elf_id, task_id, duration} tuple (integer, any, integer)
  """
  def soonest_task(elf_tasks) do
    min = Enum.min_by(elf_tasks, fn ({_elf_id, task}) ->
      case task do
        nil                  -> 9_999_999
        {_task_id, duration} -> duration
      end
    end)
    case min do
      {_, nil}                      -> {nil, nil, nil}
      {elf_id, {task_id, duration}} -> {elf_id, task_id, duration}
    end
  end

  @doc """
  Complete a task, and simulate time by decrementing the remaining duration
  of all other tasks. (This should always be called on the task found by
  the `soonest_task()` function.)

  ## Parameters

  - elf_tasks: ElfTasks map
  - elf_id: ID of elf of task to complete (integer)

  ## Returns

  New ElfTasks map
  """
  def complete_task(elf_tasks, elf_id) do
    case elf_tasks[elf_id] do
      nil ->
        raise ElfTasksError, message: "elf ID #{elf_id} has no task"
      {_task_id, duration} ->
        # FIXME this code works but is too complicated to easily understand
        #       (MEME: indentation =~ cyclomatic complexity)
        Map.new(elf_tasks, fn ({m_elf_id, m_task}) ->
          case m_task do
            nil ->
              {m_elf_id, nil}
            {m_task_id, m_duration} ->
              if (m_duration - duration) < 0 do
                raise ElfTasksError, message: "task ID #{m_task_id} completed sooner"
              end
              if m_elf_id == elf_id do
                {m_elf_id, nil}
              else
                {m_elf_id, {m_task_id, m_duration - duration}}
              end
          end
        end)
    end
  end
end
