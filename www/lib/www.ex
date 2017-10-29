defmodule WWW do
  use Raxx.Router, [
    {%{method: :GET, path: []}, WWW.HomePage},
    {%{method: :POST, path: []}, WWW.PublishMessage},
    {%{method: :GET, path: ["updates"]}, WWW.SubscribeToMessages},
  ]
end
