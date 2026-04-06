defmodule Myappv1.Repo do
  use Ecto.Repo,
    otp_app: :myappv1,
    adapter: Ecto.Adapters.Postgres
end
