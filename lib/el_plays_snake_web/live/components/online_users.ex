defmodule ElPlaysSnakeWeb.Components.OnlineUsers do
  use ElPlaysSnakeWeb, :live_component

  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
    }
  end
end
