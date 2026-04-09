defmodule AIValidator do
  @api_key System.get_env("GEMINI_API_KEY")

  def analyze(summary) do
    body =
      %{
        "contents" => [
          %{
            "role" => "user",
            "parts" => [
              %{
                "text" => """
Here is a data validation summary:

#{summary}

Please:
- List each issue
- Explain the impact
- Suggest fixes
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
            {"x-goog-api-key", @api_key}
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
