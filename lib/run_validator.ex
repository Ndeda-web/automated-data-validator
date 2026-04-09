defmodule RunValidator do
  def start do
    {:ok, _} = Application.ensure_all_started(:httpoison)
    
    data = SampleData.data()
    summary = DataValidator.summary(data)

    IO.puts("=== Rule-based Validation Summary ===")
    IO.puts(summary)

    IO.puts("\n=== AI-assisted Suggestions ===")

    case AIValidator.analyze(summary) do
      {:error, reason} ->
        IO.puts("AI analysis failed: #{inspect(reason)}")

      suggestions ->
        IO.puts(suggestions)
    end
  end
end


RunValidator.start()
