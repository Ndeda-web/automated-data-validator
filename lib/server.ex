defmodule Server do
  def start do
    Plug.Cowboy.http(ValidatorAPI, [], port: 4000)
  end
end
