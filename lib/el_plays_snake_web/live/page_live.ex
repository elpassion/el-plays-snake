defmodule ElPlaysSnakeWeb.PageLive do
  use ElPlaysSnakeWeb, :live_view
  require Logger

  @topic "game"

  @impl true
  def mount(_params, _session, socket) do
    ElPlaysSnakeWeb.Endpoint.subscribe(@topic)
    {:ok, game} = ElPlaysSnake.Game.start_game([])
    {:ok, socket |> assign(:game, game)}
  end


  def handle_event("start", _, socket) do
    {:ok, game} = ElPlaysSnake.Game.start_game([])

    socket = socket |> assign(:game, game)

    {:noreply, socket}
  end

  def handle_info(%{event: "update", payload: game}, socket) do
    socket = socket |> assign(:game, game)
    {:noreply, socket}
  end

  @left_key "l"
  @right_key "r"

  @keys [@left_key, @right_key]

  def handle_event("turn", %{"key" => key}, socket) when key in @keys do
    direction = dir(key)

    game = ElPlaysSnake.Game.turn(direction)

    {:noreply, socket |> assign(:game, game)}
  end

  def handle_event("turn", _, socket) do
    {:noreply, socket}
  end

  defp dir(@left_key), do: :left
  defp dir(@right_key), do: :right
end
