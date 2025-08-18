# Test Firebase Storage Setup
Write-Host "Testing Firebase Storage Setup..." -ForegroundColor Yellow

# Check if Firebase CLI is available
if (!(Get-Command "firebase" -ErrorAction SilentlyContinue)) {
    Write-Host "Firebase CLI not found!" -ForegroundColor Red
    exit 1
}

# Set project
Write-Host "Setting Firebase project..." -ForegroundColor Cyan
firebase use unilegal-14d0c

# Test storage deployment
Write-Host "Testing Firebase Storage..." -ForegroundColor Cyan
firebase deploy --only storage --dry-run
