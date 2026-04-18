defmodule RunValidator do
  def start do
    {:ok, _} = Application.ensure_all_started(:httpoison)

    data = SampleData.data()
    summary = DataValidator.summary(data)

   IO.puts(summary)

    IO.puts("\n==============================")
    IO.puts("🧠 AI-ASSISTED ANALYSIS")
    IO.puts("==============================\n")

    case AIValidator.analyze(summary) do
      {:error, reason} ->
        IO.puts("AI analysis failed: #{inspect(reason)}")

      suggestions ->
        IO.puts(suggestions)
    end

    IO.puts("\n==============================")
    IO.puts("⚖️ COMPARISON INSIGHT")
    IO.puts("==============================\n")

    IO.puts("""
    Rule-based validation detects issues directly.
    AI analysis explains the issues, their impact, and suggests fixes.
    """)
  end
end


#RunValidator.start()
