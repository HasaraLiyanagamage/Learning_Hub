# Git History Cleanup Guide

## Problem

The OpenAI API key was committed to Git history and needs to be removed before pushing to GitHub.

## ⚠️ CRITICAL: Revoke Exposed API Keys

**FIRST, revoke the exposed API keys immediately:**

1. **OpenAI Key**: Visit https://platform.openai.com/api-keys and delete the exposed key
2. **Gemini Key**: Visit https://makersuite.google.com/app/apikey and delete the exposed key
3. Generate new keys and add them to your local `.env` file

## Solution: Remove from Git History

### Option 1: Amend Last Commit (If it's the most recent commit)

```bash
# Stage the fixed file
git add lib/core/constants/app_constants.dart
git add .gitignore
git add .env.example
git add API_KEYS_SETUP.md

# Amend the last commit
git commit --amend --no-edit

# Force push (⚠️ only if you're the only one working on this branch)
git push origin main --force
```

### Option 2: Use BFG Repo-Cleaner (For older commits)

```bash
# Install BFG
brew install bfg

# Create a backup
git clone --mirror https://github.com/HasaraLiyanagamage/Learning_Hub.git backup-repo

# Remove the sensitive data
bfg --replace-text passwords.txt Learning_Hub.git

# Force push
cd Learning_Hub.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force
```

### Option 3: Interactive Rebase (Manual approach)

```bash
# Find the commit with the API key
git log --oneline

# Start interactive rebase from before that commit
git rebase -i HEAD~5  # Adjust number as needed

# In the editor, change 'pick' to 'edit' for the problematic commit
# Save and close

# Make your changes
git add lib/core/constants/app_constants.dart
git commit --amend --no-edit

# Continue rebase
git rebase --continue

# Force push
git push origin main --force
```

## After Cleanup

1. Verify the keys are removed:
   ```bash
   git log -p lib/core/constants/app_constants.dart
   ```

2. Try pushing again:
   ```bash
   git push origin main
   ```

## Prevention

- ✅ `.env` files are now in `.gitignore`
- ✅ API keys use environment variables
- ✅ `.env.example` provides template without real keys
