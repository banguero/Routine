# Real Photo Analysis Setup Guide

This guide explains how to enable real AI-powered food recognition in the Routine app.

## Overview

The app now supports three modes for food recognition:

1. **OpenAI GPT-4 Vision** (Recommended for development) - Direct client-side API calls
2. **Firebase Functions** (Recommended for production) - Server-side processing with secure API key storage
3. **Mock Mode** - Fallback with simulated data for testing

## Option 1: OpenAI GPT-4 Vision (Quick Start)

This is the fastest way to get real food recognition working.

### Step 1: Get an OpenAI API Key

1. Go to https://platform.openai.com/api-keys
2. Sign in or create an account
3. Click "Create new secret key"
4. Copy the key (starts with `sk-...`)

**Pricing**: GPT-4o costs approximately $0.01-0.03 per image analysis. See https://openai.com/pricing for current rates.

### Step 2: Configure the App

**Option A: Using Config.plist (Recommended)**

1. Copy the template:
   ```bash
   cp Routine/Config.plist.template Routine/Config.plist
   ```

2. Open `Routine/Config.plist` in Xcode or a text editor

3. Replace `YOUR_API_KEY_HERE` with your actual OpenAI API key

4. Build and run the app

**Option B: Using Environment Variable**

Set the environment variable before building:

```bash
export OPENAI_API_KEY="sk-your-key-here"
```

Or add to your Xcode scheme:
1. Product → Scheme → Edit Scheme
2. Select "Run" → "Arguments" tab
3. Add Environment Variable: `OPENAI_API_KEY` = `sk-your-key-here`

### Step 3: Test It

1. Build and run the app on a device or simulator
2. Tap the "+" button → "Scan Food"
3. Take a photo of food or select from library
4. Tap "Use Photo"
5. Wait 3-5 seconds for AI analysis
6. The meal should appear with real AI-generated nutrition data!

### Console Output

When working correctly, you'll see:
```
🤖 Analyzing food photo with AI...
✅ AI Analysis complete: Grilled Salmon with Vegetables
   Confidence: 88%
   Ingredients: 3
   Total Calories: 510
📤 Uploading image to Firebase Storage...
✅ Image uploaded: https://firebasestorage.googleapis.com/...
💾 Saving to Firestore...
✅ Food entry saved successfully!
```

## Option 2: Firebase Functions (Production)

For production apps, use Firebase Functions to keep your API key secure on the server.

### Step 1: Set Up Firebase Functions

```bash
# Install Firebase CLI if you haven't
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Functions (if not already done)
cd /path/to/Routine
firebase init functions

# Choose:
# - JavaScript
# - Yes to ESLint (optional)
# - Yes to install dependencies
```

### Step 2: Install Dependencies

```bash
cd functions
npm install openai
```

### Step 3: Create the Function

Replace `functions/index.js` with:

```javascript
const functions = require('firebase-functions');
const { OpenAI } = require('openai');

// Initialize OpenAI with API key from Firebase config
// Set with: firebase functions:config:set openai.key="YOUR_KEY"
const openai = new OpenAI({
  apiKey: functions.config().openai.key,
});

exports.analyzeFoodImage = functions.https.onCall(async (data, context) => {
  // Verify user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to analyze food images'
    );
  }

  const { image, mimeType } = data;

  if (!image) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Image data is required'
    );
  }

  try {
    const prompt = `Analyze this food photo and provide a detailed nutritional breakdown.

Identify all food items visible in the image, estimate portion sizes, and provide nutritional information for each ingredient.

Return ONLY valid JSON in this exact format (no markdown, no code blocks, just raw JSON):
{
  "meal_name": "Descriptive name of the meal",
  "confidence": 0.85,
  "analysis": "Brief 1-2 sentence analysis of the meal's nutritional quality, health benefits, and any suggestions for improvement",
  "ingredients": [
    {
      "name": "Ingredient name with portion (e.g., 'Grilled chicken breast (5 oz)')",
      "quantity": 1.0,
      "measurement_type": "servings",
      "calories": 230,
      "protein": 43,
      "carbs": 0,
      "fat": 5,
      "sugar": 0,
      "fiber": 0,
      "sodium": 90
    }
  ]
}

Guidelines:
- Be specific with ingredient names and include portion sizes in the name
- Estimate realistic portion sizes based on the image
- Provide accurate nutritional data (use USDA FoodData Central as reference)
- Include all visible components (oils, sauces, seasonings, etc.)
- measurement_type must be one of: servings, grams, ounces, cups, tbsp, tsp, pieces, ml, l
- confidence should be between 0.0 and 1.0 based on how clearly you can identify the foods
- For analysis, be concise but informative about nutritional balance, health aspects, and suggestions`;

    const response = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "user",
          content: [
            { type: "text", text: prompt },
            {
              type: "image_url",
              image_url: {
                url: `data:${mimeType || 'image/jpeg'};base64,${image}`,
                detail: "high"
              }
            }
          ]
        }
      ],
      max_tokens: 2000,
      temperature: 0.3
    });

    const content = response.choices[0].message.content;

    // Clean up markdown code blocks if present
    let jsonString = content.trim();
    if (jsonString.startsWith('```json')) {
      jsonString = jsonString.substring(7);
    } else if (jsonString.startsWith('```')) {
      jsonString = jsonString.substring(3);
    }
    if (jsonString.endsWith('```')) {
      jsonString = jsonString.substring(0, jsonString.length - 3);
    }

    const result = JSON.parse(jsonString.trim());
    
    // Log for monitoring
    console.log(`Food analyzed for user ${context.auth.uid}: ${result.meal_name}`);
    
    return result;

  } catch (error) {
    console.error('Error analyzing food image:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to analyze image: ' + error.message
    );
  }
});
```

### Step 4: Configure API Key

```bash
# Set your OpenAI API key in Firebase config
firebase functions:config:set openai.key="sk-your-actual-key-here"

# Verify it was set
firebase functions:config:get
```

### Step 5: Deploy

```bash
# Deploy only the function
firebase deploy --only functions:analyzeFoodImage

# Or deploy all functions
firebase deploy --only functions
```

### Step 6: Update iOS App

In `FoodRecognitionService.swift`, change the initialization:

```swift
// Change from:
init(mode: RecognitionMode = .openAI)

// To:
init(mode: RecognitionMode = .firebaseFunctions)
```

Or update `FoodLogViewModel.swift`:

```swift
private let recognitionService = FoodRecognitionService(mode: .firebaseFunctions)
```

### Step 7: Test

Build and run the app - it will now use your Firebase Function for analysis!

## Option 3: Mock Mode (Testing)

Mock mode is automatically used when:
- No API key is configured
- API calls fail
- You explicitly set mode to `.mock`

This is useful for:
- UI development
- Testing without API costs
- Demo mode

## Switching Between Modes

### In Code

**FoodLogViewModel.swift:**
```swift
// Use OpenAI directly (client-side)
private let recognitionService = FoodRecognitionService(mode: .openAI)

// Use Firebase Functions (server-side)
private let recognitionService = FoodRecognitionService(mode: .firebaseFunctions)

// Use mock data
private let recognitionService = FoodRecognitionService(mode: .mock)
```

## Monitoring Usage

### OpenAI Dashboard

View usage and costs at: https://platform.openai.com/usage

### Firebase Functions Logs

```bash
# View logs
firebase functions:log --only analyzeFoodImage

# Or in Firebase Console:
# https://console.firebase.google.com/project/_/functions/logs
```

## Troubleshooting

### "OpenAI API key not configured"

**Solution**: Make sure `Config.plist` exists and contains a valid key, or set the `OPENAI_API_KEY` environment variable.

### "HTTP 401: Incorrect API key"

**Solution**: 
1. Verify your API key is correct
2. Check that your OpenAI account has credits
3. Ensure the key hasn't been revoked

### "HTTP 429: Rate limit exceeded"

**Solution**:
1. You've hit OpenAI's rate limits
2. Wait a moment and try again
3. Consider upgrading your OpenAI plan
4. Or implement request queuing

### "Failed to analyze image" (Firebase Functions)

**Solution**:
1. Check Firebase Functions logs: `firebase functions:log`
2. Verify the API key is set: `firebase functions:config:get`
3. Ensure the function deployed successfully
4. Check that the user is authenticated

### Images not uploading to Firebase Storage

**Solution**:
1. Verify `GoogleService-Info.plist` is in your project
2. Check Firebase Storage security rules
3. Ensure user is authenticated
4. Check Storage logs in Firebase Console

### Analysis returns mock data instead of real AI

**Solution**:
1. Check Xcode console for error messages
2. Verify API key configuration
3. Check network connectivity
4. Ensure Firebase Functions are deployed (if using that mode)

## Security Best Practices

### For Development (OpenAI Direct)

- ✅ Use Config.plist (gitignored)
- ✅ Never commit API keys to git
- ✅ Use environment variables in CI/CD
- ❌ Don't hardcode keys in source

### For Production (Firebase Functions)

- ✅ Store API key in Firebase config
- ✅ Require authentication for function calls
- ✅ Implement rate limiting
- ✅ Monitor usage and costs
- ✅ Set up budget alerts in OpenAI
- ✅ Consider caching common foods

## Cost Optimization

### OpenAI GPT-4o Pricing (as of 2024)

- ~$0.01-0.03 per image analysis
- Depends on image size and detail level

### Tips to Reduce Costs

1. **Compress images** before sending (already done: 0.8 JPEG quality)
2. **Cache results** - if user scans same meal, reuse analysis
3. **Resize large images** - GPT-4o charges by token, smaller images = fewer tokens
4. **Use lower detail** - Change `"detail": "high"` to `"low"` in the API call
5. **Implement user quotas** - Limit scans per day for free tier users

### Example: Adding Image Resizing

```swift
// In OpenAIFoodRecognitionService.swift, before encoding:
let maxDimension: CGFloat = 1024
let resizedImage = image.resized(to: maxDimension)
guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else { ... }
```

## Next Steps

1. **Add Nutrition Database Fallback**: Integrate USDA FoodData Central for validation
2. **Implement Caching**: Cache analysis results to reduce API calls
3. **Add User Feedback**: Let users correct AI estimates to improve accuracy
4. **Barcode Scanning**: Add barcode support for packaged foods
5. **Meal History**: Suggest previous meals for quick logging

## Support

- OpenAI API Docs: https://platform.openai.com/docs
- Firebase Functions Docs: https://firebase.google.com/docs/functions
- Routine App Issues: Check console logs and error messages
