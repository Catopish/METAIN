//
//  ContentView.swift
//  META
//
//  Created by Al Amin Dwiesta on 22/07/25.
//
import SwiftUI
import SwiftData

enum SidebarItem: String, CaseIterable, Identifiable {
    case visualData = "Analytics"
    case rawData = "Records"

    var id: String { rawValue }
    var systemIcon: String {
        switch self {
        case .visualData: return "chart.pie"
        case .rawData: return "doc.text"
        }
    }
    
    var iconName: String {
        switch self {
        case .visualData: return "DashboardIcon"
        case .rawData: return "RawDataIcon"
        }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @State private var selection: SidebarItem? = .visualData
    @State private var searchText = ""

    var body: some View {
        NavigationSplitView {
            sidebar
        } detail: {
            VStack(spacing: 0) {
                // Header Section
                headerSection
                    .zIndex(2)
                
                // Detail View
                detailView
                    .zIndex(1)
            }
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.light)
    }
    
    private var headerSection: some View {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hi there")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color("ColorGrayPrimary"))
                    
                    Text("Kaori Hanami")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(Color("ColorBluePrimary"))
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 32)
            .background(
                Rectangle()
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.8), radius: 6, x: 0, y: -4)
            )
        }
    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Logo (made larger)
            HStack {
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                
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
        .frame(minWidth: 260, idealWidth: 280)
        .background(Color.white)
    }

    @ViewBuilder
    private var detailView: some View {
        switch selection {
        case .visualData:
            VisualDataView()
        case .rawData:
            RawDataView()
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
