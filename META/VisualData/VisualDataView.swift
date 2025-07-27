import SwiftUI
import MapKit

struct VisualDataView: View {
    // Heatmap filters
    @State private var selectedRoute = RouteOption.allRoutes[4] // Jakarta - Alam Sutera as default
    
    // Dynamic region based on selected route
    @State private var region: MKCoordinateRegion = {
        let defaultRoute = RouteOption.allRoutes[4] // Jakarta - Alam Sutera
        let coordinates = TrafficDataService.getRouteCoordinates(for: defaultRoute)
        let centerLat = (coordinates.start.latitude + coordinates.end.latitude) / 2
        let centerLon = (coordinates.start.longitude + coordinates.end.longitude) / 2
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    }()
    
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
                    region: $region
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
