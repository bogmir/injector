defmodule Injector do
  defmacro __using__(_opts) do
    quote do
      import Injector
      @before_compile Injector
    end
  end

  defmacro inject(module, opts \\ []) do
    as = Keyword.get(opts, :as, module)
    as = simplify_alias(as)
    mock = Keyword.get(opts, :mock)

    quote do
      Injector.__inject__(__MODULE__, {unquote(module), unquote(as), unquote(mock)})
    end
  end

  def __inject__(module, injection) do
    injections = Module.get_attribute(module, :injector_injections) || []
    Module.put_attribute(module, :injector_injections, [injection | injections])
  end

  defmacro __before_compile__(env) do
    injections = Module.get_attribute(env.module, :injector_injections) || []

    aliases =
      for {module, as, mock} <- injections do
        cond do
          Mix.env() == :test and not is_nil(mock) ->
            quote do
              alias unquote(mock), as: unquote(as)
            end

          true ->
            injection = Application.get_env(:injector, module, module)

            quote do
              alias unquote(injection), as: unquote(as)
            end
        end
      end

    quote do
      (unquote_splicing(aliases))
    end
  end

  defp simplify_alias(alias) when is_atom(alias) do
    alias
    |> Atom.to_string()
    |> String.split(".")
    |> List.last()
    |> String.to_atom()
  end

  defp simplify_alias({:__aliases__, meta, parts}) do
    {:__aliases__, meta, [List.last(parts)]}
  end

  defp simplify_alias(other), do: other
end
