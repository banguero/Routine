import SwiftUI

struct IngredientEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var ingredient: Ingredient
    @State private var quantity: String
    @State private var measurementType: MeasurementType
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fat: String
    @State private var sugar: String
    @State private var fiber: String
    @State private var sodium: String
    
    let onSave: (Ingredient) -> Void
    
    init(ingredient: Ingredient, onSave: @escaping (Ingredient) -> Void) {
        self._ingredient = State(initialValue: ingredient)
        self._quantity = State(initialValue: String(format: "%.1f", ingredient.quantity))
        self._measurementType = State(initialValue: ingredient.measurementType)
        self._calories = State(initialValue: String(format: "%.0f", ingredient.calories))
        self._protein = State(initialValue: String(format: "%.0f", ingredient.protein))
        self._carbs = State(initialValue: String(format: "%.0f", ingredient.carbs))
        self._fat = State(initialValue: String(format: "%.0f", ingredient.fat))
        self._sugar = State(initialValue: String(format: "%.0f", ingredient.sugar))
        self._fiber = State(initialValue: String(format: "%.0f", ingredient.fiber))
        self._sodium = State(initialValue: String(format: "%.0f", ingredient.sodium))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Ingredient Details Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Ingredient Details")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            // Name
                            HStack(spacing: 12) {
                                Image(systemName: "tag.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 18))
                                    .frame(width: 24)
                                
                                TextField("Ingredient name", text: $ingredient.name)
                                    .font(.system(size: 16))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            
                            Divider()
                                .padding(.leading, 52)
                            
                            // Measurement Type
                            HStack(spacing: 12) {
                                Image(systemName: "ruler")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 18))
                                    .frame(width: 24)
                                
                                Text("Measurement Type")
                                    .font(.system(size: 16))
                                
                                Spacer()
                                
                                Picker("", selection: $measurementType) {
                                    ForEach(MeasurementType.allCases, id: \.self) { type in
                                        Text(type.displayName).tag(type)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.blue)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            Divider()
                                .padding(.leading, 52)
                            
                            // Quantity
                            HStack(spacing: 12) {
                                Text("#")
                                    .foregroundColor(.green)
                                    .font(.system(size: 20, weight: .bold))
                                    .frame(width: 24)
                                
                                Text("Quantity")
                                    .font(.system(size: 16))
                                
                                Spacer()
                                
                                TextField("1.0", text: $quantity)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .font(.system(size: 16))
                                    .frame(width: 60)
                                
                                Text(measurementType.abbreviation)
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 16)
                    }
                    
                    // Nutritional Info Section
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Text("Nutritional Info")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.gray)
                                .textCase(.uppercase)
                            
                            Spacer()
                            
                            Button(action: {
                                // TODO: Implement AI calculation
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 12))
                                    Text("Calculate with AI")
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            NutrientRow(
                                icon: "flame.fill",
                                iconColor: .blue,
                                label: "Calories",
                                value: $calories,
                                unit: "cal"
                            )
                            
                            Divider().padding(.leading, 52)
                            
                            NutrientRow(
                                icon: "dumbbell.fill",
                                iconColor: .purple,
                                label: "Protein",
                                value: $protein,
                                unit: "g"
                            )
                            
                            Divider().padding(.leading, 52)
                            
                            NutrientRow(
                                icon: "leaf.fill",
                                iconColor: .green,
                                label: "Carbs",
                                value: $carbs,
                                unit: "g"
                            )
                            
                            Divider().padding(.leading, 52)
                            
                            NutrientRow(
                                icon: "drop.fill",
                                iconColor: .orange,
                                label: "Fat",
                                value: $fat,
                                unit: "g"
                            )
                            
                            Divider().padding(.leading, 52)
                            
                            NutrientRow(
                                icon: "cube.fill",
                                iconColor: .red,
                                label: "Sugar",
                                value: $sugar,
                                unit: "g"
                            )
                            
                            Divider().padding(.leading, 52)
                            
                            NutrientRow(
                                icon: "leaf.arrow.circlepath",
                                iconColor: .teal,
                                label: "Fiber",
                                value: $fiber,
                                unit: "g"
                            )
                            
                            Divider().padding(.leading, 52)
                            
                            NutrientRow(
                                icon: "flask.fill",
                                iconColor: .gray,
                                label: "Sodium",
                                value: $sodium,
                                unit: "mg"
                            )
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 20)
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationTitle("Edit Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveIngredient()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func saveIngredient() {
        let updatedIngredient = Ingredient(
            id: ingredient.id,
            name: ingredient.name,
            quantity: Double(quantity) ?? ingredient.quantity,
            measurementType: measurementType,
            calories: Double(calories) ?? 0,
            protein: Double(protein) ?? 0,
            carbs: Double(carbs) ?? 0,
            fat: Double(fat) ?? 0,
            sugar: Double(sugar) ?? 0,
            fiber: Double(fiber) ?? 0,
            sodium: Double(sodium) ?? 0
        )
        onSave(updatedIngredient)
        dismiss()
    }
}

// MARK: - Nutrient Row
struct NutrientRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    @Binding var value: String
    let unit: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 18))
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 16))
            
            Spacer()
            
            TextField("0", text: $value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 16))
                .frame(width: 80)
            
            Text(unit)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .frame(width: 30, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    IngredientEditorView(ingredient: Ingredient.sampleLamb()) { _ in }
}
