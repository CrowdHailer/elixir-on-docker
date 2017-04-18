defmodule WaterCooler do

  use Tokumei
  alias WaterCooler.ChatRoom

  route [], request do
    :GET ->
      Response.ok(render("home_page.html", %{}))
    :POST ->
      {:ok, %{message: message}} = parse_publish_form(request.body)
      {:ok, _} = ChatRoom.publish(message)
      Helpers.redirect("/")
  end

  route ["updates"] do
    :GET ->
      {:ok, _} = ChatRoom.join()
      %Ace.ChunkedResponse{
        status: 200,
        headers: [
          {"cache-control", "no-cache"},
          {"transfer-encoding", "chunked"},
          {"connection", "keep-alive"},
          {"content-type", "text/event-stream"}
        ]
      }
  end

  def handle_info({:message, data}, _) do
    data = ServerSentEvent.serialize(%ServerSentEvent{lines: [data], type: "chat"})
    [data]
  end

  def parse_publish_form(raw) do
    %{"message" => message} = URI.decode_www_form(raw) |> URI.decode_query
    {:ok, %{message: message}}
  end

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # port = Application.get_env(:www, :port)
    # cert_path = Path.expand("../cert.pem", __ENV__.file |> Path.dirname)
    # key_path = Path.expand("../key.pem", __ENV__.file |> Path.dirname)

    children = [
      worker(Ace.HTTP, [{__MODULE__, :config}, [port: 8080]]),
      # worker(Ace.HTTPS, [{__MODULE__, :config}, [
      #   port: 8443,
      #   certificate: Application.app_dir(:www, "priv/cert.pem"),
      #   certificate_key: Application.app_dir(:www, "priv/key.pem")
      # ]])
    ]

    opts = [strategy: :one_for_one, name: __MODULE__.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
