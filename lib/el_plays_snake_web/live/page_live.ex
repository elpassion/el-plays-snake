defmodule ElPlaysSnakeWeb.PageLive do
  use ElPlaysSnakeWeb, :live_view
  require Logger

  alias ElPlaysSnake.Presence
  alias ElPlaysSnake.PubSub

  @topic "game"
  @presence "game:presence"

  @impl true
  def mount(_params, session, socket) do
    socket =
      assign_new(
        socket,
        :current_user,
        fn ->
          %{
            name: random_string(8),
            joined_at: :os.system_time(:seconds)
          }
        end
      )

    {:ok, _} = Presence.track(
      self(),
      @presence,
      socket.assigns.current_user.name,
      socket.assigns.current_user
    )

    Phoenix.PubSub.subscribe(PubSub, @presence)

    ElPlaysSnakeWeb.Endpoint.subscribe(@topic)


    {:ok, game} = ElPlaysSnake.Game.start_game([])


    {
      :ok,
      socket
      |> assign(:game, game)
      |> assign(:users, users())
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

  def handle_event("message", %{"message" => message_params}, socket) do
    message = ElPlaysSnake.Message.changeset(%ElPlaysSnake.Message{}, message_params)
              |> ElPlaysSnake.Message.to_message

    ElPlaysSnakeWeb.Endpoint.broadcast_from(self(), "game", "new_message", message)
    socket = socket |> assign(:messages, [message | socket.assigns.messages])

    {:noreply, socket}
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
    socket = socket |> assign(:messages, [message | socket.assigns.messages])

    {:noreply, socket}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    {:noreply, assign(socket, users: users())}
  end

  @left_key "l"
  @right_key "r"

  @keys [@left_key, @right_key]


  def handle_event("turn", %{"key" => key}, socket) when key in @keys do
    direction = dir(key)

    game = ElPlaysSnake.Game.turn(direction)

    {
      :noreply,
      socket
      |> assign(:game, game)
    }
  end

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
