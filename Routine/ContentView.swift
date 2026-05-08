import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var foodLogViewModel: FoodLogViewModel
    @StateObject private var waterViewModel: WaterViewModel
    
    @State private var selectedCategory = 0
    @State private var selectedDay = 6 // Fri (0-indexed from Sat)
    @State private var selectedTab = 0
    @State private var showAddFoodSheet = false
    @State private var showCamera = false
    
    // Haptic feedback generators
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    let categories = [
        ("Eating", "fork.knife"),
        ("Mindfulness", "brain.head.profile"),
        ("Meditation", "figure.mind.and.body")
    ]
    
    let days = [
        ("Sat", "2"),
        ("Sun", "3"),
        ("Mon", "4"),
        ("Tue", "5"),
        ("Wed", "6"),
        ("Thu", "7"),
        ("Fri", "8")
    ]
    
    init() {
        // Initialize with placeholder - will be updated in onAppear
        let placeholderUser = User(
            id: "placeholder",
            email: "",
            displayName: ""
        )
        _foodLogViewModel = StateObject(wrappedValue: FoodLogViewModel(userId: "placeholder", user: placeholderUser))
        _waterViewModel = StateObject(wrappedValue: WaterViewModel(userId: "placeholder"))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.97)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Category tabs
                    categoryTabs
                    
                    // Calendar strip
                    calendarStrip
                    
                    // Main content
                    ScrollView {
                        VStack(spacing: 18) {
                            // Calories card
                            caloriesCard
                            
                            // Food section
                            foodSection
                            
                            // Water section
                            waterSection
                            
                            Spacer(minLength: 90)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    }
                }
                
                // Bottom tab bar
                VStack {
                    Spacer()
                    bottomTabBar
                        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 8)
                }
            }
        }
        .sheet(isPresented: $showAddFoodSheet) {
            AddFoodSheet(onScanFood: {
                showCamera = true
            })
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(foodLogViewModel: foodLogViewModel)
        }
        .onAppear {
            if let user = authViewModel.user, let userId = user.id {
                foodLogViewModel.updateUser(userId: userId, user: user)
                waterViewModel.updateUserId(userId)
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            HStack(spacing: 10) {
                // Infinity logo
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.cyan, Color.green, Color.yellow],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 32, height: 32)
                        .mask {
                            Image(systemName: "infinity")
                                .font(.system(size: 20, weight: .bold))
                        }
                }
                
                Text("Routine")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            
            Spacer(minLength: 8)
            
            // Flame counter
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 18))
                Text("67")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    // MARK: - Category Tabs
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(0..<categories.count, id: \.self) { index in
                    categoryButton(
                        title: categories[index].0,
                        icon: categories[index].1,
                        isSelected: selectedCategory == index
                    )
                    .onTapGesture {
                        impactLight.impactOccurred()
                        selectedCategory = index
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
    }
    
    private func categoryButton(title: String, icon: String, isSelected: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .lineLimit(1)
        }
        .foregroundColor(isSelected ? .white : .black.opacity(0.7))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(isSelected ? Color(red: 0.4, green: 0.65, blue: 0.95) : Color.white)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
    }
    
    // MARK: - Calendar Strip
    private var calendarStrip: some View {
        HStack(spacing: 8) {
            ForEach(0..<days.count, id: \.self) { index in
                dayCell(
                    day: days[index].0,
                    date: days[index].1,
                    isSelected: selectedDay == index,
                    hasDot: true
                )
                .onTapGesture {
                    selectionFeedback.selectionChanged()
                    selectedDay = index
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
    
    private func dayCell(day: String, date: String, isSelected: Bool, hasDot: Bool) -> some View {
        VStack(spacing: 4) {
            Text(day)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(isSelected ? .white.opacity(0.85) : .gray)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Text(date)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(isSelected ? .white : .black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Circle()
                .fill(isSelected ? Color.white : Color.blue)
                .frame(width: 4, height: 4)
                .opacity(hasDot ? 1 : 0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color(red: 0.4, green: 0.65, blue: 0.95) : Color.white)
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
    }
    
    // MARK: - Calories Card
    private var caloriesCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 0) {
                // Left side: Circular progress + label
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.15), lineWidth: 6)
                            .frame(width: 70, height: 70)
                        
                        Circle()
                            .trim(from: 0, to: progressRingValue)
                            .stroke(Color(red: 0.4, green: 0.65, blue: 0.95), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 70, height: 70)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 1) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(Color(red: 0.4, green: 0.65, blue: 0.95))
                                .font(.system(size: 14))
                            Text("\(Int(caloriesRemaining))")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Calories")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                        Text("left")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer(minLength: 8)
                
                // Right side: Macros
                HStack(spacing: 8) {
                    macroView(
                        icon: "dumbbell.fill",
                        iconColor: Color.purple,
                        label: "Protein",
                        value: "\(Int(proteinRemaining))g",
                        progress: proteinProgress,
                        color: Color.purple
                    )
                    
                    macroView(
                        icon: "leaf.fill",
                        iconColor: Color.green,
                        label: "Carbs",
                        value: "\(Int(carbsRemaining))g",
                        progress: carbsProgress,
                        color: Color.green
                    )
                    
                    macroView(
                        icon: "drop.fill",
                        iconColor: Color.orange,
                        label: "Fat",
                        value: "\(Int(fatRemaining))g",
                        progress: fatProgress,
                        color: Color.orange
                    )
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            
            // Page indicators
            HStack(spacing: 4) {
                Circle()
                    .fill(Color(red: 0.4, green: 0.65, blue: 0.95))
                    .frame(width: 4, height: 4)
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 4, height: 4)
            }
            .padding(.bottom, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Computed Properties for Calories Card
    
    private var caloriesRemaining: Double {
        foodLogViewModel.dailySummary?.caloriesRemaining ?? 1800
    }
    
    private var proteinRemaining: Double {
        foodLogViewModel.dailySummary?.proteinRemaining ?? 130
    }
    
    private var carbsRemaining: Double {
        foodLogViewModel.dailySummary?.carbsRemaining ?? 180
    }
    
    private var fatRemaining: Double {
        foodLogViewModel.dailySummary?.fatRemaining ?? 60
    }
    
    private var progressRingValue: Double {
        guard let summary = foodLogViewModel.dailySummary else { return 0.75 }
        let progress = summary.totalCalories / Double(summary.calorieGoal)
        return min(max(1.0 - progress, 0.0), 1.0)
    }
    
    private var proteinProgress: Double {
        guard let summary = foodLogViewModel.dailySummary else { return 0.7 }
        return min(summary.totalProtein / Double(summary.proteinGoal), 1.0)
    }
    
    private var carbsProgress: Double {
        guard let summary = foodLogViewModel.dailySummary else { return 0.6 }
        return min(summary.totalCarbs / Double(summary.carbsGoal), 1.0)
    }
    
    private var fatProgress: Double {
        guard let summary = foodLogViewModel.dailySummary else { return 0.8 }
        return min(summary.totalFat / Double(summary.fatGoal), 1.0)
    }
    
    private func macroView(icon: String, iconColor: Color, label: String, value: String, progress: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 12))
                .frame(height: 14)
            
            VStack(spacing: 1) {
                Text(label)
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            
            GeometryReader { geo in
                Capsule()
                    .fill(color.opacity(0.2))
                    .frame(height: 3)
                    .overlay(
                        Capsule()
                            .fill(color)
                            .frame(width: geo.size.width * progress, height: 3),
                        alignment: .leading
                    )
            }
            .frame(height: 3)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Food Section
    private var foodSection: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Food for Today")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                Button(action: {
                    impactMedium.impactOccurred()
                    showAddFoodSheet = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.4, green: 0.65, blue: 0.95))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .medium))
                    }
                }
            }
            
            if foodLogViewModel.foodEntries.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 42))
                        .foregroundColor(.gray.opacity(0.4))
                        .padding(.top, 30)
                    
                    Text("No entries yet")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    Text("Tap + to scan or describe your first food item")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 12) {
                    ForEach(foodLogViewModel.foodEntries) { entry in
                        FoodEntryRow(entry: entry) {
                            Task {
                                await foodLogViewModel.deleteFoodEntry(id: entry.id ?? "")
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Water Section
    private var waterSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Water")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text("\(Int(waterViewModel.totalWaterOz))")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.black)
                    Text("oz")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.bottom, 4)
                }
            }
            
            Spacer()
            
            Button(action: {
                impactLight.impactOccurred()
                Task {
                    await waterViewModel.addWater(amountOz: 8)
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "plus")
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 1)
        )
    }
    
    // MARK: - Bottom Tab Bar
    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            tabButton(icon: "list.bullet", title: "Log", index: 0, isSelected: selectedTab == 0)
            tabButton(icon: "chart.xyaxis.line", title: "Stats", index: 1, isSelected: selectedTab == 1)
            tabButton(icon: "sparkles", title: "AI Coach", index: 2, isSelected: selectedTab == 2)
            tabButton(icon: "gearshape", title: "Settings", index: 3, isSelected: selectedTab == 3)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    private func tabButton(icon: String, title: String, index: Int, isSelected: Bool) -> some View {
        Button(action: {
            selectionFeedback.selectionChanged()
            selectedTab = index
        }) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color(red: 0.4, green: 0.65, blue: 0.95) : .gray)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? Color(red: 0.4, green: 0.65, blue: 0.95) : .gray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .background(
                Capsule()
                    .fill(isSelected ? Color(red: 0.4, green: 0.65, blue: 0.95).opacity(0.1) : Color.clear)
            )
        }
    }
}

// MARK: - Food Entry Row
struct FoodEntryRow: View {
    let entry: FoodEntry
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Food image or placeholder
            if entry.imageUrl != nil {
                AsyncImage(url: URL(string: entry.imageUrl!)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                    )
            }
            
            // Food details
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    
                    if entry.aiRecognized {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                            .font(.system(size: 12))
                    }
                }
                
                Text("\(Int(entry.calories)) cal • P: \(Int(entry.protein))g • C: \(Int(entry.carbs))g • F: \(Int(entry.fat))g")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Meal type badge
            Text(entry.mealType.rawValue)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Add Food Sheet
struct AddFoodSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    let onScanFood: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Add Food")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 20)
                
                Text("Choose how you'd like to add the food item")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
            
            // Options
            VStack(spacing: 12) {
                AddFoodOption(
                    icon: "camera.fill",
                    iconColor: .blue,
                    iconBackground: Color.blue.opacity(0.12),
                    title: "Scan Food",
                    subtitle: "Take or upload a photo of your food",
                    action: {
                        impactLight.impactOccurred()
                        dismiss()
                        onScanFood()
                    }
                )
                
                AddFoodOption(
                    icon: "bookmark.fill",
                    iconColor: .orange,
                    iconBackground: Color.orange.opacity(0.12),
                    title: "Saved Food",
                    subtitle: "Choose from your saved food items",
                    action: {
                        impactLight.impactOccurred()
                        dismiss()
                    }
                )
                
                AddFoodOption(
                    icon: "mic.fill",
                    iconColor: .green,
                    iconBackground: Color.green.opacity(0.12),
                    title: "Describe Food",
                    subtitle: "Tell us what you ate",
                    action: {
                        impactLight.impactOccurred()
                        dismiss()
                    }
                )
            }
            .padding(.horizontal, 20)
            
            Spacer(minLength: 20)
        }
        .background(Color(red: 0.96, green: 0.96, blue: 0.98))
    }
}

struct AddFoodOption: View {
    let icon: String
    let iconColor: Color
    let iconBackground: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconBackground)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.system(size: 20))
                }
                
                // Text
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray.opacity(0.4))
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}

// MARK: - Camera View
struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var scanMode: ScanMode = .camera
    @State private var isProcessing = false
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    
    let foodLogViewModel: FoodLogViewModel?
    
    init(foodLogViewModel: FoodLogViewModel? = nil) {
        self.foodLogViewModel = foodLogViewModel
    }
    
    enum ScanMode {
        case camera
        case library
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button(action: {
                        impactLight.impactOccurred()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .medium))
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Scan Food")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear.frame(width: 32, height: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // Mode selector
                HStack(spacing: 0) {
                    Button(action: {
                        impactLight.impactOccurred()
                        scanMode = .camera
                        sourceType = .camera
                        showImagePicker = true
                    }) {
                        Text("Scan Food")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(scanMode == .camera ? .black : .white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(scanMode == .camera ? Color.white : Color.clear)
                            )
                    }
                    
                    Button(action: {
                        impactLight.impactOccurred()
                        scanMode = .library
                        sourceType = .photoLibrary
                        showImagePicker = true
                    }) {
                        Text("Library")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(scanMode == .library ? .black : .white.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(scanMode == .library ? Color.white : Color.clear)
                            )
                    }
                }
                .padding(4)
                .background(Color.white.opacity(0.15))
                .clipShape(Capsule())
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
                
                Spacer()
                
                // Camera preview area
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: scanMode == .camera ? "camera.fill" : "photo.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))
                        
                        Text(scanMode == .camera ? "Position food in frame" : "Select a photo from your library")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, maxHeight: 400)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .onTapGesture {
                        showImagePicker = true
                    }
                }
                
                Spacer()
                
                // Capture button (only show for camera mode and when no image selected)
                if selectedImage == nil && scanMode == .camera {
                    Button(action: {
                        impactLight.impactOccurred()
                        showImagePicker = true
                    }) {
                        ZStack {
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                        }
                    }
                    .padding(.bottom, 40)
                } else if selectedImage != nil {
                    // Action buttons when image is selected
                    HStack(spacing: 20) {
                        Button(action: {
                            impactLight.impactOccurred()
                            selectedImage = nil
                        }) {
                            Text("Retake")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            impactLight.impactOccurred()
                            if let image = selectedImage, let viewModel = foodLogViewModel {
                                isProcessing = true
                                Task {
                                    await viewModel.addFoodWithAI(image: image)
                                    isProcessing = false
                                    dismiss()
                                }
                            } else {
                                dismiss()
                            }
                        }) {
                            if isProcessing {
                                ProgressView()
                                    .tint(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.white)
                                    .cornerRadius(12)
                            } else {
                                Text("Use Photo")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.white)
                                    .cornerRadius(12)
                            }
                        }
                        .disabled(isProcessing)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                } else {
                    // Library mode - show select button
                    Button(action: {
                        impactLight.impactOccurred()
                        showImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo.fill")
                            Text("Choose from Library")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
                .ignoresSafeArea()
        }
        .onAppear {
            // Auto-open camera when view appears in camera mode
            if scanMode == .camera {
                showImagePicker = true
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
