# AI Validator - Code Walkthrough

## How It Works (Technical Overview)

### Flow Diagram
```
SampleData.data()
    ↓
DataValidator.validate(data)  ← Rule-based checks
    ↓
DataValidator.summary(data)   ← Generate text summary
    ↓
AIValidator.analyze(summary)  ← Send to Gemini API
    ↓
RunValidator.start()          ← Display results
```

---

## Module Breakdown

### 1. SampleData (lib/sample_data.ex)

**Purpose**: Provides test data with intentional issues

```elixir
def data do
  [
    %{id: 1, name: "Alice", email: "alice@mail.com", amount: 100, ...},
    %{id: 2, name: "Bob", email: nil, amount: -50, ...},        ← Missing email
    %{id: 3, name: "Charlie", email: "charlie@mail.com", ...},  ← Duplicate ID
    %{id: 3, name: "Charlie", email: "charlie@mail.com", ...},  ← Duplicate ID
    %{id: 4, name: "Dana", email: "dana@mail.com", amount: 0, ...},
  ]
end
```

**Key Issues Introduced**:
- Bob (id: 2) has `email: nil` → Tests missing email detection
- Bob has `amount: -50` → Tests negative amount detection
- Charlie (id: 3) appears twice → Tests duplicate ID detection

---

### 2. DataValidator (lib/data_validator.ex)

**Purpose**: Rule-based validation logic

#### Validation Rules

```elixir
def validate(data) do
  %{
    # Rule 1: Find records with missing emails
    missing_email: Enum.filter(data, fn row -> row.email == nil end),
    
    # Rule 2: Find records with negative amounts
    negative_amount: Enum.filter(data, fn row -> row.amount < 0 end),
    
    # Rule 3: Find duplicate IDs
    duplicate_ids: 
      Enum.map(
        Enum.filter(
          Enum.frequencies(Enum.map(data, & &1.id)),  ← Count IDs
          fn {_id, count} -> count > 1 end              ← Keep only duplicates
        ),
        fn {id, _} -> id end                            ← Extract ID values
      )
  }
end
```

**How it works**:
1. `Enum.frequencies()` - Counts occurrences of each ID
2. Filter for counts > 1 - Find duplicates
3. Extract and return the duplicate IDs

#### Summary Generation

```elixir
def summary(data) do
  results = validate(data)
  
  # Generate human-readable summary
  """
  Data Validation Summary:
  - Missing emails: #{length(results.missing_email)}
  - Negative amounts: #{length(results.negative_amount)}
  - Duplicate IDs: #{Enum.join(results.duplicate_ids, ", ")}
  """
end
```

**Output Example**:
```
Data Validation Summary:
- Missing emails: 1
- Negative amounts: 1
- Duplicate IDs: 3
```

---

### 3. AIValidator (lib/ai_validator.ex)

**Purpose**: Calls Google Gemini API for AI analysis

#### API Request Structure

```elixir
body = %{
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
```

**Note**: Uses Gemini's conversation format:
- `role: "user"` → We're sending a user message
- `parts: [...]` → Message contains text/multimodal content

#### API Call

```elixir
HTTPoison.post(
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent",
  body,
  [
    {"Content-Type", "application/json"},
    {"x-goog-api-key", @api_key}
  ],
  [timeout: 30000, recv_timeout: 30000]  ← 30 sec timeout
)
```

**Key Settings**:
- Model: `gemini-2.5-flash` (fast, efficient)
- Authentication: API key in header
- Timeouts: 30 seconds for both connection and receiving

#### Response Parsing

```elixir
case response do
  {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
    # Success: extract text from nested structure
    {:ok, parsed} = Jason.decode(body)
    
    parsed["candidates"]        ← Array of response options
    |> List.first()             ← Take first (only) option
    |> Map.get("content")       ← Get content object
    |> Map.get("parts")         ← Get parts array
    |> List.first()             ← Get first part
    |> Map.get("text")          ← Extract text!
    
  {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
    # Error response (400, 503, etc.)
    {:error, {:api_error, status, body}}
    
  {:error, err} ->
    # Network/timeout error
    {:error, err}
end
```

**Response Structure**:
```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {"text": "Here's a breakdown of each issue..."}
        ]
      }
    }
  ]
}
```

---

### 4. RunValidator (lib/run_validator.ex)

**Purpose**: Orchestrates the entire validation flow

```elixir
def start do
  # Initialize HTTP client with dependencies
  {:ok, _} = Application.ensure_all_started(:httpoison)
  
  # Get data
  data = SampleData.data()
  
  # Validate with rules
  summary = DataValidator.summary(data)
  
  # Display rule-based results
  IO.puts("=== Rule-based Validation Summary ===")
  IO.puts(summary)
  
  # Get AI analysis
  IO.puts("\n=== AI-assisted Suggestions ===")
  case AIValidator.analyze(summary) do
    {:error, reason} ->
      IO.puts("AI analysis failed: #{inspect(reason)}")
    suggestions ->
      IO.puts(suggestions)
  end
end
```

**Flow**:
1. Start dependencies
2. Load data
3. Run validation
4. Call AI API
5. Display results

---

## Data & Message Flow

### Step 1: Data Input
```elixir
data = [
  %{id: 1, name: "Alice", email: "alice@mail.com", amount: 100, ...},
  %{id: 2, name: "Bob", email: nil, amount: -50, ...},
  %{id: 3, name: "Charlie", email: "charlie@mail.com", amount: 200, ...},
  %{id: 3, name: "Charlie", email: "charlie@mail.com", amount: 200, ...},
  %{id: 4, name: "Dana", email: "dana@mail.com", amount: 0, ...}
]
```

### Step 2: Validation
```elixir
%{
  missing_email: [%{id: 2, name: "Bob", email: nil, ...}],
  negative_amount: [%{id: 2, name: "Bob", email: nil, amount: -50, ...}],
  duplicate_ids: [3]
}
```

### Step 3: Summary
```
Data Validation Summary:
- Missing emails: 1
- Negative amounts: 1
- Duplicate IDs: 3
```

### Step 4: AI Request
```
POST /v1beta/models/gemini-2.5-flash:generateContent

{
  "contents": [{
    "role": "user",
    "parts": [{
      "text": "Data Validation Summary:\n- Missing emails: 1\n- Negative amounts: 1\n- Duplicate IDs: 3\n\nPlease: List each issue, Explain impact, Suggest fixes"
    }]
  }]
}
```

### Step 5: AI Response
```
Here's a breakdown of each data validation issue...

### 1. Missing Emails
**Issue**: 1 record is missing an email address.
**Impact**: Communication breakdown, customer service issues...
**Suggested Fixes**: Mandatory field enforcement, Regular audits...

[Full analysis continues...]
```

---

## Key Design Decisions

### 1. Modular Architecture
- Separation of concerns
- Easy to test each module independently
- Simple to extend with new rules

### 2. Three-Layer Validation
- **Layer 1**: Rule-based (fast, deterministic)
- **Layer 2**: AI analysis (comprehensive, actionable)
- Combined = thorough + practical

### 3. API Design
- Uses conversation format for context
- Passes full summary for complete picture
- Requests structured output (issues, impact, fixes)

### 4. Error Handling
- Network errors caught
- API errors handled with status codes
- Graceful fallback messaging

---

## Customization Points

### Add New Validation Rule

**In `data_validator.ex`**:

```elixir
def validate(data) do
  %{
    missing_email: ...,
    negative_amount: ...,
    duplicate_ids: ...,
    # NEW RULE:
    future_dates: Enum.filter(data, fn row -> 
      row.date > Date.utc_today() 
    end)
  }
end
```

### Add to Summary

```elixir
def summary(data) do
  results = validate(data)
  """
  Data Validation Summary:
  - Missing emails: #{length(results.missing_email)}
  - Negative amounts: #{length(results.negative_amount)}
  - Duplicate IDs: #{Enum.join(results.duplicate_ids, ", ")}
  - Future dates: #{length(results.future_dates)}
  """
end
```

### Use Different Model

**In `ai_validator.ex`**, change this line:
```elixir
"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
```

To:
```elixir
"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent"
```

---

## Testing

To test individual modules in `iex`:

```elixir
# Load and test data
data = SampleData.data()

# Test validation
results = DataValidator.validate(data)
IO.inspect(results)

# Test summary
summary = DataValidator.summary(data)
IO.puts(summary)

# Test AI analysis
AIValidator.analyze(summary)
```

---

## Performance Notes

- **Rule-based validation**: ~1ms (very fast)
- **API call**: ~2-5 seconds (depends on API load)
- **Total runtime**: ~3-6 seconds

---

## Dependencies Explained

- **httpoison**: HTTP client for Gemini API calls
- **jason**: JSON encode/decode
- **certifi & ssl_verify_fun**: SSL/HTTPS support

All dependencies are production-grade and widely used.
