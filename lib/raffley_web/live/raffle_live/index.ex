defmodule RaffleyWeb.RaffleLive.Index do
  use RaffleyWeb, :live_view

  alias Raffley.Raffles

  def mount(_params, _session, socket) do
    socket = assign(socket, :raffles, Raffles.list_raffles())
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
      <div class="raffles">
        <.raffle_card :for={raffle <- @raffles} raffle={raffle} />
      </div>
    </div>
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

  attr :raffle, Raffley.Raffle, required: true

  def raffle_card(assigns) do
    ~H"""
    <div class="card">
      <img src={@raffle.image_path} alt={@raffle.description} />
      <h2>{@raffle.prize}</h2>
      <div class="details">
        <div class="price">${@raffle.ticket_price} / ticket</div>
        <.badge status={@raffle.status} />
      </div>
    </div>
    """
  end
end
