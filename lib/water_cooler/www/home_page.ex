defmodule WaterCooler.WWW.HomePage do
  use Raxx.Server

  require EEx

  EEx.function_from_file(:defp, :home_page, Path.join(__DIR__, "./home_page.html.eex"), [])

  @impl Raxx.Server
  def handle_request(_request, _config) do
    body = home_page()
    Raxx.response(:ok)
    |> Raxx.set_header("content-type", "text/html")
    |> Raxx.set_body(body)
  end
end
