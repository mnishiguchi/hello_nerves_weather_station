defmodule SensorHub.MeasurementServer do
  @moduledoc false

  use GenServer, restart: :transient

  @interval_ms 30

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    state = %{chisel_font: nil}

    {:ok, state, {:continue, :start}}
  end

  @impl GenServer
  def handle_continue(:start, state) do
    chisel_font = SensorHub.Font.load!("6x10.bdf")

    send(self(), :tick)

    {:noreply, %{state | chisel_font: chisel_font}}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    refresh_display(state)

    Process.send_after(self(), :tick, @interval_ms)

    {:noreply, state}
  end

  defp refresh_display(state) do
    measurement_text = measure() |> measurement_to_string()

    SensorHub.Display.clear()
    put_pixel_fun = fn x, y -> SensorHub.Display.put_pixel(x, y, []) end
    Chisel.Renderer.draw_text(measurement_text, 0, 0, state.chisel_font, put_pixel_fun, [])
    SensorHub.Display.display()
  end

  defp measurement_to_string(measurement) when is_map(measurement) do
    time =
      NaiveDateTime.local_now()
      |> NaiveDateTime.to_time()
      |> Time.truncate(:second)
      |> to_string()

    [
      {"time", time},
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

  defp measure(sensor_mods \\ [SGP30, BMP280, BH1750]) do
    sensor_mods
    |> Enum.reduce(%{}, fn sensor_mod, acc_map ->
      sensor_mod
      |> SensorHub.Sensor.new()
      |> SensorHub.Sensor.measure()
      |> Enum.into(acc_map)
    end)
  end
end
