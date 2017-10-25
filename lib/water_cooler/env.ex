defmodule WaterCooler.WWW.Env do
  # use Env
  #
  # setting :secure_port, :integer
  # setting :service_name, :string

  @enforce_keys [
    :service_name,
    :secure_port
  ]

  defstruct @enforce_keys

  settings = [
    service_name: :string,
    secure_port: :integer
  ]

  def read() do
    values =
      for {setting, type} <- unquote(settings) do
        case fetch(setting) do
          {:ok, value} ->
            {setting, cast(type, value)}

          {:error, reason} ->
            {setting, {:error, reason}}
        end
      end

    struct(__MODULE__, values)
  end

  defp cast(:string, raw) do
    {:ok, raw}
  end

  defp cast(:integer, raw) do
    case Integer.parse(raw) do
      {integer, ""} ->
        {:ok, integer}

      _ ->
        {:error, {:invalid_integer, raw}}
    end
  end

  defp fetch(name) do
    case System.get_env("#{name}" |> String.upcase()) do
      nil ->
        {:error, {:no_env_variable, name}}

      value ->
        {:ok, value}
    end
  end
end
