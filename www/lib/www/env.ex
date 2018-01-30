defmodule WWW.Env do
  settings = [
    peer_list: {:list, :atom}
  ]

  @enforce_keys Keyword.keys(settings)

  defstruct @enforce_keys

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

  defp cast({:list, type}, raw) do
    Enum.reduce_while(String.split(raw), {:ok, []}, fn part, {:ok, values} ->
      case cast(type, part) do
        {:ok, next} ->
          {:cont, {:ok, values ++ [next]}}

        {:error, reason} ->
          {:halt, {:error, reason}}
      end
    end)
  end

  defp cast(:string, raw) do
    {:ok, raw}
  end

  defp cast(:atom, raw) do
    {:ok, String.to_atom(raw)}
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
