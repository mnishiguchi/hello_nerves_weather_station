defmodule SensorHub.Sensor.BMP280 do
  @moduledoc false

  defstruct fields: [:humidity_rh, :pressure_pa, :temperature_c]

  def new(_opts \\ []) do
    %__MODULE__{}
  end

  defimpl SensorHub.Sensor do
    @impl true
    def measure!(sensor) do
      {:ok, measurement} = BMP280.measure(BMP280)
      measurement |> Map.take(sensor.fields)
    end
  end
end
