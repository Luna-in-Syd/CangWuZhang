import SwiftUI
import SwiftData

struct RootTabView: View {
    var body: some View {
        TabView {
            ShowcaseView()
                .tabItem { Label("陈列柜", systemImage: "square.grid.2x2.fill") }

            DashboardView()
                .tabItem { Label("数据看板", systemImage: "chart.pie.fill") }

            SettingsPlaceholderView()
                .tabItem { Label("我的", systemImage: "person.crop.circle") }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: Item.self, inMemory: true)
}
