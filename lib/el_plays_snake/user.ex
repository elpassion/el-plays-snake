defmodule ElPlaysSnake.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  def to_user(changeset) do
    changeset |> apply_changes
  end
end
