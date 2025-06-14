defmodule Raffley.Admin do
  alias Raffley.Raffles
  alias Raffley.Raffles.Raffle
  alias Raffley.Repo
  import Ecto.Query

  def list_raffles do
    Raffle
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def create_raffle(attrs \\ %{}) do
    %Raffle{}
    |> Raffle.changeset(attrs)
    |> Repo.insert()
  end

  def get_raffle!(id) do
    Repo.get!(Raffle, id)
  end

  def update_raffle(%Raffle{} = raffle, attrs) do
    raffle
    |> Raffle.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, raffle} ->
        raffle = Repo.preload(raffle, [:charity, :winning_ticket])
        Raffles.broadcast(raffle.id, {:raffle_updated, raffle})
        {:ok, raffle}

      {:error, _changeset} = error ->
        error
    end
  end

  def draw_winner(%Raffle{status: :closed} = raffle) do
    raffle
    |> Ecto.assoc(:tickets)
    |> order_by(fragment("random()"))
    |> limit(1)
    |> Repo.one()
    |> case do
      nil ->
        {:error, "No tickets to draw!"}

      winner ->
        update_raffle(raffle, %{winning_ticket_id: winner.id})
    end
  end

  def draw_winner(%Raffle{}) do
    {:error, "Raffle must be closed to draw a winner!"}
  end

  def delete_raffle(%Raffle{} = raffle) do
    Repo.delete(raffle)
  end

  def change_raffle(%Raffle{} = raffle, attrs \\ %{}) do
    Raffle.changeset(raffle, attrs)
  end
end
