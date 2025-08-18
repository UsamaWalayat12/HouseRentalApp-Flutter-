# Script to enable Firebase Storage and switch back
Write-Host "Firebase Storage Enablement Script" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

Write-Host ""
Write-Host "STEP 1: Enable Firebase Storage" -ForegroundColor Yellow
Write-Host "Please complete these steps:" -ForegroundColor White
Write-Host "1. Open: https://console.firebase.google.com/project/unilegal-14d0c/storage" -ForegroundColor Cyan
Write-Host "2. Click 'Get Started'" -ForegroundColor Cyan
Write-Host "3. Select 'Start in test mode'" -ForegroundColor Cyan
Write-Host "4. Choose a location (e.g., us-central1)" -ForegroundColor Cyan
Write-Host "5. Click 'Done'" -ForegroundColor Cyan

Write-Host ""
$response = Read-Host "Have you completed the above steps? (y/n)"

if ($response -eq "y" -or $response -eq "Y") {
    Write-Host ""
    Write-Host "STEP 2: Testing Firebase Storage..." -ForegroundColor Yellow
    
    firebase use unilegal-14d0c
    $result = firebase deploy --only storage --dry-run 2>&1
    
    if ($result -match "Firebase Storage has not been set up") {
        Write-Host "❌ Firebase Storage is still not enabled!" -ForegroundColor Red
        Write-Host "Please go back and complete Step 1." -ForegroundColor Yellow
    } else {
        Write-Host "✅ Firebase Storage is enabled!" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "STEP 3: Deploying storage rules..." -ForegroundColor Yellow
        firebase deploy --only storage
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "STEP 4: Switching app to use Firebase Storage..." -ForegroundColor Yellow
            
            # Update the image service to use Firebase
            $imageServicePath = "lib\core\services\image_service.dart"
            if (Test-Path $imageServicePath) {
                (Get-Content $imageServicePath) | 
                    Foreach-Object { $_ -replace "ImageStorageProvider.none; // Temporarily disabled", "ImageStorageProvider.firebase; // Firebase enabled!" } |
                    Foreach-Object { $_ -replace "provider = ImageStorageProvider.none", "provider = ImageStorageProvider.firebase" } |
                    Set-Content $imageServicePath
                
                Write-Host "✅ App configured to use Firebase Storage!" -ForegroundColor Green
            }
            
            Write-Host ""
            Write-Host "🎉 SUCCESS! Firebase Storage is now enabled and configured!" -ForegroundColor Green
            Write-Host "🚀 Restart your Flutter app: flutter run -d web" -ForegroundColor Yellow
        } else {
            Write-Host "❌ Failed to deploy storage rules" -ForegroundColor Red
        }
    }
} else {
    Write-Host ""
    Write-Host "Please complete Step 1 first, then run this script again." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
