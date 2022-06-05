defmodule SensorHub.Sensor.BH1750 do
  @moduledoc false

  defstruct fields: [:light_lux]

  def new(_opts \\ []) do
    %__MODULE__{}
  end

  defimpl SensorHub.Sensor do
    @impl true
    def measure!(_sensor) do
      {:ok, measurement} = BH1750.measure(BH1750)
      %{light_lux: measurement}
    end
  end
end
