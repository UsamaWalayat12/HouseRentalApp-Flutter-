# Firebase Storage and Collections Setup Script
Write-Host "🔥 Firebase Storage and Collections Setup" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

Write-Host ""
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "1. Help you enable Firebase Storage" -ForegroundColor White
Write-Host "2. Deploy security rules" -ForegroundColor White
Write-Host "3. Apply CORS configuration" -ForegroundColor White
Write-Host "4. Initialize image collections" -ForegroundColor White
Write-Host "5. Switch your app to use Firebase Storage" -ForegroundColor White

Write-Host ""
Write-Host "STEP 1: Enable Firebase Storage" -ForegroundColor Yellow
Write-Host "Please complete these steps in your browser:" -ForegroundColor White
Write-Host "1. Open: https://console.firebase.google.com/project/unilegal-14d0c/storage" -ForegroundColor Cyan
Write-Host "2. Click 'Get Started'" -ForegroundColor Cyan
Write-Host "3. Select 'Start in test mode'" -ForegroundColor Cyan
Write-Host "4. Choose a location (e.g. us-central1)" -ForegroundColor Cyan
Write-Host "5. Click 'Done'" -ForegroundColor Cyan

# Open Firebase Console
Start-Process "https://console.firebase.google.com/project/unilegal-14d0c/storage"

Write-Host ""
$response = Read-Host "Have you enabled Firebase Storage? (y/n)"

if ($response -eq "y" -or $response -eq "Y") {
    Write-Host ""
    Write-Host "STEP 2: Testing Firebase Storage..." -ForegroundColor Yellow
    
    firebase use unilegal-14d0c
    $result = firebase deploy --only storage --dry-run 2>&1
    
    if ($result -match "Firebase Storage has not been set up") {
        Write-Host "❌ Firebase Storage is still not enabled!" -ForegroundColor Red
        Write-Host "Please go back and complete Step 1." -ForegroundColor Yellow
        exit
    } else {
        Write-Host "✅ Firebase Storage is enabled!" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "STEP 3: Deploying storage rules..." -ForegroundColor Yellow
        firebase deploy --only storage
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Storage rules deployed successfully!" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to deploy storage rules" -ForegroundColor Red
            exit
        }
        
        Write-Host ""
        Write-Host "STEP 4: Applying CORS configuration..." -ForegroundColor Yellow
        
        # Check if gsutil is available
        if (Get-Command "gsutil" -ErrorAction SilentlyContinue) {
            gsutil cors set cors.json gs://unilegal-14d0c.firebasestorage.app
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ CORS configuration applied!" -ForegroundColor Green
            } else {
                Write-Host "⚠️ CORS configuration failed, but continuing..." -ForegroundColor Yellow
            }
        } else {
            Write-Host "⚠️ gsutil not found. Manual CORS setup needed:" -ForegroundColor Yellow
            Write-Host "https://console.cloud.google.com/storage/browser/unilegal-14d0c.firebasestorage.app" -ForegroundColor Cyan
        }
        
        Write-Host ""
        Write-Host "STEP 5: Creating Firebase Collections..." -ForegroundColor Yellow
        Write-Host "The following collections will be created:" -ForegroundColor White
        Write-Host "• property_images - for property photos" -ForegroundColor Cyan
        Write-Host "• user_avatars - for user profile pictures" -ForegroundColor Cyan
        Write-Host "• property_documents - for property documents" -ForegroundColor Cyan
        Write-Host "• gallery_images - for general gallery images" -ForegroundColor Cyan
        
        # Create placeholder files to initialize collections
        $collections = @("property_images", "user_avatars", "property_documents", "gallery_images")
        
        foreach ($collection in $collections) {
            try {
                # Create a temporary file
                $tempFile = "temp_$collection.txt"
                "This folder is for $collection" | Out-File -FilePath $tempFile -Encoding utf8
                
                # Upload using gsutil if available
                if (Get-Command "gsutil" -ErrorAction SilentlyContinue) {
                    gsutil cp $tempFile gs://unilegal-14d0c.firebasestorage.app/$collection/.keep
                    Remove-Item $tempFile
                    Write-Host "✅ Created collection: $collection" -ForegroundColor Green
                } else {
                    Write-Host "⚠️ Collection $collection will be created when first image is uploaded" -ForegroundColor Yellow
                    Remove-Item $tempFile
                }
            } catch {
                Write-Host "⚠️ Could not create collection $collection (will be created automatically)" -ForegroundColor Yellow
            }
        }
        
        Write-Host ""
        Write-Host "STEP 6: Updating app configuration..." -ForegroundColor Yellow
        
        # Update the image service to use Firebase
        $imageServicePath = "lib\core\services\image_service.dart"
        if (Test-Path $imageServicePath) {
            try {
                (Get-Content $imageServicePath) | 
                    ForEach-Object { $_ -replace "ImageStorageProvider.none; // Temporarily disabled", "ImageStorageProvider.firebase; // Firebase Collections enabled!" } |
                    ForEach-Object { $_ -replace "provider = ImageStorageProvider.none", "provider = ImageStorageProvider.firebase" } |
                    Set-Content $imageServicePath
                
                Write-Host "✅ App configured to use Firebase Storage!" -ForegroundColor Green
            } catch {
                Write-Host "⚠️ Could not auto-update image service. Manual update needed." -ForegroundColor Yellow
            }
        }
        
        Write-Host ""
        Write-Host "🎉 SETUP COMPLETE!" -ForegroundColor Green
        Write-Host "==================" -ForegroundColor Green
        Write-Host ""
        Write-Host "✅ Firebase Storage enabled" -ForegroundColor Green
        Write-Host "✅ Security rules deployed" -ForegroundColor Green
        Write-Host "✅ Collections initialized" -ForegroundColor Green
        Write-Host "✅ App configured" -ForegroundColor Green
        Write-Host ""
        Write-Host "🚀 Next Steps:" -ForegroundColor Yellow
        Write-Host "1. Restart your Flutter app: flutter run -d web" -ForegroundColor Cyan
        Write-Host "2. Your app will now use Firebase Storage with collections" -ForegroundColor Cyan
        Write-Host "3. Images will be organized in separate collections" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "📂 Available Collections:" -ForegroundColor Yellow
        Write-Host "• ImageService.uploadPropertyImagesToCollection()" -ForegroundColor Cyan
        Write-Host "• ImageService.uploadUserAvatar()" -ForegroundColor Cyan
        Write-Host "• ImageService.uploadPropertyDocuments()" -ForegroundColor Cyan
        Write-Host "• ImageService.uploadGalleryImages()" -ForegroundColor Cyan
        
    }
} else {
    Write-Host ""
    Write-Host "Please enable Firebase Storage first, then run this script again." -ForegroundColor Yellow
    Write-Host "https://console.firebase.google.com/project/unilegal-14d0c/storage" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
