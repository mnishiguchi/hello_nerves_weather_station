defmodule SensorHub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SensorHub.Supervisor]

    children = [
      {SGP30, []},
      {BMP280, [name: BMP280]},
      {BH1750, [name: BH1750]},
      SensorHub.Font,
      SensorHub.Display,
      SensorHub.MeasurementServer
    ]

    {:ok, _} = result = Supervisor.start_link(children, opts)

    BMP280.force_altitude(BMP280, 100)

    result
  end

  def target() do
    Application.get_env(:sensor_hub, :target)
  end
end
