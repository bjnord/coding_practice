defmodule SegmentP.Repo do
  use Ecto.Repo,
    otp_app: :segment_p,
    adapter: Ecto.Adapters.Postgres
end
