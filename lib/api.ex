defmodule ValidatorAPI do
  use Plug.Router

  plug :match
  plug :dispatch

  post "/validate" do
    data = SampleData.data()
    summary = DataValidator.summary(data)
    ai_result = AIValidator.analyze(summary)

    response =
      case ai_result do
        {:error, reason} ->
          %{
            summary: summary,
            ai: format_ai_error(reason),
            error: true
          }

        text when is_binary(text) ->
          %{
            summary: summary,
            ai: text,
            error: false
          }
      end

    send_resp(conn, 200, Jason.encode!(response))
  end

  defp format_ai_error(:missing_api_key), do: "Missing GEMINI_API_KEY environment variable"
  defp format_ai_error({:api_error, status, body}), do: "AI API error #{status}: #{body}"
  defp format_ai_error(reason), do: "AI Error: #{inspect(reason)}"

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
