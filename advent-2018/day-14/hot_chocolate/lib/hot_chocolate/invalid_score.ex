defmodule HotChocolate.InvalidScore do
  defexception [:message]

  @impl true
  def exception(score) do
    m = "score #{score} outside range 0..9"
    %HotChocolate.InvalidScore{message: m}
  end
end
