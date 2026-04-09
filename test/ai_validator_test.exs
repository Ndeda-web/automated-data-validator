defmodule AiValidatorTest do
  use ExUnit.Case
  doctest AiValidator

  test "greets the world" do
    assert AiValidator.hello() == :world
  end
end
