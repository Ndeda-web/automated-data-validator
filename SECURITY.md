# 🔒 Security & API Key Management

## ⚠️ Critical: Never Commit API Keys

The API key should **NEVER** be committed to GitHub or any version control system.

### ✅ What's Protected

Your `.gitignore` file blocks:
- `.env` files
- `.env.local` files
- `*.env` files
- Environment variable files

### ✅ What's Safe to Commit

- `README.md` - Project documentation
- `.env.example` - Shows what variables are needed (no secrets!)
- Source code - `lib/` and `test/` directories
- Configuration files - `mix.exs`, `mix.lock`

### ❌ What's Dangerous (DON'T COMMIT)

- `.env` - Your actual credentials
- Hardcoded API keys in source code
- Configuration with real secrets

---

## 🔑 How to Safely Use the API Key

### Option 1: Export in Terminal (Recommended for Development)

```bash
export GEMINI_API_KEY="your-actual-key"
mix run -e 'RunValidator.start()'
```

**Pros**:
✅ Key stays in memory only
✅ Not written to disk
✅ Automatic cleanup on terminal close

**Cons**:
⚠️ Key visible in terminal history
⚠️ Need to set it each time

### Option 2: Use .env File (Recommended for Local Development)

1. Create `.env` file (NOT committed):
```bash
GEMINI_API_KEY=your-actual-key
```

2. Load it before running:
```bash
source .env
mix run -e 'RunValidator.start()'
```

3. Make sure `.env` is in `.gitignore` (✅ Already done!)

**Pros**:
✅ Convenient for local development
✅ Protected by .gitignore
✅ Can have per-environment files

**Cons**:
⚠️ File on disk (ensure file permissions are restricted)

### Option 3: Use a Tool (Recommended for Teams)

Tools like `direnv` can load environment files automatically:

```bash
# Install direnv: https://direnv.net/
echo 'export GEMINI_API_KEY="your-key"' > .envrc
direnv allow
```

**Pros**:
✅ Automatic loading
✅ Per-project configuration
✅ Secure
✅ Team-friendly

---

## 🚀 For Production Deployment

Never use local environment files in production!

### Use Platform Secrets Instead

#### For Cloud Providers:
- **AWS**: AWS Secrets Manager
- **Google Cloud**: Google Cloud Secret Manager
- **Azure**: Azure Key Vault
- **Heroku**: Heroku Config Vars

#### Example (AWS Secrets Manager):
```elixir
# Instead of: System.get_env("GEMINI_API_KEY")

# Use AWS SDK:
api_key = ExAws.SecretsManager.get_secret_value("gemini-api-key")
```

#### Example (Environment from CI/CD):
```bash
# In GitHub Actions, GitLab CI, etc.
export GEMINI_API_KEY=${{ secrets.GEMINI_API_KEY }}
mix run -e 'RunValidator.start()'
```

---

## 🛡️ Security Checklist

### For Development
- [ ] Never commit `.env` file
- [ ] `.env` is in `.gitignore` ✅
- [ ] Use `export` or `.env.example` for setup
- [ ] `.env.example` shows structure without secrets ✅
- [ ] Team shares `.env` values through secure channel (password manager, Slack, etc.)

### Before Pushing to GitHub
- [ ] Run `git status` to verify no `.env` files staged
- [ ] Check `.gitignore` protects sensitive files ✅
- [ ] Code review - verify no hardcoded secrets
- [ ] Run `grep` for API key in codebase:
  ```bash
  grep -r "AIzaSy" lib/  # Should return NOTHING if not hardcoded
  ```

### Before Pushing to Production
- [ ] Use proper secret management service
- [ ] API key has minimal permissions (if possible)
- [ ] Rotate keys periodically
- [ ] Monitor API key usage for suspicious activity
- [ ] Have a plan to revoke compromised keys

---

## 🔍 If Your API Key Gets Exposed

**IMMEDIATELY**:
1. Delete the exposed key in Google AI Studio
2. Generate a new key
3. Update your local `.env` file
4. Update production secrets manager
5. Check Google Console for unusual activity
6. No action needed on GitHub (key was never committed)

---

## Recommended Setup for Your Team

### Step 1: Create `.env` locally (not committed)
```bash
cp .env.example .env
# Edit .env and add your actual key
```

### Step 2: Each team member should:
```bash
# Clone repository
git clone <your-repo>
cd ai-validator

# Ask team lead for .env file (share via secure channel)
# Or get key from your team's secret manager

# Set up locally
export GEMINI_API_KEY="your-key"
mix deps.get

# Run!
mix run -e 'RunValidator.start()'
```

### Step 3: Verify security
```bash
# Make sure .env is ignored
git status  # Should NOT show .env

# Double-check .gitignore has env files
cat .gitignore | grep env
```

---

## Code Review Tips

When reviewing code, look for:

❌ Bad:
```elixir
@api_key "AIzaSy..."  # Hardcoded key!
```

✅ Good:
```elixir
@api_key System.get_env("GEMINI_API_KEY")  # From environment
```

❌ Bad:
```bash
GEMINI_API_KEY=AIzaSy... mix run  # Key in history!
```

✅ Good:
```bash
export GEMINI_API_KEY="AIzaSy..."
mix run  # Key from environment variable
```

---

## Additional Resources

- [GitHub: Protecting Secrets](https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning)
- [Git: Removing Sensitive Data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
- [OWASP: Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)

---

## Summary

✅ **Your project is secure** because:
- `.env` files are in `.gitignore`
- Code uses `System.get_env()` (not hardcoded)
- `.env.example` shows structure without secrets
- Team has clear guidance on setup

🎯 **Just remember**:
- Never commit `.env` files ✅
- Keep API keys in environment variables ✅
- Share keys securely (not via email/Slack messages) ⚠️
- Rotate keys periodically ⚠️
