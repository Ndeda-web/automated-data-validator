defmodule RunValidator do
  def start do
    {:ok, _} = Application.ensure_all_started(:httpoison)

    data = SampleData.data()
    summary = DataValidator.summary(data)

    ai_response = AIValidator.analyze(summary)

    IO.puts(summary)
    IO.puts("\nAI RESPONSE:\n")

    # Handle both success and error cases
    ai_text = case ai_response do
      {:error, reason} ->
        IO.puts("❌ AI Error: #{inspect(reason)}")
        "Error: #{inspect(reason)}"
      text when is_binary(text) ->
        IO.puts(text)
        text
    end

    # 🔥 FINAL STRUCTURE (THIS IS WHAT N8N RECEIVES)
    payload = %{
      summary: summary,
      ai: ai_text
    }

    #HTTPoison.post(
     # "http://localhost:5678/webhook-test/validate-data",
     # Jason.encode!(payload),
     # [{"Content-Type", "application/json"}]
   # )

    IO.puts("\nSent to n8n successfully 🚀")
  end
end
