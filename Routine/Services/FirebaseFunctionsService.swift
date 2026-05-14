// FirebaseFunctionsService.swift
// Server-side food recognition using Firebase Functions
// This is more secure than client-side API calls as API keys stay on the server
//
// NOTE: To use this service, add FirebaseFunctions via Swift Package Manager:
// https://github.com/firebase/firebase-ios-sdk
// Then change the FoodRecognitionService mode to .firebaseFunctions

import Foundation
import UIKit

// This service requires FirebaseFunctions framework
// Add it via SPM if you want to use server-side food recognition
// For now, this is a stub that will throw an error if used

class FirebaseFunctionsService {
    init() {}
    
    func recognizeMeal(from image: UIImage) async throws -> RecognizedMeal {
        throw FoodRecognitionError.apiError(
            "FirebaseFunctions not configured. " +
            "To enable server-side food recognition:\n" +
            "1. Add FirebaseFunctions via Swift Package Manager\n" +
            "2. See PHOTO_ANALYSIS_SETUP.md for deployment instructions\n" +
            "3. Change FoodRecognitionService mode to .firebaseFunctions"
        )
    }
}

/*
 
 FIREBASE FUNCTIONS SETUP
 ========================
 
 To use this service, deploy the following Firebase Function:
 
 File: functions/index.js
 
 const functions = require('firebase-functions');
 const { OpenAI } = require('openai');
 
 const openai = new OpenAI({
   apiKey: functions.config().openai.key // Set with: firebase functions:config:set openai.key="YOUR_KEY"
 });
 
 exports.analyzeFoodImage = functions.https.onCall(async (data, context) => {
   // Verify authentication
   if (!context.auth) {
     throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
   }
   
   const { image, mimeType } = data;
   
   if (!image) {
     throw new functions.https.HttpsError('invalid-argument', 'Image data is required');
   }
   
   try {
     const prompt = `Analyze this food photo and provide a detailed nutritional breakdown.
     
     Identify all food items visible in the image, estimate portion sizes, and provide nutritional information for each ingredient.
     
     Return ONLY valid JSON in this exact format (no markdown, no code blocks, just raw JSON):
     {
       "meal_name": "Descriptive name of the meal",
       "confidence": 0.85,
       "analysis": "Brief 1-2 sentence analysis of the meal's nutritional quality",
       "ingredients": [
         {
           "name": "Ingredient name with portion",
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
     }`;
     
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
     
     // Clean up markdown if present
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
     return result;
     
   } catch (error) {
     console.error('Error analyzing food image:', error);
     throw new functions.https.HttpsError('internal', 'Failed to analyze image');
   }
 });
 
 DEPLOYMENT:
 1. cd functions
 2. npm install openai
 3. firebase functions:config:set openai.key="YOUR_OPENAI_API_KEY"
 4. firebase deploy --only functions
 
 */
