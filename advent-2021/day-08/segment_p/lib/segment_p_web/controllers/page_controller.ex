defmodule SegmentPWeb.PageController do
  use SegmentPWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
