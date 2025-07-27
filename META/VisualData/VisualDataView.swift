import SwiftUI
import MapKit

struct VisualDataView: View {
    // Heatmap filters - Default to "All Routes"
    @State private var selectedRoute = RouteOption.allRoutes[0] // All Routes as default
    
    // Dynamic region based on selected route
    @State private var region: MKCoordinateRegion = {
        let defaultRoute = RouteOption.allRoutes[0] // All Routes
        
        return MKCoordinateRegion(
            center: TrafficDataService.getCenterCoordinate(for: defaultRoute),
            span: TrafficDataService.getZoomLevel(for: defaultRoute)
        )
    }()
    
    // Selected time range for vehicle data
    @State private var selectedTimeRange = "00.00 - 01.00"
    
    // Comparison filters
    @State private var selectedYear = 2025
    @State private var selectedMonth = "All Months"
    @State private var selectedRoutes: Set<RouteOption> = [RouteOption.allRoutes[5], RouteOption.allRoutes[2]] // Default selections (jakarta-alam-sutera, bintaro-out)
    
    // Computed property for dynamic vehicle data
    private var dynamicVehicleData: [VehicleAnalytics] {
        TrafficDataService.getVehicleDataForRoute(selectedRoute, timeRange: selectedTimeRange)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Heatmap Section
                HeatmapSectionView(
                    selectedRoute: $selectedRoute,
                    region: $region
                )
                
                // Vehicle Count Cards - Now dynamic based on selected route
                VehicleCountCardsView(
                    vehicleData: dynamicVehicleData,
                    selectedRoute: selectedRoute
                )
                
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
