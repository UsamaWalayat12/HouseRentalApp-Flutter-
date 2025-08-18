@echo off
echo ========================================
echo Firebase Storage Setup Commands
echo ========================================
echo.
echo 1. First, enable Firebase Storage in console:
echo    https://console.firebase.google.com/project/unilegal-14d0c/storage
echo.
echo 2. Then run these commands:
echo.
echo Setting Firebase project...
firebase use unilegal-14d0c
echo.
echo Deploying storage rules...
firebase deploy --only storage
echo.
echo ========================================
echo If you see success messages above, 
echo restart your Flutter app with:
echo flutter run -d web
echo ========================================
pause
