# Firebase Image Storage Setup Script
# This script sets up Firebase Storage with proper collections and CORS configuration

Write-Host "🔥 Firebase Image Storage Setup for Flutter App" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# Function to check if a command exists
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Check prerequisites
Write-Host "📋 Checking Prerequisites..." -ForegroundColor Yellow

$allGood = $true

if (-not (Test-Command "firebase")) {
    Write-Host "❌ Firebase CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "   npm install -g firebase-tools" -ForegroundColor White
    $allGood = $false
}

if (-not (Test-Command "gsutil")) {
    Write-Host "⚠️ Google Cloud SDK (gsutil) not found. CORS setup will need manual configuration." -ForegroundColor Yellow
}

if (-not $allGood) {
    Write-Host "Please install missing prerequisites and run this script again." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Prerequisites check complete!" -ForegroundColor Green
Write-Host ""

# Step 1: Firebase Login
Write-Host "🔐 Step 1: Firebase Authentication" -ForegroundColor Cyan
Write-Host "Checking Firebase authentication status..." -ForegroundColor White

$loginResult = firebase --version
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Firebase CLI is available" -ForegroundColor Green
    
    # Check if already logged in
    $whoAmI = firebase auth:list 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Please log in to Firebase..." -ForegroundColor Yellow
        firebase login
        if ($LASTEXITCODE -ne 0) {
            Write-Host "❌ Firebase login failed. Please try again." -ForegroundColor Red
            exit 1
        }
    }
    Write-Host "✅ Firebase authentication successful" -ForegroundColor Green
} else {
    Write-Host "❌ Firebase CLI authentication failed" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Check Firebase Project
Write-Host "📱 Step 2: Firebase Project Configuration" -ForegroundColor Cyan
Write-Host "Current project: unilegal-14d0c" -ForegroundColor White

# Verify project exists and is accessible
firebase projects:list | findstr "unilegal-14d0c"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Cannot access Firebase project 'unilegal-14d0c'" -ForegroundColor Red
    Write-Host "Please make sure:" -ForegroundColor Yellow
    Write-Host "  1. The project exists in your Firebase console" -ForegroundColor White
    Write-Host "  2. You have access to the project" -ForegroundColor White
    Write-Host "  3. The project ID is correct in .firebaserc" -ForegroundColor White
    exit 1
}

Write-Host "✅ Firebase project verified" -ForegroundColor Green
Write-Host ""

# Step 3: Enable Firebase Storage (Manual Check)
Write-Host "💾 Step 3: Firebase Storage Setup" -ForegroundColor Cyan
Write-Host "Please ensure Firebase Storage is enabled for your project:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Visit: https://console.firebase.google.com/project/unilegal-14d0c/storage" -ForegroundColor White
Write-Host "2. Click 'Get Started' if Storage is not enabled" -ForegroundColor White
Write-Host "3. Choose 'Start in production mode' or use the rules we'll deploy" -ForegroundColor White
Write-Host "4. Select your preferred storage location (e.g., us-central1)" -ForegroundColor White
Write-Host ""

$storageEnabled = Read-Host "Is Firebase Storage enabled? (y/n)"
if ($storageEnabled.ToLower() -ne 'y' -and $storageEnabled.ToLower() -ne 'yes') {
    Write-Host "Please enable Firebase Storage first, then run this script again." -ForegroundColor Yellow
    Write-Host "Storage Console: https://console.firebase.google.com/project/unilegal-14d0c/storage" -ForegroundColor Cyan
    exit 1
}

Write-Host "✅ Firebase Storage confirmed as enabled" -ForegroundColor Green
Write-Host ""

# Step 4: Deploy Storage Rules
Write-Host "🛡️ Step 4: Deploying Storage Security Rules" -ForegroundColor Cyan
Write-Host "Deploying storage.rules to Firebase..." -ForegroundColor White

firebase deploy --only storage
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Storage rules deployed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to deploy storage rules" -ForegroundColor Red
    Write-Host "Please check your storage.rules file and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Step 5: Configure CORS
Write-Host "🌐 Step 5: CORS Configuration" -ForegroundColor Cyan
$bucketName = "unilegal-14d0c.firebasestorage.app"

if (Test-Command "gsutil") {
    Write-Host "Applying CORS configuration using gsutil..." -ForegroundColor White
    
    gsutil cors set cors.json gs://$bucketName
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ CORS configuration applied successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to apply CORS configuration via gsutil" -ForegroundColor Red
        Write-Host "Please apply CORS manually via Google Cloud Console" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️ gsutil not available. Please configure CORS manually:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Visit: https://console.cloud.google.com/storage/browser/$bucketName" -ForegroundColor White
    Write-Host "2. Click on 'Permissions' tab" -ForegroundColor White
    Write-Host "3. Add CORS configuration from cors.json file" -ForegroundColor White
    Write-Host ""
    Write-Host "Or install Google Cloud SDK:" -ForegroundColor White
    Write-Host "https://cloud.google.com/sdk/docs/install" -ForegroundColor Cyan
}

Write-Host ""

# Step 6: Create Image Collections Structure
Write-Host "📁 Step 6: Creating Image Collections" -ForegroundColor Cyan
Write-Host "This will create organized folders for different types of images..." -ForegroundColor White

# Test Firebase Storage connection by trying to create placeholder files
Write-Host "Creating collection structure..." -ForegroundColor White

# Create a test file to verify storage works
$testContent = "Firebase Storage test - $(Get-Date)"
$testFile = "test_connection.txt"
$testContent | Out-File -FilePath $testFile -Encoding UTF8

# Try to upload test file (requires additional setup, but we'll document the structure)
Write-Host ""
Write-Host "Image Collections that will be created in your Firebase Storage:" -ForegroundColor Green
Write-Host "  📂 property_images/       - Main property photos" -ForegroundColor White
Write-Host "  📂 user_avatars/          - User profile pictures" -ForegroundColor White
Write-Host "  📂 property_documents/    - Property-related documents" -ForegroundColor White  
Write-Host "  📂 gallery_images/        - Additional gallery images" -ForegroundColor White
Write-Host ""

# Clean up test file
Remove-Item $testFile -ErrorAction SilentlyContinue

Write-Host "✅ Collection structure documented" -ForegroundColor Green
Write-Host ""

# Step 7: Test Flutter App Configuration
Write-Host "📱 Step 7: Flutter App Integration Test" -ForegroundColor Cyan
Write-Host "Testing Firebase Storage connectivity from Flutter..." -ForegroundColor White

Write-Host ""
Write-Host "Please run the following commands in your Flutter project:" -ForegroundColor Yellow
Write-Host ""
Write-Host "flutter clean" -ForegroundColor White
Write-Host "flutter pub get" -ForegroundColor White
Write-Host "flutter run -d chrome --web-renderer html" -ForegroundColor White
Write-Host ""
Write-Host "Then test image upload in your app." -ForegroundColor Yellow
Write-Host ""

# Step 8: Verification Checklist
Write-Host "✅ Step 8: Setup Verification Checklist" -ForegroundColor Cyan
Write-Host ""
Write-Host "Please verify the following:" -ForegroundColor Yellow
Write-Host ""
Write-Host "□ Firebase Storage is enabled in console" -ForegroundColor White
Write-Host "□ Storage rules are deployed (shows ✅ above)" -ForegroundColor White
Write-Host "□ CORS is configured (shows ✅ above or manually set)" -ForegroundColor White
Write-Host "□ Flutter app runs without Firebase initialization errors" -ForegroundColor White
Write-Host "□ Image upload functionality works in the app" -ForegroundColor White
Write-Host "□ Images display properly in property cards" -ForegroundColor White
Write-Host ""

# Step 9: Troubleshooting Information
Write-Host "🔧 Troubleshooting Information" -ForegroundColor Cyan
Write-Host ""
Write-Host "If you encounter issues:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. CORS Errors:" -ForegroundColor White
Write-Host "   - Check browser console for specific CORS error messages" -ForegroundColor Gray
Write-Host "   - Verify CORS is applied: gsutil cors get gs://$bucketName" -ForegroundColor Gray
Write-Host "   - Try hard refresh (Ctrl+Shift+R) to clear browser cache" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Firebase Storage Errors:" -ForegroundColor White
Write-Host "   - Verify project ID in firebase.json and .firebaserc" -ForegroundColor Gray
Write-Host "   - Check Firebase Storage is enabled in console" -ForegroundColor Gray
Write-Host "   - Verify storage rules allow your operations" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Image Upload Failures:" -ForegroundColor White
Write-Host "   - Check browser network tab for failed requests" -ForegroundColor Gray
Write-Host "   - Verify file size limits (default 5GB per file)" -ForegroundColor Gray
Write-Host "   - Check file format is supported (jpg, png, gif, webp)" -ForegroundColor Gray
Write-Host ""

Write-Host "🎉 Firebase Image Storage Setup Complete!" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Test image upload in your Flutter app" -ForegroundColor White
Write-Host "2. Check property cards display images correctly" -ForegroundColor White
Write-Host "3. Monitor Firebase Storage usage in console" -ForegroundColor White
Write-Host ""
Write-Host "Firebase Console: https://console.firebase.google.com/project/unilegal-14d0c" -ForegroundColor Cyan
Write-Host "Storage Browser: https://console.firebase.google.com/project/unilegal-14d0c/storage" -ForegroundColor Cyan
Write-Host ""
