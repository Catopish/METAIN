//
//  RawDataView.swift
//  META
//
//  Created by Al Amin Dwiesta on 22/07/25.
//

import SwiftUI

struct RawDataView: View {
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    
    let filterOptions = ["All", "Car", "Bus", "Truck"]
    
    let rawTrafficData = [
        RawTrafficEntry(id: 1, timestamp: "2025-07-18 10:30:00", location: "Off Ramp Serpong 2", vehicleType: "Car", count: 45),
        RawTrafficEntry(id: 2, timestamp: "2025-07-18 10:30:00", location: "Off Ramp Serpong 2", vehicleType: "Bus", count: 12),
        RawTrafficEntry(id: 3, timestamp: "2025-07-18 10:30:00", location: "Off Ramp Serpong 2", vehicleType: "Truck", count: 8),
        RawTrafficEntry(id: 4, timestamp: "2025-07-18 10:31:00", location: "On Ramp Serpong 3", vehicleType: "Car", count: 52),
        RawTrafficEntry(id: 5, timestamp: "2025-07-18 10:31:00", location: "On Ramp Serpong 3", vehicleType: "Bus", count: 15),
        RawTrafficEntry(id: 6, timestamp: "2025-07-18 10:31:00", location: "On Ramp Serpong 3", vehicleType: "Truck", count: 6),
        RawTrafficEntry(id: 7, timestamp: "2025-07-18 10:32:00", location: "Off Ramp Serpong 7", vehicleType: "Car", count: 38),
        RawTrafficEntry(id: 8, timestamp: "2025-07-18 10:32:00", location: "Off Ramp Serpong 7", vehicleType: "Bus", count: 9),
        RawTrafficEntry(id: 9, timestamp: "2025-07-18 10:32:00", location: "Off Ramp Serpong 7", vehicleType: "Truck", count: 11),
        RawTrafficEntry(id: 10, timestamp: "2025-07-18 10:33:00", location: "On Ramp Serpong 6", vehicleType: "Car", count: 41)
    ]
    
    var filteredData: [RawTrafficEntry] {
        let searchFiltered = rawTrafficData.filter { entry in
            searchText.isEmpty || 
            entry.location.localizedCaseInsensitiveContains(searchText) ||
            entry.vehicleType.localizedCaseInsensitiveContains(searchText)
        }
        
        if selectedFilter == "All" {
            return searchFiltered
        } else {
            return searchFiltered.filter { $0.vehicleType == selectedFilter }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Controls Section
            controlsSection
            
            // Data Table
            dataTable
        }
        .background(Color("ColorGraySecondary"))
        .preferredColorScheme(.light)
    }
    
    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color("ColorGrayPrimary"))
                        .font(.system(size: 16))
                    
                    TextField("Search locations or vehicle types...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.system(size: 14))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("ColorGrayPrimary").opacity(0.3), lineWidth: 1)
                )
                .frame(maxWidth: 400)
                
                Spacer()
                
                // Filter Dropdown
                Menu {
                    ForEach(filterOptions, id: \.self) { option in
                        Button(option) {
                            selectedFilter = option
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text("Filter: \(selectedFilter)")
                            .font(.system(size: 14))
                            .foregroundColor(Color("ColorBluePrimary"))
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(Color("ColorGrayPrimary"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("ColorGrayPrimary").opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Export Button
                Button(action: {
                    // Export functionality
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14))
                        Text("Export")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color("ColorBluePrimary"))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Summary Stats
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Records")
                        .font(.system(size: 12))
                        .foregroundColor(Color("ColorGrayPrimary"))
                    Text("\(filteredData.count)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("ColorBluePrimary"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Vehicles")
                        .font(.system(size: 12))
                        .foregroundColor(Color("ColorGrayPrimary"))
                    Text("\(filteredData.reduce(0) { $0 + $1.count })")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("ColorBluePrimary"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active Locations")
                        .font(.system(size: 12))
                        .foregroundColor(Color("ColorGrayPrimary"))
                    Text("\(Set(filteredData.map { $0.location }).count)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("ColorBluePrimary"))
                }
                
                Spacer()
            }
        }
        .padding(24)
        .background(Color.white)
    }
    
    private var dataTable: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Table Header
            HStack {
                Text("ID")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("ColorGrayPrimary"))
                    .frame(width: 60, alignment: .leading)
                
                Text("Timestamp")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("ColorGrayPrimary"))
                    .frame(width: 150, alignment: .leading)
                
                Text("Location")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("ColorGrayPrimary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Vehicle Type")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("ColorGrayPrimary"))
                    .frame(width: 120, alignment: .leading)
                
                Text("Count")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("ColorGrayPrimary"))
                    .frame(width: 80, alignment: .trailing)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color("ColorGraySecondary").opacity(0.3))
            
            // Table Rows
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredData, id: \.id) { entry in
                        HStack {
                            Text("\(entry.id)")
                                .font(.system(size: 14))
                                .foregroundColor(Color("ColorBluePrimary"))
                                .frame(width: 60, alignment: .leading)
                            
                            Text(entry.timestamp)
                                .font(.system(size: 14))
                                .foregroundColor(Color("ColorBluePrimary"))
                                .frame(width: 150, alignment: .leading)
                            
                            Text(entry.location)
                                .font(.system(size: 14))
                                .foregroundColor(Color("ColorBluePrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(colorForVehicleType(entry.vehicleType))
                                    .frame(width: 8, height: 8)
                                Text(entry.vehicleType)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color("ColorBluePrimary"))
                            }
                            .frame(width: 120, alignment: .leading)
                            
                            Text("\(entry.count)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("ColorBluePrimary"))
                                .frame(width: 80, alignment: .trailing)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        
                        if entry.id != filteredData.last?.id {
                            Divider()
                                .background(Color("ColorGraySecondary").opacity(0.5))
                        }
                    }
                }
            }
            .background(Color.white)
        }
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(24)
    }
    
    private func colorForVehicleType(_ type: String) -> Color {
        switch type {
        case "Car":
            return Color("ColorBluePrimary")
        case "Bus":
            return Color("ColorBlueSecondary")
        case "Truck":
            return Color("ColorGrayPrimary")
        default:
            return Color("ColorGrayPrimary")
        }
    }
}

// MARK: - Data Model
struct RawTrafficEntry {
    let id: Int
    let timestamp: String
    let location: String
    let vehicleType: String
    let count: Int
}

#Preview {
    RawDataView()
} 