defmodule ElPlaysSnakeWeb.PageLive do
  use ElPlaysSnakeWeb, :live_view
  require Logger

  alias ElPlaysSnake.Presence
  alias ElPlaysSnake.PubSub

  @topic "game"
  @presence "game:presence"

  @impl true
  def mount(_params, session, socket) do

    Phoenix.PubSub.subscribe(PubSub, @presence)

    ElPlaysSnakeWeb.Endpoint.subscribe(@topic)


    {:ok, game} = ElPlaysSnake.Game.start_game([])


    {
      :ok,
      socket
      |> assign(:game, game)
      |> assign(:users, users())
      |> assign(:current_user, nil)
      |> assign(:current_user_form, ElPlaysSnake.User.changeset(%ElPlaysSnake.User{}))
      |> assign(:messages, [])
      |> assign(:message, ElPlaysSnake.Message.changeset(%ElPlaysSnake.Message{}))
    }
  end


  def handle_event("start", _, socket) do
    {:ok, game} = ElPlaysSnake.Game.start_game([])

    socket = socket
             |> assign(:game, game)

    {:noreply, socket}
  end

  def handle_event("name", %{"message" => user_params}, socket) do
    IO.inspect(user_params)
    user = ElPlaysSnake.User.changeset(%ElPlaysSnake.User{}, user_params)
           |> ElPlaysSnake.User.to_user

    socket = assign(socket, :current_user, user)

    {:ok, _} = Presence.track(
      self(),
      @presence,
      socket.assigns.current_user.name,
      socket.assigns.current_user
    )
    {:noreply, socket}
  end

  def handle_event("message", %{"message" => message_params}, socket) do
    message = ElPlaysSnake.Message.changeset(%ElPlaysSnake.Message{}, message_params)
              |> ElPlaysSnake.Message.to_message

    ElPlaysSnakeWeb.Endpoint.broadcast_from(self(), "game", "new_message", message)
    socket = socket
             |> assign(:messages, [message | socket.assigns.messages])

    keys = ["l", "r"]

    if (Enum.member?(keys, message.text)) do
      direction = dir(message.text)

      game = ElPlaysSnake.Game.turn(direction)

      {
        :noreply,
        socket
        |> assign(:game, game)
      }
    else
      {:noreply, socket}
    end
  end


  def handle_info(%{event: "message", payload: state}, socket) do
    {:noreply, assign(socket, state)}
  end


  def handle_info(%{event: "update", payload: game}, socket) do
    socket = socket
             |> assign(:game, game)
    {:noreply, socket}
  end

  def handle_info(%{event: "new_message", payload: message}, socket) do
    socket = socket
             |> assign(:messages, [message | socket.assigns.messages])

    {:noreply, socket}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    {:noreply, assign(socket, users: users())}
  end

  @left_key "l"
  @right_key "r"

  def handle_event("turn", _, socket) do
    {:noreply, socket}
  end

  defp dir(@left_key), do: :left
  defp dir(@right_key), do: :right

  defp random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)
  end

  defp users() do
    Presence.list(@presence)
    |> Enum.map(
         fn {_user_id, data} ->
           data[:metas]
           |> List.first()
         end
       )
  end
end
