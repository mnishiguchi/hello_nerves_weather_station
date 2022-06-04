defmodule SensorHub.Font do
  @moduledoc false

  @doc """
  Loads a font from priv/fonts directory and converts it to [Chisel.Font]
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

    SensorHub.ChiselFontCache.get_or_insert_by(bdf_font_name, &build_chisel_font/1)
  end

  defp build_chisel_font(bdf_font_name) do
    fonts_source_dir = Path.join([:code.priv_dir(:sensor_hub), "fonts"])
    fonts_destination_dir = Path.join([System.tmp_dir!(), "fonts"])
    File.mkdir_p(fonts_destination_dir)

    font_data_src = Path.join([fonts_source_dir, bdf_font_name])
    font_data_file = Path.join([fonts_destination_dir, bdf_font_name])

    raw_font = File.read!(font_data_src)
    File.write!(font_data_file, raw_font)

    {:ok, %Chisel.Font{} = chisel_font} = Chisel.Font.load(font_data_file)

    chisel_font
  end
end
