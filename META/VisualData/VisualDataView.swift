//
//  VisualDataView.swift
//  META
//
//  Created by Al Amin Dwiesta on 22/07/25.
//

import SwiftUI
import MapKit

// MARK: - Visual Data View
struct VisualDataView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -6.294252169538141, longitude: 106.7169941191576), // BSD Toll Road
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    // Heatmap filters
    @State private var selectedRoute = RouteOption.allRoutes[4] // Jakarta - Alam Sutera as default
    
    // Comparison filters
    @State private var selectedYear = 2025
    @State private var selectedMonth = "All Months"
    @State private var selectedRoutes: Set<RouteOption> = [RouteOption.allRoutes[4], RouteOption.allRoutes[1]] // Default selections
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Heatmap Section
                HeatmapSectionView(
                    selectedRoute: $selectedRoute,
                    region: $region,
                    trafficSegments: TrafficDataService.sampleTrafficSegments
                )
                
                // Vehicle Count Cards
                VehicleCountCardsView(vehicleData: TrafficDataService.sampleVehicleData)
                
                // Comparison Section
                ComparisonSectionView(
                    selectedYear: $selectedYear,
                    selectedMonth: $selectedMonth,
                    selectedRoutes: $selectedRoutes,
                    monthlyData: TrafficDataService.sampleMonthlyData
                )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
        .background(Color("ColorGraySecondary"))
        .preferredColorScheme(.light)
        .allowsHitTesting(true) // Ensure all interactive elements work
    }
}

#Preview {
    VisualDataView()
} 
