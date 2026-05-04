defmodule AIValidator do
  def analyze(summary) do
    case System.get_env("GEMINI_API_KEY") do
      nil ->
        {:error, :missing_api_key}

      "" ->
        {:error, :missing_api_key}

      api_key ->
        body =
          %{
            "contents" => [
              %{
                "role" => "user",
                "parts" => [
                  %{
                    "text" => """
You are a professional data analyst.

IMPORTANT: You are a reporting engine, not a chatbot.
Return ONLY a structured report formatted for email.

STRICT FORMAT (follow exactly):

==============================
TITLE
==============================
One-line summary

==============================
ISSUES
==============================
- Issue 1: short explanation
- Issue 2: short explanation
- Issue 3: short explanation

==============================
IMPACT
==============================
- Bullet points only

==============================
FIXES
==============================
- Bullet points only

==============================
SEVERITY
==============================
- High / Medium / Low

Rules:
- No paragraphs
- No long explanations
- No storytelling
- Only bullet points and headings


Dataset Summary:
#{summary}
"""
                  }
                ]
              }
            ]
          }
          |> Jason.encode!()

        case HTTPoison.post(
               "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
               body,
               [
                 {"Content-Type", "application/json"},
                 {"x-goog-api-key", api_key}
               ],
               [timeout: 30000, recv_timeout: 30000]
             ) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            {:ok, parsed} = Jason.decode(body)

            parsed["candidates"]
            |> List.first()
            |> Map.get("content")
            |> Map.get("parts")
            |> List.first()
            |> Map.get("text")

          {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
            {:error, {:api_error, status, body}}

          {:error, err} ->
            {:error, err}
        end
    end
  end
end
