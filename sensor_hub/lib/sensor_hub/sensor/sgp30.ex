defmodule SensorHub.Sensor.SGP30 do
  @moduledoc false

  defstruct fields: [:co2_eq_ppm, :tvoc_ppb]

  def new(_opts \\ []) do
    %__MODULE__{}
  end

  defimpl SensorHub.Sensor do
    @impl true
    def measure!(sensor) do
      SGP30.state() |> Map.take(sensor.fields)
    end
  end
end
