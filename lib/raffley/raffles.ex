defmodule Raffley.Raffles do
  alias Raffley.Repo
  alias Raffley.Raffles.Raffle
  import Ecto.Query

  def list_raffles do
    Raffle
    |> Repo.all()
  end

  def filter_raffles() do
    Raffle
    |> where(status: :closed)
    |> where([r], ilike(r.prize, "%gourmet%"))
    |> order_by(:prize)
    |> Repo.all()
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
