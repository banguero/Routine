// OpenAIFoodRecognitionService.swift

import Foundation
import UIKit

enum FoodRecognitionError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case imageEncodingFailed
    case missingAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return "API Error: \(message)"
        case .imageEncodingFailed:
            return "Failed to encode image"
        case .missingAPIKey:
            return "OpenAI API key not configured. Add your key to Config.plist or set OPENAI_API_KEY environment variable."
        }
    }
}

class OpenAIFoodRecognitionService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let session: URLSession
    
    init(apiKey: String? = nil) throws {
        // Try to get API key from parameter, config file, or environment
        if let key = apiKey {
            self.apiKey = key
        } else if let key = Self.loadAPIKeyFromConfig() {
            self.apiKey = key
        } else if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            self.apiKey = key
        } else {
            throw FoodRecognitionError.missingAPIKey
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 120
        self.session = URLSession(configuration: config)
    }
    
    private static func loadAPIKeyFromConfig() -> String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["OPENAI_API_KEY"] as? String,
              !key.isEmpty,
              key != "YOUR_API_KEY_HERE" else {
            return nil
        }
        return key
    }
    
    func recognizeMeal(from image: UIImage) async throws -> RecognizedMeal {
        // Resize image to reduce API costs (max 1024px dimension)
        // GPT-4o charges based on image size, so this saves money
        let resizedImage = image.resized(to: 1024)
        
        // Convert image to base64
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            throw FoodRecognitionError.imageEncodingFailed
        }
        
        let base64Image = imageData.base64EncodedString()
        
        print("📸 Image resized from \(Int(image.size.width))x\(Int(image.size.height)) to \(Int(resizedImage.size.width))x\(Int(resizedImage.size.height))")
        print("📦 Image data size: \(imageData.count / 1024) KB")
        
        // Create the request
        let request = try createRequest(with: base64Image)
        
        // Make the API call
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FoodRecognitionError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw FoodRecognitionError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        // Parse the response
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let content = openAIResponse.choices.first?.message.content else {
            throw FoodRecognitionError.invalidResponse
        }
        
        // Parse the JSON from the content
        return try parseMeal(from: content)
    }
    
    private func createRequest(with base64Image: String) throws -> URLRequest {
        guard let url = URL(string: baseURL) else {
            throw FoodRecognitionError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        Analyze this food photo and provide a detailed nutritional breakdown.
        
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
        - For analysis, be concise but informative about nutritional balance, health aspects, and suggestions
        """
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",  // Using GPT-4o for vision capabilities
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": prompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)",
                                "detail": "high"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 2000,
            "temperature": 0.3
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        return request
    }
    
    private func parseMeal(from content: String) throws -> RecognizedMeal {
        // Clean up the content - remove markdown code blocks if present
        var jsonString = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if jsonString.hasPrefix("```json") {
            jsonString = String(jsonString.dropFirst(7))
        } else if jsonString.hasPrefix("```") {
            jsonString = String(jsonString.dropFirst(3))
        }
        
        if jsonString.hasSuffix("```") {
            jsonString = String(jsonString.dropLast(3))
        }
        
        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw FoodRecognitionError.invalidResponse
        }
        
        let mealData = try JSONDecoder().decode(OpenAIMealResponse.self, from: jsonData)
        
        let ingredients = mealData.ingredients.map { ing in
            Ingredient(
                id: UUID().uuidString,
                name: ing.name,
                quantity: ing.quantity,
                measurementType: MeasurementType(rawValue: ing.measurement_type) ?? .servings,
                calories: ing.calories,
                protein: ing.protein,
                carbs: ing.carbs,
                fat: ing.fat,
                sugar: ing.sugar,
                fiber: ing.fiber,
                sodium: ing.sodium
            )
        }
        
        return RecognizedMeal(
            name: mealData.meal_name,
            ingredients: ingredients,
            confidence: mealData.confidence,
            analysis: mealData.analysis
        )
    }
}

// MARK: - OpenAI API Response Models

private struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

private struct OpenAIMealResponse: Codable {
    let meal_name: String
    let confidence: Double
    let analysis: String
    let ingredients: [IngredientResponse]
    
    struct IngredientResponse: Codable {
        let name: String
        let quantity: Double
        let measurement_type: String
        let calories: Double
        let protein: Double
        let carbs: Double
        let fat: Double
        let sugar: Double
        let fiber: Double
        let sodium: Double
    }
}
