//
//  ContentView.swift
//  META
//
//  Created by Al Amin Dwiesta on 22/07/25.
//
import SwiftUI
import SwiftData

enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case heatmap   = "Heatmap"
    case analytics = "Analytics"

    var id: String { rawValue }
    var systemIcon: String {
        switch self {
        case .dashboard: return "speedometer"
        case .heatmap:   return "square.grid.3x3.fill"
        case .analytics: return "chart.bar"
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @State private var selection: SidebarItem? = .dashboard

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailView
        }
        .preferredColorScheme(.light) // Force light mode
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Logo
            HStack {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                
                Spacer()
            }
            .padding(.top, 12)

            // Navigation Buttons
            VStack(spacing: 12) {
                ForEach(SidebarItem.allCases) { item in
                    SidebarButton(
                        title: item.rawValue,
                        systemIcon: item.systemIcon,
                        isSelected: selection == item
                    ) {
                        selection = item
                    }
                }
            }

            Spacer()

            // Log out button
            SidebarButton(
                title: "Log Out",
                systemIcon: "arrow.left.square",
                isSelected: false
            ) {
                // Logout logic here
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .frame(minWidth: 280, idealWidth: 300)
        .background(Color.white)
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .dashboard:
            DashboardView()
        case .heatmap:
            HeatmapView()
        case .analytics:
            AnalyticsView()
        case .none:
            Text("Select an item")
                .font(.title)
                .foregroundColor(Color("ColorGrayPrimary"))
        }
    }

    // CoreData / SwiftData add/delete from your original code
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for idx in offsets {
                modelContext.delete(items[idx])
            }
        }
    }
    
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
