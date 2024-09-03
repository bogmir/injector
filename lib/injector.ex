defmodule Injector do
  defmacro __using__(_opts) do
    quote do
      import Injector
      @before_compile Injector
    end
  end

  defmacro inject(module, opts \\ []) do
    as = Keyword.get(opts, :as, module)
    injection = Application.get_env(:injector, module, module)

    quote do
      @injections {unquote(injection), unquote(as)}
    end
  end

  defmacro __before_compile__(env) do
    injections = Module.get_attribute(env.module, :injections) || []

    aliases =
      for {injection, as} <- injections do
        quote do
          alias unquote(injection), as: unquote(as)
        end
      end

    quote do
      (unquote_splicing(aliases))
    end
  end
end
