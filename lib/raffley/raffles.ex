defmodule Raffley.Raffles do
  alias Raffley.Repo
  alias Raffley.Raffles.Raffle
  import Ecto.Query

  def list_raffles do
    Raffle
    |> Repo.all()
  end

  def filter_raffles(filter \\ %{}) do
    Raffle
    |> with_status(filter["status"])
    |> search_by(filter["q"])
    |> sort(filter["sort_by"])
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

  defp sort(query, "prize") do
    order_by(query, :prize)
  end

  defp sort(query, "ticket_price") do
    order_by(query, desc: :ticket_price)
  end

  defp sort(query, "ticket_price_asc") do
    order_by(query, asc: :ticket_price)
  end

  defp sort(query, "ticket_price_desc") do
    order_by(query, desc: :ticket_price)
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
  end

  def featured_raffles(%Raffle{id: id}) do
    Raffle
    |> where([r], r.id != ^id)
    |> order_by(desc: :ticket_price)
    |> limit(3)
    |> Repo.all()
  end
end
