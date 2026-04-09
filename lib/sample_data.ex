defmodule SampleData do
  def data do
    [
      %{id: 1, name: "Alice", email: "alice@mail.com", amount: 100, date: ~D[2026-04-01]},
      %{id: 2, name: "Bob", email: nil, amount: -50, date: ~D[2026-04-03]},
      %{id: 3, name: "Charlie", email: "charlie@mail.com", amount: 200, date: ~D[2025-12-31]},
      %{id: 3, name: "Charlie", email: "charlie@mail.com", amount: 200, date: ~D[2025-12-31]},
      %{id: 4, name: "Dana", email: "dana@mail.com", amount: 0, date: ~D[2026-04-10]}
    ]
  end
end
