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
    SensorHub.Display.clear()
    put_pixel_fun = fn x, y -> SensorHub.Display.put_pixel(x, y, []) end

    SensorHub.Measurement.new()
    |> SensorHub.Measurement.text()
    |> Chisel.Renderer.draw_text(0, 0, state.chisel_font, put_pixel_fun, [])

    SensorHub.Display.display()
  end
end
