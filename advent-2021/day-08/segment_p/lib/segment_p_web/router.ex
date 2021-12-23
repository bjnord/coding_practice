defmodule SegmentPWeb.Router do
  use SegmentPWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SegmentPWeb do
    pipe_through :browser

    get "/parts", SegmentController, :parts
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", SegmentPWeb do
  #   pipe_through :api
  # end
end
