defmodule Injector do
  defmacro __using__(_opts) do
    quote do
      import Injector
      @before_compile Injector
    end
  end

  defmacro inject(module, opts \\ []) do
    as = Keyword.get(opts, :as, module)

    quote do
      @injections {unquote(module), unquote(as)}
    end
  end

  defmacro __before_compile__(env) do
    injections = Module.get_attribute(env.module, :injections) || []

    aliases =
      for {module, as} <- injections do
        injection = Application.get_env(:injector, module, module)

        quote do
          alias unquote(injection), as: unquote(as)
        end
      end

    quote do
      (unquote_splicing(aliases))
    end
  end
end
