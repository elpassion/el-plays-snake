defmodule ElPlaysSnake.Repo do
  use Ecto.Repo,
    otp_app: :el_plays_snake,
    adapter: Ecto.Adapters.Postgres
end
