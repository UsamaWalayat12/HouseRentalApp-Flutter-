# Simple Firebase Storage CORS Fix
Write-Host "🔥 Firebase Storage CORS Fix" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host ""

# Check if Firebase Storage is now enabled
Write-Host "🔍 Testing Firebase Storage availability..." -ForegroundColor Yellow

# Try to deploy storage rules
Write-Host "📦 Deploying storage rules..." -ForegroundColor Yellow
firebase deploy --only storage

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Storage rules deployed successfully!" -ForegroundColor Green
} else {
    Write-Host "❌ Storage rules deployment failed" -ForegroundColor Red
    Write-Host "Please ensure Firebase Storage is enabled at:" -ForegroundColor Yellow
    Write-Host "https://console.firebase.google.com/project/unilegal-14d0c/storage" -ForegroundColor Cyan
    exit 1
}

# Try to apply CORS configuration
Write-Host ""
Write-Host "🌐 Attempting to apply CORS configuration..." -ForegroundColor Yellow

# Check if gsutil is available
$gsutilAvailable = Get-Command "gsutil" -ErrorAction SilentlyContinue
if ($gsutilAvailable) {
    Write-Host "Using gsutil to apply CORS..." -ForegroundColor White
    gsutil cors set cors.json gs://unilegal-14d0c.firebasestorage.app
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ CORS configuration applied successfully!" -ForegroundColor Green
    } else {
        Write-Host "⚠️ CORS application failed with gsutil" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️ gsutil not found. Please apply CORS manually." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Manual CORS Setup (if automatic failed):" -ForegroundColor Cyan
Write-Host "1. Visit: https://console.cloud.google.com/storage/browser/unilegal-14d0c.firebasestorage.app" -ForegroundColor White
Write-Host "2. Click on 'Permissions' tab" -ForegroundColor White
Write-Host "3. Click 'Edit CORS Configuration'" -ForegroundColor White
Write-Host "4. Paste this configuration:" -ForegroundColor White
Write-Host ""
Write-Host '[' -ForegroundColor Gray
Write-Host '  {' -ForegroundColor Gray
Write-Host '    "origin": ["*"],' -ForegroundColor Gray
Write-Host '    "method": ["GET", "HEAD", "PUT", "POST", "DELETE"],' -ForegroundColor Gray
Write-Host '    "maxAgeSeconds": 3600,' -ForegroundColor Gray
Write-Host '    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin", "x-goog-resumable"]' -ForegroundColor Gray
Write-Host '  }' -ForegroundColor Gray
Write-Host ']' -ForegroundColor Gray
Write-Host ""
Write-Host "5. Click 'Save'" -ForegroundColor White
Write-Host ""

Write-Host "🧪 Test Your App:" -ForegroundColor Cyan
Write-Host "1. Stop your Flutter app (Ctrl+C)" -ForegroundColor White
Write-Host "2. Run: flutter clean" -ForegroundColor White
Write-Host "3. Run: flutter pub get" -ForegroundColor White
Write-Host "4. Run: flutter run -d chrome" -ForegroundColor White
Write-Host "5. Try uploading an image again" -ForegroundColor White
Write-Host ""

Write-Host "🎉 Setup Complete!" -ForegroundColor Green
Write-Host "If you still get CORS errors, use the manual setup above." -ForegroundColor Yellow
