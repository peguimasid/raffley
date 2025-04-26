defmodule RaffleyWeb.RafflesController do
  use RaffleyWeb, :controller

  alias Raffley.Raffles.Raffle
  alias Raffley.Admin

  action_fallback RaffleyWeb.FallbackController

  def index(conn, _params) do
    raffles = Admin.list_raffles()

    render(conn, :index, raffles: raffles)
  end

  def show(conn, %{"id" => id}) do
    raffle = Admin.get_raffle!(id)

    render(conn, :show, raffle: raffle)
  end

  def create(conn, %{"raffle" => raffle_params}) do
    with {:ok, %Raffle{} = raffle} <- Admin.create_raffle(raffle_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/raffles/#{raffle}")
      |> render(:show, raffle: raffle)
    end
  end
end
