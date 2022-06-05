defmodule SensorHub.Font do
  @moduledoc false

  use Agent

  def start_link(_opts \\ []) do
    initial_state = %{}
    Agent.start_link(fn -> initial_state end, name: __MODULE__)
  end

  @doc """
  Loads a font from priv/fonts directory and converts it to [Chisel.Font].
  See [olikraus/u8g2] for bdf fonts.

  ## Examples

      Font.load!("5x8.bdf")

  [Chisel.Font]: https://hexdocs.pm/chisel/Chisel.Font.html
  [olikraus/u8g2]: https://github.com/olikraus/u8g2/tree/master/tools/font/bdf

  """
  def load!(bdf_font_name) do
    if not String.ends_with?(bdf_font_name, ".bdf") do
      raise("font name must end with .bdf")
    end

    get_or_insert_by(bdf_font_name, &build_chisel_font/1)
  end

  defp get_or_insert_by(font_name, chisel_font_builder) do
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

  defp build_chisel_font(bdf_font_name) do
    {:ok, %Chisel.Font{} = chisel_font} =
      Path.join([:code.priv_dir(:sensor_hub), "fonts", bdf_font_name])
      |> Chisel.Font.load()

    chisel_font
  end
end
