# Learning Hub Backend - Deployment Guide

##  Quick Start (Local Development)

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Setup Firebase
Download your Firebase service account key and save as `firebase-service-account.json`

### 3. Configure Environment
```bash
cp .env.example .env
# Edit .env with your settings
```

### 4. Start Server
```bash
npm run dev
```

Visit: http://localhost:3000

---

##  Docker Deployment

### Build and Run with Docker
```bash
# Build image
docker build -t learninghub-api .

# Run container
docker run -p 3000:3000 \
  -v $(pwd)/firebase-service-account.json:/app/firebase-service-account.json:ro \
  -v $(pwd)/.env:/app/.env:ro \
  learninghub-api
```

### Using Docker Compose
```bash
docker-compose up -d
```

---

##  Cloud Deployment Options

### Option 1: Heroku

```bash
# Install Heroku CLI
# Login
heroku login

# Create app
heroku create learninghub-api

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set FIREBASE_DATABASE_URL=your-firebase-url

# Add Firebase credentials as config var
heroku config:set FIREBASE_SERVICE_ACCOUNT="$(cat firebase-service-account.json)"

# Deploy
git push heroku main

# Open app
heroku open
```

**Cost:** Free tier available

---

### Option 2: Google Cloud Run

```bash
# Install gcloud CLI
# Login
gcloud auth login

# Set project
gcloud config set project YOUR_PROJECT_ID

# Build and deploy
gcloud run deploy learninghub-api \
  --source . \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars NODE_ENV=production

# Get URL
gcloud run services describe learninghub-api --region us-central1
```

**Cost:** Pay per use, free tier available

---

### Option 3: Railway

1. Visit [railway.app](https://railway.app)
2. Click "New Project" > "Deploy from GitHub"
3. Select your repository
4. Add environment variables:
   - `NODE_ENV=production`
   - `FIREBASE_DATABASE_URL=your-url`
5. Upload `firebase-service-account.json` as a file
6. Deploy!

**Cost:** Free tier available ($5 credit/month)

---

### Option 4: Render

1. Visit [render.com](https://render.com)
2. Click "New +" > "Web Service"
3. Connect your GitHub repository
4. Configure:
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Environment:** Node
5. Add environment variables
6. Deploy!

**Cost:** Free tier available

---

### Option 5: DigitalOcean App Platform

```bash
# Install doctl CLI
# Login
doctl auth init

# Create app
doctl apps create --spec app.yaml

# Monitor deployment
doctl apps list
```

Create `app.yaml`:
```yaml
name: learninghub-api
services:
- name: api
  github:
    repo: your-username/learninghub
    branch: main
    deploy_on_push: true
  source_dir: /backend
  run_command: npm start
  environment_slug: node-js
  instance_count: 1
  instance_size_slug: basic-xxs
  envs:
  - key: NODE_ENV
    value: production
```

**Cost:** Starting at $5/month

---

### Option 6: AWS Elastic Beanstalk

```bash
# Install EB CLI
pip install awsebcli

# Initialize
eb init -p node.js learninghub-api

# Create environment
eb create learninghub-production

# Set environment variables
eb setenv NODE_ENV=production FIREBASE_DATABASE_URL=your-url

# Deploy
eb deploy

# Open app
eb open
```

**Cost:** Pay per use

---

### Option 7: Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Set environment variables in dashboard
# Add firebase-service-account.json content as FIREBASE_SERVICE_ACCOUNT
```

Create `vercel.json`:
```json
{
  "version": 2,
  "builds": [
    {
      "src": "server.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "server.js"
    }
  ]
}
```

**Cost:** Free tier available

---

##  Post-Deployment Configuration

### 1. Update Flutter App API URL

Edit `lib/services/api_service.dart`:
```dart
final Dio _dio = Dio(
  BaseOptions(
    baseUrl: 'https://your-deployed-api-url.com', // Update this
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ),
);
```

### 2. Test API
```bash
curl https://your-api-url.com/health
```

### 3. Enable CORS (if needed)
Update `server.js`:
```javascript
app.use(cors({
  origin: ['https://your-app-domain.com'],
  credentials: true
}));
```

---

##  Monitoring & Logs

### View Logs

**Heroku:**
```bash
heroku logs --tail
```

**Google Cloud Run:**
```bash
gcloud run services logs read learninghub-api
```

**Railway/Render:**
View in dashboard

---

##  Security Checklist

- [ ] Set `NODE_ENV=production`
- [ ] Use HTTPS only
- [ ] Secure Firebase credentials
- [ ] Enable rate limiting
- [ ] Add authentication middleware
- [ ] Validate all inputs
- [ ] Set proper CORS origins
- [ ] Use environment variables for secrets
- [ ] Enable request logging
- [ ] Set up error monitoring (Sentry)

---

##  Testing Deployed API

```bash
# Health check
curl https://your-api-url.com/health

# Get courses
curl https://your-api-url.com/api/courses

# Create course (POST)
curl -X POST https://your-api-url.com/api/courses \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Course","description":"Test"}'
```

---

##  Troubleshooting

### API Returns 500 Error
- Check Firebase credentials
- Verify environment variables
- Check server logs

### CORS Errors
- Update CORS configuration in `server.js`
- Add your app domain to allowed origins

### Firebase Connection Failed
- Verify service account JSON is correct
- Check Firebase project ID
- Ensure Firestore is enabled

---

##  Scaling

### Horizontal Scaling
- Increase instance count in cloud platform
- Use load balancer
- Enable auto-scaling

### Performance Optimization
- Enable response caching
- Use CDN for static assets
- Optimize database queries
- Add Redis for session storage

---

##  Cost Comparison

| Platform | Free Tier | Paid Plans |
|----------|-----------|------------|
| Heroku | 550 hours/month | $7+/month |
| Railway | $5 credit/month | $5+/month |
| Render | 750 hours/month | $7+/month |
| Google Cloud Run | 2M requests/month | Pay per use |
| Vercel | Unlimited | $20+/month |
| DigitalOcean | None | $5+/month |

---

##  Deployment Checklist

- [ ] Code pushed to Git
- [ ] Environment variables configured
- [ ] Firebase credentials added
- [ ] API tested locally
- [ ] Deployment platform selected
- [ ] App deployed
- [ ] Health check passes
- [ ] Flutter app updated with new URL
- [ ] End-to-end testing completed
- [ ] Monitoring enabled

---

**Your API is now live! **

Update your Flutter app's API URL and start syncing data!
