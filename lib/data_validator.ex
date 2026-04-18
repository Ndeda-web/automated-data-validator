defmodule DataValidator do
  def validate(data) do
    %{
      missing_email: Enum.filter(data, fn row -> row.email == nil end),
      negative_amount: Enum.filter(data, fn row -> row.amount < 0 end),
      duplicate_ids:
        Enum.map(
          Enum.filter(
            Enum.frequencies(Enum.map(data, & &1.id)),
            fn {_id, count} -> count > 1 end
          ),
          fn {id, _} -> id end
        )
    }
  end

 def summary(data) do
  results = validate(data)

  """
==============================
📊 RULE-BASED VALIDATION
==============================

Missing emails: #{length(results.missing_email)}
Negative amounts: #{length(results.negative_amount)}
Duplicate IDs: #{Enum.join(results.duplicate_ids, ", ")}
"""
end
end
