import SwiftUI

struct MealDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var foodLogViewModel: FoodLogViewModel
    @State private var entry: FoodEntry
    @State private var showingIngredientEditor = false
    @State private var selectedIngredient: Ingredient?
    @State private var showingAddIngredient = false
    @State private var mealAnalysis: String?
    
    init(entry: FoodEntry, foodLogViewModel: FoodLogViewModel) {
        self._entry = State(initialValue: entry)
        self.foodLogViewModel = foodLogViewModel
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with meal info and analysis
                    headerSection
                    
                    // Macros summary
                    macrosSection
                    
                    // Ingredients section
                    ingredientsSection
                }
                .padding(.bottom, 30)
            }
            .background(Color(red: 0.95, green: 0.95, blue: 0.97))
            .navigationTitle("Meal Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        Task {
                            await saveChanges()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showingIngredientEditor) {
            if let ingredient = selectedIngredient {
                IngredientEditorView(
                    ingredient: ingredient,
                    onSave: { updatedIngredient in
                        updateIngredient(updatedIngredient)
                    }
                )
            }
        }
        .sheet(isPresented: $showingAddIngredient) {
            AddIngredientView { newIngredient in
                addIngredient(newIngredient)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageUrl = entry.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Text(entry.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
            
            if let analysis = mealAnalysis ?? generateAnalysis() {
                Text(analysis)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .italic()
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    // MARK: - Macros Section
    private var macrosSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                MacroCard(
                    icon: "flame.fill",
                    iconColor: .blue,
                    label: "Calories",
                    value: "\(Int(entry.totalCalories))",
                    unit: ""
                )
                
                MacroCard(
                    icon: "dumbbell.fill",
                    iconColor: .purple,
                    label: "Protein",
                    value: "\(Int(entry.totalProtein))",
                    unit: "g"
                )
            }
            
            HStack(spacing: 20) {
                MacroCard(
                    icon: "leaf.fill",
                    iconColor: .green,
                    label: "Carbs",
                    value: "\(Int(entry.totalCarbs))",
                    unit: "g"
                )
                
                MacroCard(
                    icon: "drop.fill",
                    iconColor: .orange,
                    label: "Fat",
                    value: "\(Int(entry.totalFat))",
                    unit: "g"
                )
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Ingredients Section
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ingredients")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Serving size multiplier
                if entry.ingredients != nil {
                    Button(action: {
                        // TODO: Implement serving size adjustment
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                                .font(.system(size: 12))
                            Text("x1.0")
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                
                Button(action: {
                    showingAddIngredient = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .medium))
                        Text("Add")
                            .font(.system(size: 15, weight: .medium))
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 16)
            
            if let ingredients = entry.ingredients, !ingredients.isEmpty {
                VStack(spacing: 10) {
                    ForEach(ingredients) { ingredient in
                        IngredientRow(ingredient: ingredient) {
                            selectedIngredient = ingredient
                            showingIngredientEditor = true
                        }
                    }
                }
                .padding(.horizontal, 16)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.4))
                    
                    Text("No ingredients added")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("Tap + to add ingredients")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func generateAnalysis() -> String? {
        // Generate a simple analysis based on macros
        let protein = entry.totalProtein
        let carbs = entry.totalCarbs
        let fat = entry.totalFat
        
        if protein > 30 && carbs < 10 {
            return "High-protein, low-carb meal. Great for muscle building and low-carb diets. Consider adding vegetables for fiber and micronutrients."
        } else if carbs > 40 {
            return "Higher carbohydrate meal providing energy. Good for active lifestyles or post-workout recovery."
        } else if fat > 25 {
            return "Higher fat content meal. Provides satiety and essential fatty acids. Balance with lean proteins and vegetables."
        }
        
        return "Balanced meal with good macronutrient distribution."
    }
    
    private func updateIngredient(_ updatedIngredient: Ingredient) {
        guard var ingredients = entry.ingredients else { return }
        
        if let index = ingredients.firstIndex(where: { $0.id == updatedIngredient.id }) {
            ingredients[index] = updatedIngredient
            entry.ingredients = ingredients
            entry.updateMacrosFromIngredients()
        }
        
        showingIngredientEditor = false
        selectedIngredient = nil
    }
    
    private func addIngredient(_ newIngredient: Ingredient) {
        if entry.ingredients == nil {
            entry.ingredients = []
        }
        entry.ingredients?.append(newIngredient)
        entry.updateMacrosFromIngredients()
        showingAddIngredient = false
    }
    
    private func saveChanges() async {
        await foodLogViewModel.updateFoodEntry(entry)
    }
}

// MARK: - Macro Card
struct MacroCard: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 14))
                Text(label)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Ingredient Row
struct IngredientRow: View {
    let ingredient: Ingredient
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ingredient.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text(ingredient.quantityString)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(ingredient.calories)) cal")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    HStack(spacing: 8) {
                        MacroBadge(icon: "dumbbell.fill", value: "\(Int(ingredient.protein))g", color: .purple)
                        MacroBadge(icon: "leaf.fill", value: "\(Int(ingredient.carbs))g", color: .green)
                        MacroBadge(icon: "drop.fill", value: "\(Int(ingredient.fat))g", color: .orange)
                    }
                }
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Macro Badge
struct MacroBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Add Ingredient View
struct AddIngredientView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var quantity = "1.0"
    @State private var measurementType = MeasurementType.servings
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    
    let onAdd: (Ingredient) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section("Ingredient Details") {
                    TextField("Name (e.g., Chicken breast)", text: $name)
                    
                    HStack {
                        TextField("Quantity", text: $quantity)
                            .keyboardType(.decimalPad)
                        Picker("", selection: $measurementType) {
                            ForEach(MeasurementType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Nutritional Info") {
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("cal")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Protein")
                        Spacer()
                        TextField("0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Carbs")
                        Spacer()
                        TextField("0", text: $carbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Fat")
                        Spacer()
                        TextField("0", text: $fat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("g")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addIngredient()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func addIngredient() {
        let ingredient = Ingredient(
            id: UUID().uuidString,
            name: name,
            quantity: Double(quantity) ?? 1.0,
            measurementType: measurementType,
            calories: Double(calories) ?? 0,
            protein: Double(protein) ?? 0,
            carbs: Double(carbs) ?? 0,
            fat: Double(fat) ?? 0
        )
        onAdd(ingredient)
        dismiss()
    }
}

#Preview {
    MealDetailView(
        entry: FoodEntry(
            id: "1",
            userId: "test",
            name: "Grilled Lamb & Chicken",
            calories: 525,
            protein: 55,
            carbs: 0,
            fat: 33,
            mealType: .lunch,
            aiRecognized: true,
            confidence: 0.88,
            ingredients: [
                Ingredient.sampleLamb(),
                Ingredient.sampleChicken(),
                Ingredient.sampleOliveOil(),
                Ingredient.sampleSalt()
            ]
        ),
        foodLogViewModel: FoodLogViewModel(
            userId: "test",
            user: User(id: "test", email: "test@test.com", displayName: "Test")
        )
    )
}
