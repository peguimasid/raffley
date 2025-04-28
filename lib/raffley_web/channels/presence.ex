defmodule RaffleyWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  alias Raffley.Accounts.User

  use Phoenix.Presence,
    otp_app: :raffley,
    pubsub_server: Raffley.PubSub

  def topic(id) do
    "raffle_watchers:#{id}"
  end

  def track_user(raffle_id, %User{username: username}) do
    track(self(), topic(raffle_id), username, %{
      online_at: System.system_time(:second)
    })
  end

  def subscribe(raffle_id) do
    Phoenix.PubSub.subscribe(Raffley.PubSub, "updates:#{topic(raffle_id)}")
  end

  def list_users(raffle_id) do
    list(topic(raffle_id))
    |> Enum.map(fn {username, %{metas: metas}} ->
      %{id: username, metas: metas}
    end)
  end

  def init(_opts) do
    {:ok, %{}}
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {username, _presence} <- joins do
      presence = %{id: username, metas: Map.fetch!(presences, username)}
      msg = {:user_joined, presence}
      Phoenix.PubSub.local_broadcast(Raffley.PubSub, "updates:#{topic}", msg)
    end

    for {username, _presence} <- leaves do
      metas =
        case Map.fetch(presences, username) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      presence = %{id: username, metas: metas}
      msg = {:user_left, presence}
      Phoenix.PubSub.local_broadcast(Raffley.PubSub, "updates:#{topic}", msg)
    end

    {:ok, state}
  end
end
