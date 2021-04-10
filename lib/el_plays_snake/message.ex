defmodule ElPlaysSnake.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :author_id
    field :text
  end

  def changeset(message, params \\ %{}) do
    message
    |> cast(params, [:author_id, :text])
    |> validate_required([:author_id, :text])
  end

  def to_message(changeset) do
    changeset |> apply_changes
  end
end
