defmodule RaffleyWeb.AdminRaffleLive.Form do
  alias Raffley.Raffles.Raffle
  alias Raffley.Admin
  alias Raffley.Raffles
  use RaffleyWeb, :live_view

  def mount(_params, _session, socket) do
    changeset = Raffle.changeset(%Raffle{}, %{})

    socket =
      socket
      |> assign(:page_title, "Create Raffle")
      |> assign(:form, to_form(changeset))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
    </.header>
    <.simple_form for={@form} id="raffle-form" phx-submit="save">
      <.input field={@form[:prize]} label="Prize" />
      <.input field={@form[:description]} label="Description" type="textarea" />
      <.input field={@form[:ticket_price]} label="Ticket price" type="number" />
      <.input
        field={@form[:status]}
        label="Status"
        type="select"
        prompt="Choose a status"
        options={Raffles.status_options()}
      />
      <.input field={@form[:image_path]} label="Image Path" />
      <:actions>
        <.button phx-disable-with="Saving...">Save Raffle</.button>
      </:actions>
    </.simple_form>
    <.back navigate={~p"/admin/raffles"}>
      Back
    </.back>
    """
  end

  def handle_event("save", %{"raffle" => raffle_params}, socket) do
    case Admin.create_raffle(raffle_params) do
      {:ok, _raffle} ->
        socket =
          socket
          |> put_flash(:info, "Raffle created successfully!")
          |> push_navigate(to: ~p"/admin/raffles")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        socket = assign(socket, :form, to_form(changeset))
        {:noreply, socket}
    end
  end
end
