# AI Validator

An intelligent data validation system that combines rule-based validation with AI-powered analysis using Google's Gemini API.

## Features

- **Rule-Based Validation**: Automatically detects common data issues:
  - Missing email addresses
  - Negative amounts
  - Duplicate IDs

- **AI-Powered Insights**: Uses Google Gemini 2.5 Flash to provide:
  - Detailed issue explanations
  - Impact analysis
  - Actionable fix recommendations

## Quick Start

### Prerequisites

- Elixir 1.17+
- Mix (Elixir build tool)
- Google API Key from [Google AI Studio](https://aistudio.google.com/api/keys)

### Installation

1. Clone the repository
```bash
cd ai-validator
```

2. Install dependencies
```bash
mix deps.get
```

3. Set your API key
```bash
export GEMINI_API_KEY="your-api-key-here"
```

4. Run the validator
```bash
mix run -e 'RunValidator.start()'
```

## Architecture

### Modules

- **`SampleData`** - Contains test data (5 records with intentional issues)
- **`DataValidator`** - Rule-based validation logic
  - Detects missing emails
  - Detects negative amounts
  - Detects duplicate IDs
- **`AIValidator`** - Calls Google Gemini API for analysis
- **`RunValidator`** - Orchestrates the validation flow

## Example Output

```
=== Rule-based Validation Summary ===
Data Validation Summary:
- Missing emails: 1
- Negative amounts: 1
- Duplicate IDs: 3

=== AI-assisted Suggestions ===
Here's a breakdown of each data validation issue...

### 1. Missing Emails
**Impact:** Communication breakdown, customer service issues...
**Suggested Fixes:** 
- Mandatory field enforcement
- Regular audits
- Data enrichment...

### 2. Negative Amounts
**Impact:** Financial inaccuracy, reporting errors...
**Suggested Fixes:**
- Input validation
- Business logic refinement...

### 3. Duplicate IDs
**Impact:** Data integrity loss, system confusion...
**Suggested Fixes:**
- Implement unique constraints
- Deduplication process...
```

## Project Structure

```
ai-validator/
├── lib/
│   ├── ai_validator.ex          # AI analysis module
│   ├── data_validator.ex        # Rule-based validation
│   ├── run_validator.ex         # Main entry point
│   └── sample_data.ex           # Test data
├── test/
│   └── ai_validator_test.exs
├── mix.exs                      # Elixir project config
└── README.md
```

## Configuration

### Using Different Models

The validator uses `gemini-2.5-flash` by default. You can change it in `lib/ai_validator.ex`:

```elixir
"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
```

Available models from Google AI:
- `gemini-2.5-flash` (Fast, efficient)
- `gemini-2.5-pro` (More capable)
- `gemini-2.0-flash`

### Adjusting Timeouts

Edit the timeout in `lib/ai_validator.ex` if needed:

```elixir
[timeout: 30000, recv_timeout: 30000]  # in milliseconds
```

## How It Works

1. **Load Data** - Reads sample data records
2. **Validate** - Rule-based checks identify issues
3. **Summarize** - Generates a summary of problems
4. **AI Analysis** - Sends summary to Gemini API
5. **Display** - Shows validation results and AI suggestions

## Customization

### Add Your Own Data

Edit `lib/sample_data.ex`:

```elixir
def data do
  [
    %{id: 1, name: "Your Name", email: "email@example.com", amount: 100, date: ~D[2026-04-01]},
    # Add more records...
  ]
end
```

### Add New Validation Rules

Edit `lib/data_validator.ex` to add custom checks:

```elixir
def validate(data) do
  %{
    missing_email: ...,
    negative_amount: ...,
    duplicate_ids: ...,
    your_custom_rule: Enum.filter(data, fn row -> your_condition end)
  }
end
```

## Dependencies

- **httpoison** - HTTP client for API calls
- **jason** - JSON encoding/decoding
- **certifi** - SSL certificates (for HTTPS)

## Getting an API Key

1. Visit [Google AI Studio](https://aistudio.google.com/api/keys)
2. Click "Create API Key"
3. Copy your key and set it as an environment variable

## Troubleshooting

**Error: "API key not valid"**
- Verify your API key is correct
- Ensure it's set: `echo $GEMINI_API_KEY`

**Error: "503 Unavailable"**
- The API is temporarily overloaded
- Try again in a few seconds (auto-retry included)

**Error: "Timeout"**
- Increase timeouts in `air_validator.ex`
- Check your internet connection

## Next Steps

- **Test with Real Data**: Replace `SampleData` with your actual dataset
- **Integrate into Pipeline**: Add to your data processing workflow
- **Custom Rules**: Extend validation for your specific use case
- **API Integration**: Call this from your application

## License

MIT
