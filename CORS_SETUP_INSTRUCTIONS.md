# Firebase Storage CORS Setup Instructions

## Problem
Your Flutter web app can't upload images to Firebase Storage due to CORS policy restrictions from localhost.

## Solution Steps

### 1. Install Google Cloud SDK
- **Windows**: Download and install from https://cloud.google.com/sdk/docs/install-sdk
- **Alternative**: Use Google Cloud Shell (browser-based) at https://shell.cloud.google.com/

### 2. Authenticate and Set Project
Open your terminal/command prompt and run:

```bash
# Authenticate with Google Cloud
gcloud auth login

# Set your project
gcloud config set project unilegal-14d0c
```

### 3. Apply CORS Configuration
Run this command to apply the CORS configuration:

```bash
# Apply CORS settings to your storage bucket
gsutil cors set cors.json gs://unilegal-14d0c.firebasestorage.app
```

### 4. Verify CORS Configuration
Check if CORS was applied successfully:

```bash
# View current CORS configuration
gsutil cors get gs://unilegal-14d0c.firebasestorage.app
```

## Alternative Method: Use Firebase Console

If you can't install Google Cloud SDK:

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project `unilegal-14d0c`
3. Navigate to **Storage** > **Rules**
4. Update storage rules to allow authenticated uploads
5. Navigate to **Storage** > **Files** and check bucket settings

## Testing
After applying CORS configuration:
1. Restart your Flutter web app
2. Try uploading an image
3. The CORS error should be resolved

## Troubleshooting
- If still getting CORS errors, wait 5-10 minutes for changes to propagate
- Clear browser cache and restart
- Check Firebase Storage rules are properly set
