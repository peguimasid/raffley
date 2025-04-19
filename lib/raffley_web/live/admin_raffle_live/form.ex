defmodule RaffleyWeb.AdminRaffleLive.Form do
  alias Raffley.Raffles
  use RaffleyWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Create Raffle")
      |> assign(:form, to_form(%{}, as: "raffle"))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.header>
      {@page_title}
    </.header>
    <.simple_form for={@form} id="raffle-form">
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
        <.button>Save Raffle</.button>
      </:actions>
    </.simple_form>
    <.back navigate={~p"/admin/raffles"}>
      Back
    </.back>
    """
  end
end
