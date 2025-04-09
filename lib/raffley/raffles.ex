defmodule Raffley.Raffles do
  alias Raffley.Repo
  alias Raffley.Raffles.Raffle

  def list_raffles do
    Raffle
    |> Repo.all()
  end

  def get_raffle!(id) do
    Raffle
    |> Repo.get!(id)
  end

  def featured_raffles(%Raffle{id: id}) do
    Enum.filter(list_raffles(), fn raffle -> raffle.id != id end)
  end
end
