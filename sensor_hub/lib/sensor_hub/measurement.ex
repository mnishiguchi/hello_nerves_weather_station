defmodule SensorHub.Measurement do
  @moduledoc false

  @sensor_mods [SensorHub.Sensor.SGP30, SensorHub.Sensor.BMP280, SensorHub.Sensor.BH1750]

  def new do
    Enum.reduce(@sensor_mods, %{}, fn sensor_mod, acc_map ->
      sensor_mod.new()
      |> SensorHub.Sensor.measure!()
      |> Enum.into(acc_map)
    end)
  end

  def text(measurement) when is_map(measurement) do
    [
      {"time", local_time_string()},
      {"temperature", measurement.temperature_c |> :erlang.float_to_binary(decimals: 2)},
      {"humidity", measurement.humidity_rh |> :erlang.float_to_binary(decimals: 2)},
      {"co2 eq ppm", measurement.co2_eq_ppm},
      {"tvoc ppb", measurement.tvoc_ppb},
      {"light lux", measurement.light_lux |> :erlang.float_to_binary(decimals: 2)}
    ]
    |> Enum.map(fn {key, value} ->
      _row = [
        key |> to_string() |> String.pad_trailing(12),
        value |> to_string() |> String.pad_leading(8),
        '\n'
      ]
    end)
    |> to_string()
  end

  defp local_time_string do
    NaiveDateTime.local_now()
    |> NaiveDateTime.to_time()
    |> Time.truncate(:second)
    |> to_string()
  end
end
