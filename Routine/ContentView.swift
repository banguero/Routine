import SwiftUI

struct ContentView: View {
    @State private var selectedCategory = 0
    @State private var selectedDay = 6 // Fri (0-indexed from Sat)
    @State private var selectedTab = 0
    
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
                            .trim(from: 0, to: 0.75)
                            .stroke(Color(red: 0.4, green: 0.65, blue: 0.95), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 70, height: 70)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 1) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(Color(red: 0.4, green: 0.65, blue: 0.95))
                                .font(.system(size: 14))
                            Text("1800")
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
                        value: "130g",
                        progress: 0.7,
                        color: Color.purple
                    )
                    
                    macroView(
                        icon: "leaf.fill",
                        iconColor: Color.green,
                        label: "Carbs",
                        value: "180g",
                        progress: 0.6,
                        color: Color.green
                    )
                    
                    macroView(
                        icon: "drop.fill",
                        iconColor: Color.orange,
                        label: "Fat",
                        value: "60g",
                        progress: 0.8,
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
                Text("Food for Fri, May 8")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                Button(action: {}) {
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
                    Text("0")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.black)
                    Text("oz")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.bottom, 4)
                }
            }
            
            Spacer()
            
            Button(action: {}) {
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

#Preview {
    ContentView()
}
