# Test Firebase Storage Setup
Write-Host "🔥 Testing Firebase Storage Setup..." -ForegroundColor Yellow
Write-Host ""

# Check if Firebase CLI is available
if (!(Get-Command "firebase" -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Firebase CLI not found!" -ForegroundColor Red
    exit 1
}

# Set project
Write-Host "📁 Setting Firebase project..." -ForegroundColor Cyan
firebase use unilegal-14d0c

# Test storage deployment
Write-Host "🧪 Testing Firebase Storage..." -ForegroundColor Cyan
$result = firebase deploy --only storage --dry-run 2>&1

if ($result -match "Firebase Storage has not been set up") {
    Write-Host "❌ Firebase Storage NOT ENABLED!" -ForegroundColor Red
    Write-Host "👉 Please enable it here: https://console.firebase.google.com/project/unilegal-14d0c/storage" -ForegroundColor Yellow
} elseif ($result -match "rules file.*compiled successfully") {
    Write-Host "✅ Firebase Storage is ENABLED and ready!" -ForegroundColor Green
    Write-Host "📋 Now deploying storage rules..." -ForegroundColor Cyan
    
    firebase deploy --only storage
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "🎉 SUCCESS! Firebase Storage is now configured!" -ForegroundColor Green
        Write-Host "🚀 Restart your Flutter app: flutter run -d web" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Failed to deploy storage rules" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ Unknown status. Raw output:" -ForegroundColor Yellow
    Write-Host $result -ForegroundColor Gray
}

Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
