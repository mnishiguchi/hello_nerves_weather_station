defmodule SensorHub.Sensor do
  @moduledoc false

  defstruct [:name, :fields, :read_fn, :convert_fn]

  @doc """
  Prepares for using a given sensor.

  ## Examples

      SGP30
      |> SensorHub.Sensor.new()
      |> SensorHub.Sensor.measure()

      Enum.reduce([SGP30, BMP280, BH1750], %{}, fn sensor_mod, acc ->
        sensor_mod
        |> SensorHub.Sensor.new()
        |> SensorHub.Sensor.measure()
        |> Enum.into(acc)
      end)

  """
  @spec new(atom) :: struct
  def new(sensor_mod) do
    %__MODULE__{
      name: sensor_mod,
      fields: fields(sensor_mod),
      read_fn: read_fn(sensor_mod),
      convert_fn: convert_fn(sensor_mod)
    }
  end

  @spec measure(struct) :: map
  def measure(%__MODULE__{} = sensor) do
    sensor.read_fn.()
    |> sensor.convert_fn.()
  end

  defp fields(SGP30), do: [:co2_eq_ppm, :tvoc_ppb]
  defp fields(BMP280), do: [:altitude_m, :pressure_pa, :temperature_c]
  defp fields(BH1750), do: [:light_lux]

  # Assume the sensors are a singleton process that has already been started.
  defp read_fn(SGP30), do: fn -> SGP30.state() end
  defp read_fn(BMP280), do: fn -> BMP280.measure(BMP280) end
  defp read_fn(BH1750), do: fn -> BH1750.measure(BH1750) end

  defp convert_fn(SGP30) do
    fn measurement ->
      Map.take(measurement, fields(SGP30))
    end
  end

  defp convert_fn(BMP280) do
    fn {:ok, measurement} ->
      Map.take(measurement, fields(BMP280))
    end
  end

  defp convert_fn(BH1750) do
    fn {:ok, measurement} when is_number(measurement) ->
      %{light_lux: measurement}
    end
  end
end
