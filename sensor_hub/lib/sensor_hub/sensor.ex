defprotocol SensorHub.Sensor do
  @moduledoc false

  @doc "Returns one measurement"
  @spec measure!(struct) :: map
  def measure!(adapter)
end
