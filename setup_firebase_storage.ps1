# Firebase Storage Setup Script
# Run this after enabling Firebase Storage in the console

Write-Host "🚀 Setting up Firebase Storage..." -ForegroundColor Green

# Check if Firebase CLI is available
if (!(Get-Command "firebase" -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Firebase CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "npm install -g firebase-tools"
    exit 1
}

# Set the correct Firebase project
Write-Host "📁 Setting Firebase project to unilegal-14d0c..." -ForegroundColor Yellow
firebase use unilegal-14d0c

# Deploy storage rules
Write-Host "📋 Deploying Firebase Storage rules..." -ForegroundColor Yellow
firebase deploy --only storage

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Firebase Storage rules deployed successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to deploy storage rules. Please enable Firebase Storage first:" -ForegroundColor Red
    Write-Host "https://console.firebase.google.com/project/unilegal-14d0c/storage" -ForegroundColor Cyan
    exit 1
}

# Apply CORS configuration
Write-Host "🌐 Applying CORS configuration..." -ForegroundColor Yellow

# Check if gsutil is available
if (Get-Command "gsutil" -ErrorAction SilentlyContinue) {
    gsutil cors set cors.json gs://unilegal-14d0c.firebasestorage.app
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ CORS configuration applied successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to apply CORS configuration via gsutil" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ gsutil not found. You need to apply CORS manually:" -ForegroundColor Yellow
    Write-Host "1. Install Google Cloud SDK" -ForegroundColor Cyan
    Write-Host "2. Run: gsutil cors set cors.json gs://unilegal-14d0c.firebasestorage.app" -ForegroundColor Cyan
    Write-Host "OR apply CORS via Google Cloud Console:" -ForegroundColor Cyan
    Write-Host "https://console.cloud.google.com/storage/browser/unilegal-14d0c.firebasestorage.app" -ForegroundColor Cyan
}

Write-Host "🎉 Firebase Storage setup complete!" -ForegroundColor Green
Write-Host "Now restart your Flutter web app to test the changes." -ForegroundColor Cyan
