defmodule RaffleyWeb.CustomComponents do
  use Phoenix.Component

  attr :status, :atom, required: true, values: [:upcoming, :open, :closed]
  attr :class, :string, default: nil

  def badge(assigns) do
    ~H"""
    <div class={[
      "rounded-md px-2 py-1 text-xs font-medium uppercase inline-block border",
      @status == :open && "text-lime-600 border-lime-600",
      @status == :upcoming && "text-amber-600 border-amber-600",
      @status == :closed && "text-zinc-600 border-zinc-600",
      @class
    ]}>
      {@status}
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
end
