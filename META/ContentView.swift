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

    @State private var selection: SidebarItem? = .heatmap

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            detailView
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 24) {
            Image("NusantaraLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 32)

            ForEach(SidebarItem.allCases) { item in
                Button {
                    selection = item
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: item.systemIcon)
                            .frame(width: 20)
                        Text(item.rawValue)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(selection == item
                                ? Color.accentColor.opacity(0.2)
                                : Color.clear)
                    .cornerRadius(8)
                    .foregroundColor(selection == item
                                     ? .accentColor
                                     : .primary)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            // Log out
            Button {
                // your logout logic
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.left.square")
                        .frame(width: 20)
                    Text("Log Out")
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(minWidth: 180, idealWidth: 200)
        .background(Color(nsColor: .windowBackgroundColor))
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
