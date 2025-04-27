defmodule Raffley.Raffles do
  alias Raffley.Repo
  alias Raffley.Raffles.Raffle
  import Ecto.Query

  def subscribe(raffle_id) do
    Phoenix.PubSub.subscribe(Raffley.PubSub, "raffle:#{raffle_id}")
  end

  def broadcast(raffle_id, message) do
    Phoenix.PubSub.broadcast(Raffley.PubSub, "raffle:#{raffle_id}", message)
  end

  def list_raffles do
    Raffle
    |> Repo.all()
  end

  def filter_raffles(filter \\ %{}) do
    Raffle
    |> with_status(filter["status"])
    |> search_by(filter["q"])
    |> with_charity(filter["charity"])
    |> sort(filter["sort_by"])
    |> preload(:charity)
    |> Repo.all()
  end

  defp with_status(query, status) when status in ~w(open closed upcoming) do
    where(query, status: ^status)
  end

  defp with_status(query, _), do: query

  defp search_by(query, q) when q in ["", nil], do: query

  defp search_by(query, q) do
    where(query, [r], ilike(r.prize, ^"%#{q}%"))
  end

  defp with_charity(query, slug) when slug in ["", nil], do: query

  defp with_charity(query, slug) do
    query
    # |> join(:inner, [r], c in Charity, on: r.charity_id == c.id)
    |> join(:inner, [r], c in assoc(r, :charity))
    |> where([_r, c], c.slug == ^slug)
  end

  defp sort(query, "prize") do
    order_by(query, :prize)
  end

  defp sort(query, "ticket_price_desc") do
    order_by(query, desc: :ticket_price)
  end

  defp sort(query, "ticket_price_asc") do
    order_by(query, asc: :ticket_price)
  end

  defp sort(query, "charity") do
    query
    |> join(:inner, [r], c in assoc(r, :charity))
    |> order_by([_r, c], asc: c.name)
  end

  defp sort(query, _) do
    order_by(query, :id)
  end

  def status_options do
    Ecto.Enum.values(Raffle, :status)
  end

  def get_raffle!(id) do
    Raffle
    |> Repo.get!(id)
    |> Repo.preload(:charity)
  end

  def list_tickets(%Raffle{} = raffle) do
    raffle
    |> Ecto.assoc(:tickets)
    |> preload(:user)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def featured_raffles(%Raffle{id: id}) do
    Process.sleep(:timer.seconds(1))

    Raffle
    |> where([r], r.id != ^id)
    |> order_by(desc: :ticket_price)
    |> limit(3)
    |> Repo.all()
  end
end
