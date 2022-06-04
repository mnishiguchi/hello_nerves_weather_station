defmodule SensorHub.ChiselFontCache do
  @moduledoc false

  use Agent

  def start_link(_opts \\ []) do
    initial_state = %{}
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  def get_or_insert_by(font_name, chisel_font_builder) do
    if chisel_font = get_by(font_name) do
      chisel_font
    else
      %Chisel.Font{} = chisel_font = chisel_font_builder.(font_name)
      :ok = save(font_name, chisel_font)
      chisel_font
    end
  end

  defp get_by(font_name) do
    if chisel_font = Agent.get(__MODULE__, &get_in(&1, [font_name])) do
      chisel_font
    end
  end

  defp save(font_name, %Chisel.Font{} = chisel_font) do
    Agent.update(__MODULE__, &put_in(&1, [font_name], chisel_font))
  end
end
