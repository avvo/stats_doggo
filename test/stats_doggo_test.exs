defmodule StatsDoggoTest do
  use ExUnit.Case
  doctest StatsDoggo

  test "can be initialized multiple times safely" do
    StatsDoggo.Worker.init :ok
    StatsDoggo.Worker.init :ok
    assert {:ok, _} = StatsDoggo.Worker.init :ok
  end

  test "can handle decrement" do
    assert :ok = StatsDoggo.decrement("test string", 10)
  end

  test "can handle gauge" do
    assert :ok = StatsDoggo.gauge("test string", 10)
  end

  test "can handle increment" do
    assert :ok = StatsDoggo.increment("test string", 10)
  end

  test "can handle set" do
    assert :ok = StatsDoggo.set("test string", "user1")
  end

  test "can handle timing" do
    assert :ok = StatsDoggo.timing("test string", 10)
  end
end
