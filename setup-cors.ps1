# Firebase Storage CORS Configuration Script
# Run this script after installing Google Cloud SDK

Write-Host "Setting up Firebase Storage CORS configuration..." -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green

# Set your project ID
$PROJECT_ID = "unilegal-14d0c"
$BUCKET_NAME = "unilegal-14d0c.firebasestorage.app"

# Check if gcloud is installed
try {
    $gcloudVersion = gcloud version 2>$null
    if (-not $gcloudVersion) {
        throw "gcloud not found"
    }
    Write-Host "✓ Google Cloud SDK is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Google Cloud SDK is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install it from: https://cloud.google.com/sdk/docs/install-sdk" -ForegroundColor Yellow
    Write-Host "Or use Google Cloud Shell: https://shell.cloud.google.com/" -ForegroundColor Yellow
    exit 1
}

# Check if cors.json exists
if (-not (Test-Path "cors.json")) {
    Write-Host "❌ cors.json file not found" -ForegroundColor Red
    Write-Host "Please ensure cors.json is in the current directory" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ CORS configuration file found" -ForegroundColor Green

Write-Host "Authenticating with Google Cloud..." -ForegroundColor Yellow
try {
    gcloud auth login
    Write-Host "✓ Authentication successful" -ForegroundColor Green
} catch {
    Write-Host "❌ Authentication failed" -ForegroundColor Red
    exit 1
}

Write-Host "Setting project to $PROJECT_ID..." -ForegroundColor Yellow
try {
    gcloud config set project $PROJECT_ID
    Write-Host "✓ Project set successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to set project" -ForegroundColor Red
    exit 1
}

Write-Host "Applying CORS configuration to storage bucket..." -ForegroundColor Yellow
try {
    gsutil cors set cors.json gs://$BUCKET_NAME
    Write-Host "✓ CORS configuration applied successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to apply CORS configuration" -ForegroundColor Red
    Write-Host "Make sure you have proper permissions for the bucket" -ForegroundColor Yellow
    exit 1
}

Write-Host "\n🎉 CORS setup completed successfully!" -ForegroundColor Green
Write-Host "You can now upload images from your Flutter web app." -ForegroundColor Green

# Optional: View current CORS configuration
Write-Host "\nCurrent CORS configuration:" -ForegroundColor Cyan
try {
    gsutil cors get gs://$BUCKET_NAME
} catch {
    Write-Host "Could not retrieve CORS configuration" -ForegroundColor Yellow
}

Write-Host "\n📝 Next steps:" -ForegroundColor Cyan
Write-Host "1. Restart your Flutter web application" -ForegroundColor White
Write-Host "2. Clear browser cache if needed" -ForegroundColor White
Write-Host "3. Try uploading an image - the CORS error should be resolved" -ForegroundColor White
