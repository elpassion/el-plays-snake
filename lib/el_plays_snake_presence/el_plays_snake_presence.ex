defmodule ElPlaysSnake.Presence do
  use Phoenix.Presence, otp_app: :el_plays_snake,
                        pubsub_server: ElPlaysSnake.PubSub
end
