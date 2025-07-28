import SwiftUI
import MapKit

struct VisualDataView: View {
    // Heatmap filters - Default to "All Routes"
    @State private var selectedRoute = RouteOption.allRoutes[0] // All Routes as default
    
    // Date range for data filtering
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
    @State private var endDate = Date()
    
    // Dynamic region based on selected route
    @State private var region: MKCoordinateRegion = {
        let defaultRoute = RouteOption.allRoutes[0] // All Routes
        
        return MKCoordinateRegion(
            center: TrafficDataService.getCenterCoordinate(for: defaultRoute),
            span: TrafficDataService.getZoomLevel(for: defaultRoute)
        )
    }()
    
    // Comparison filters
    @State private var selectedYear = 2025
    @State private var selectedMonth = "All Months"
    @State private var selectedRoutes: Set<RouteOption> = [RouteOption.allRoutes[5], RouteOption.allRoutes[2]] // Default selections (jakarta-alam-sutera, bintaro-out)
    
    // Computed property for dynamic vehicle data using date range
    private var dynamicVehicleData: [VehicleAnalytics] {
        TrafficDataService.getVehicleDataForRoute(selectedRoute, startDate: startDate, endDate: endDate)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading,spacing: 24) {
                Text("Route-based Traffic Analytics")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("ColorBluePrimary"))
                // Heatmap Section
                HeatmapSectionView(
                    selectedRoute: $selectedRoute,
                    region: $region,
                    startDate: $startDate,
                    endDate: $endDate,
                    onDateRangeChanged: {
                        // This will trigger a recalculation of dynamicVehicleData
                    }
                )
                
                // Vehicle Count Cards - Now dynamic based on selected route and date range
                VehicleCountCardsView(
                    vehicleData: dynamicVehicleData,
                    selectedRoute: selectedRoute
                )
                
                // Enhanced Comparison Section - Now generates its own data
                ComparisonSectionView(
                    selectedYear: $selectedYear,
                    selectedMonth: $selectedMonth,
                    selectedRoutes: $selectedRoutes
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
