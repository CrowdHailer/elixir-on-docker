defmodule Raxx.Blueprint do
  @moduledoc """
  Route requests based on API Blueprint

  TODO rename to Tokumei
  """

  # elements should be api elements in the future
  defmacro __using__(blueprint) do
    actions = blueprint_to_actions(blueprint)

    routing_ast = for {method, path, module} <- actions do
      path = path_template_to_match(path)
      quote do
        def handle_headers(request = %{method: unquote(method), path: unquote(path)}, state) do
          # DEBT live in a state, needs message monad
          Process.put({Raxx.Blueprint, :handler}, unquote(module))
          return = unquote(module).handle_headers(request, state)
        end
      end
    end

    quote do
      use Raxx.Server
      unquote(routing_ast)

      def handle_fragment(fragment, state) do
        module = Process.get({Raxx.Blueprint, :handler})
        module.handle_fragment(fragment, state)
      end

      def handle_trailers(trailers, state) do
        module = Process.get({Raxx.Blueprint, :handler})
        module.handle_trailers(trailers, state)
      end

      def handle_info(info, state) do
        module = Process.get({Raxx.Blueprint, :handler})
        module.handle_info(info, state)
      end
    end
  end

  defp blueprint_to_actions(parsed) do
    Enum.flat_map(parsed, fn({path, actions}) ->
      Enum.map(actions, fn({method, module}) ->
        {method, path, module}
      end)
    end)
  end

  defp path_template_to_match(path_template) do
    path_template
    |> Raxx.split_path()
    |> Enum.map(&template_segment_to_match/1)
  end

  defp template_segment_to_match(segment) do
    case String.split(segment, ~r/[{}]/) do
      [raw] ->
        raw
      ["", _name, ""] ->
        Macro.var(:_, nil)
    end
  end
end
