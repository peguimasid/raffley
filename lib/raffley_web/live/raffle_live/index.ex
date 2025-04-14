defmodule RaffleyWeb.RaffleLive.Index do
  use RaffleyWeb, :live_view

  alias Raffley.Raffles.Raffle
  alias Raffley.Raffles

  def mount(_params, _session, socket) do
    socket =
      socket
      |> stream(:raffles, Raffles.list_raffles())
      |> assign(:form, to_form(%{}))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="raffle-index">
      <%!-- <.banner>
        <.icon name="hero-sparkles-solid" /> Mystery Raffle Coming Soon!
        <:details :let={[vibe, reaction]}>
          To be revealed tomorrow {vibe} {reaction}
        </:details>
        <:details>
          Any guesses?
        </:details>
      </.banner> --%>
      <.filter_form form={@form} />
      <div class="raffles" id="raffles" phx-update="stream">
        <.raffle_card :for={{dom_id, raffle} <- @streams.raffles} raffle={raffle} id={dom_id} />
      </div>
    </div>
    """
  end

  def filter_form(assigns) do
    ~H"""
    <.form for={@form}>
      <.input field={@form[:q]} placeholder="Search..." autocomplete="off" class="leading-3" />
      <.input
        type="select"
        field={@form[:status]}
        prompt="Status"
        options={[:upcoming, :open, :closed]}
      />
      <.input
        type="select"
        field={@form[:sort_by]}
        prompt="Sort by"
        options={[:prize, :ticket_price]}
      />
    </.form>
    """
  end

  slot :inner_block, required: true
  slot :details

  def banner(assigns) do
    assigns =
      assigns
      |> assign(:emoji, ~w(🎉 🎊 ✨ 🌟 💫) |> Enum.random())
      |> assign(:reaction, ~w(😮 😍 🤩 👀 🙌) |> Enum.random())

    ~H"""
    <div class="banner">
      <h1>
        {render_slot(@inner_block)}
      </h1>
      <div :for={details <- @details} class="details">
        {render_slot(details, [@emoji, @reaction])}
      </div>
    </div>
    """
  end

  attr :raffle, Raffle, required: true
  attr :id, :string, required: true

  def raffle_card(assigns) do
    ~H"""
    <.link navigate={~p"/raffles/#{@raffle}"} id={@id}>
      <div class="card">
        <img src={@raffle.image_path} alt={@raffle.description} />
        <h2>{@raffle.prize}</h2>
        <div class="details">
          <div class="price">${@raffle.ticket_price} / ticket</div>
          <.badge status={@raffle.status} />
        </div>
      </div>
    </.link>
    """
  end
end
