defmodule ElPlaysSnake.Game do
  @size 16
  @interval 200

  defstruct started: false,
            game_over: false,
            win: false,
            t: 0,
            direction: {0, 0},
            snake: [{ceil(@size / 2), ceil(@size / 2)}],
            screen_width: @size,
            screen_height: @size,
            apple: [],
            tiles: [],
            has_already_turned: false

  use GenServer
  require Logger
  import Enum, only: [member?: 2, drop: 2, random: 1]


  @doc false
  def start_link(_args) do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end








  @doc """
  Start a new snake game.
  """
  def start_game(_args) do
    {:ok, state}
  end


  @doc """
  Get current state of the game
  """
  def state() do
    GenServer.call(__MODULE__, :state)
  end

  @doc """
  Change direction.
  """
  def turn(dir) do
    GenServer.call(__MODULE__, {:turn, dir})
  end

  @doc """
  Tick tick. Move ahead the snake.
  """
  def update() do
    GenServer.call(__MODULE__, :update)
  end




  @doc false
  def init(_) do
    game = new_game()

    Process.send_after(self(), :update, @interval)

    {:ok, game}
  end







  def handle_info(:update, game) do
    game = game |> tick()
    Process.send_after(self(), :update, @interval)
    ElPlaysSnakeWeb.Endpoint.broadcast_from(self(), "game", "update", game)
    {:noreply, game}
  end







  @doc false
  def handle_call(:state, _from, game) do
    {:reply, game, game}
  end

  def handle_call(:update, _from, game) do
    game = game |> tick()

    {:reply, game, game}
  end












  def handle_call({:turn, _direction}, _from, %{has_already_turned: true} = game) do
    {:reply, game, game}
  end

  def handle_call({:turn, :left}, _from, game) do
    new_direction = case game.direction do
      {0, 0} -> {1, 0}
      {-1, 0} -> {0, 1}
      {1, 0} -> {0, -1}
      {0, 1} -> {1, 0}
      {0, -1} -> {-1, 0}
    end

    game =
      game
      |> Map.put(:direction, new_direction)
      |> Map.put(:has_already_turned, true)
      |> start()

    {:reply, game, game}
  end

  def handle_call({:turn, :right}, _from, game) do
    new_direction = case game.direction do
      {0, 0} -> {-1, 0}
      {-1, 0} -> {0, -1}
      {1, 0} -> {0, 1}
      {0, 1} -> {-1, 0}
      {0, -1} -> {1, 0}
    end
    game =
      game
      |> Map.put(:direction, new_direction)
      |> Map.put(:has_already_turned, true)
      |> start()

    {:reply, game, game}
  end

  def new_game() do
    %__MODULE__{}
      |> gen_apple()
      |> gen_tiles()
  end

  def start(%{started: true} = game), do: game

  def start(game) do
    game |> Map.put(:started, true)
  end

  def tick(game) do
    game
    |> Map.update!(:t, &(&1 + 1))
    |> Map.put(:has_already_turned, false)
    |> move_and_eat()
    |> gen_tiles()
  end

  def move(%{direction: {0, 0}} = game), do: game

  def move(game) do
    next = next_pos(game)

    if member?(game.snake, next) do
      new_game()
    else
      game
      |> Map.put(:snake, [next] ++ (game.snake |> drop(-1)))
    end
  end

  def next_pos(game) do
    [{x, y} | _] = game.snake
    {dx, dy} = game.direction

    {
      within(x + dx, game.screen_width),
      within(y + dy, game.screen_height)
    }
  end

  defp within(pos, max) do
    cond do
      pos < 0 -> pos + max
      pos >= max -> pos - max
      true -> pos
    end
  end

  def move_and_eat(%{direction: {0, 0}} = game) do
    game
  end

  def move_and_eat(%{snake: snake, apple: apple} = game) do
    next = next_pos(game)

    if member?(apple, next) do
      snake = [next] ++ snake

      game
      |> Map.put(:snake, snake)
      |> gen_apple()
    else
      game
      |> move()
    end
  end

  defp gen_apple(%{snake: snake, apple: apple, screen_width: w, screen_height: h} = game) do
    if win?(game) do
      Map.merge(game, %{game_over: true, win: true, apple: []})
    else
      Map.put(game, :apple, [next_apple_pos(w, h, snake ++ apple)])
    end
  end

  def win?(%{snake: snake, screen_width: w, screen_height: h}) do
    length(snake) == w * h
  end

  defp next_apple_pos(w, h, taken) do
    pos = {
      random(0..(w - 1)),
      random(0..(h - 1))
    }

    if member?(taken, pos) do
      next_apple_pos(w, h, taken)
    else
      pos
    end
  end

  def gen_tiles(%{snake: snake, apple: apple, screen_width: w, screen_height: h} = game) do
    tiles =
      for x <- 0..(w - 1), y <- 0..(h - 1) do
        cond do
          member?(apple, {y, x}) ->
            :apple

          member?(snake, {y, x}) ->
            :snake

          true ->
            nil
        end
      end

    tiles =
      tiles
      |> Enum.chunk_every(w)

    Map.put(game, :tiles, tiles)
  end
end
