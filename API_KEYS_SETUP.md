# API Keys Setup Guide

## ⚠️ Security Notice

API keys have been removed from the codebase for security reasons. You need to configure them locally.

## Setup Instructions

### 1. Create Local Environment File

Copy the example environment file:
```bash
cp .env.example .env
```

### 2. Add Your API Keys

Edit `.env` and add your actual API keys:

```env
OPENAI_API_KEY=your_actual_openai_key_here
GEMINI_API_KEY=your_actual_gemini_key_here
```

### 3. Get API Keys

#### OpenAI API Key
1. Visit https://platform.openai.com/api-keys
2. Sign in or create an account
3. Click "Create new secret key"
4. Copy the key and paste it in `.env`

#### Google Gemini API Key
1. Visit https://makersuite.google.com/app/apikey
2. Sign in with your Google account
3. Click "Create API key"
4. Copy the key and paste it in `.env`

## Running the App

### Option 1: Using dart-define (Recommended for Production)

```bash
flutter run --dart-define=OPENAI_API_KEY=your_key --dart-define=GEMINI_API_KEY=your_key
```

### Option 2: For Development

The `.env` file will be used automatically for local development (requires flutter_dotenv package).

## Important Notes

- ✅ `.env` is in `.gitignore` and will NOT be committed
- ✅ `.env.example` is safe to commit (no real keys)
- ❌ NEVER commit real API keys to version control
- ❌ NEVER share your `.env` file

## Troubleshooting

If the chatbot doesn't work:
1. Verify your API keys are correct in `.env`
2. Check that the keys have proper permissions
3. Ensure you have sufficient API credits/quota
