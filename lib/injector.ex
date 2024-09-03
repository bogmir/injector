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
      Injector.__inject__(__MODULE__, {unquote(module), unquote(as)})
    end
  end

  def __inject__(module, injection) do
    injections = Module.get_attribute(module, :injector_injections) || []
    Module.put_attribute(module, :injector_injections, [injection | injections])
  end

  defmacro __before_compile__(env) do
    injections = Module.get_attribute(env.module, :injector_injections) || []

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
