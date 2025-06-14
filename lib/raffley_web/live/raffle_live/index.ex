defmodule RaffleyWeb.RaffleLive.Index do
  alias Raffley.Charities
  use RaffleyWeb, :live_view

  alias Raffley.Raffles.Raffle
  alias Raffley.Raffles

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:status_options, Raffles.status_options())
      |> assign(:charity_options, Charities.charity_names_and_slugs())

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> stream(:raffles, Raffles.filter_raffles(params), reset: true)
      |> assign(:form, to_form(params))

    {:noreply, socket}
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
      <.filter_form form={@form} status_options={@status_options} charity_options={@charity_options} />
      <div class="raffles" id="raffles" phx-update="stream">
        <div id="empty" class="no-results hidden only:block">
          No raffles found. Try changing your filters.
        </div>
        <.raffle_card :for={{dom_id, raffle} <- @streams.raffles} raffle={raffle} id={dom_id} />
      </div>
    </div>
    """
  end

  def filter_form(assigns) do
    ~H"""
    <.form for={@form} id="filter-form" phx-change="filter">
      <.input field={@form[:q]} placeholder="Search..." autocomplete="off" phx-debounce="500" />
      <.input type="select" field={@form[:status]} prompt="Status" options={@status_options} />
      <.input type="select" field={@form[:charity]} prompt="Charity" options={@charity_options} />
      <.input
        type="select"
        field={@form[:sort_by]}
        prompt="Sort by"
        options={[
          Prize: "prize",
          "Price: High to Low": "ticket_price_desc",
          "Price: Low to High": "ticket_price_asc",
          Charity: "charity"
        ]}
      />
      <.link patch={~p"/raffles"}>
        Reset
      </.link>
    </.form>
    """
  end

  attr :raffle, Raffle, required: true
  attr :id, :string, required: true

  def raffle_card(assigns) do
    ~H"""
    <.link navigate={~p"/raffles/#{@raffle}"} id={@id}>
      <div class="card">
        <div class="charity">{@raffle.charity.name}</div>
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

  def handle_event("filter", params, socket) do
    params =
      params
      |> Map.take(~w(q status sort_by charity))
      |> Map.reject(fn {_key, value} -> value == "" end)

    socket = push_patch(socket, to: ~p"/raffles?#{params}")

    {:noreply, socket}
  end
end
