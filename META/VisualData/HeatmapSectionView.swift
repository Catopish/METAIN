import SwiftUI
import MapKit

struct HeatmapSectionView: View {
    @Binding var selectedRoute: RouteOption
    @Binding var region: MKCoordinateRegion
    @Binding var startDate: Date
    @Binding var endDate: Date
    let onDateRangeChanged: () -> Void
    
    // Computed property to get dynamic traffic segments based on selected route
    private var dynamicTrafficSegments: [TrafficSegment] {
        TrafficDataService.getTrafficSegmentsForRoute(selectedRoute)
    }
    
    // Callback for when route is selected via map tap
    private func onRouteSelectedFromMap(_ route: RouteOption) {
        selectedRoute = route
        
        // Update map region to focus on the selected route
        region = MKCoordinateRegion(
            center: TrafficDataService.getCenterCoordinate(for: route),
            span: TrafficDataService.getZoomLevel(for: route)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            VStack (alignment: .leading, spacing: 8){
                Text("Vehicle Volume Interactive Heatmap")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("ColorBluePrimary"))
                Text("Select route on the map to see it specific traffic volume.")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.secondary)
            }
            // Filters row - positioned below title
            HStack(spacing: 16) {
                // Route Dropdown - exact same style as DateFilterWithCalendar
                Menu {
                    ForEach(RouteOption.allRoutes) { route in
                        Button(route.displayName) {
                            selectedRoute = route
                            
                            // Update map region to focus on the selected route using helper functions
                            region = MKCoordinateRegion(
                                center: TrafficDataService.getCenterCoordinate(for: route),
                                span: TrafficDataService.getZoomLevel(for: route)
                            )
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedRoute.displayName)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "location")
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(NSColor.controlBackgroundColor))
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 200)
                
                // Date Filter with Calendar
                DateFilterWithCalendar(
                    startDate: $startDate,
                    endDate: $endDate,
                    onDateRangeChanged: onDateRangeChanged
                )
                .frame(width: 200)
                
                Spacer()
            }
            .zIndex(1000) // Move z-index to the entire filter row
            
            // Map - with lower z-index
            // Map and Legend Section
            ZStack(alignment: .topTrailing) { // 1. Changed VStack to ZStack with alignment
                
                // 2. The map is the first (bottom) layer of the ZStack
                TrafficMapViewWithOverlay(
                    segments: dynamicTrafficSegments,
                    region: $region,
                    selectedRoute: selectedRoute,
                    onRouteSelected: onRouteSelectedFromMap,
                    startDate: startDate,
                    endDate: endDate
                )
                .frame(height: 400)
                .cornerRadius(12)
                .shadow(radius: 4)
                // No zIndex needed here anymore, as ZStack handles the layering

                // 3. The legend is the second (top) layer
                // Traffic intensity legend
                HStack(spacing: 0) {
                    // Green section
                    Rectangle()
                        .fill(TrafficDataService.heatmapColorForVehicleCount(2850))
                        .frame(height: 20)

                    // Gradient section
                    LinearGradient(
                        colors: [
                            TrafficDataService.heatmapColorForVehicleCount(2850),
                            TrafficDataService.heatmapColorForVehicleCount(3990),
                            TrafficDataService.heatmapColorForVehicleCount(5700)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 20)

                    // Red section
                    Rectangle()
                        .fill(TrafficDataService.heatmapColorForVehicleCount(5700))
                        .frame(height: 20)
                }
                .overlay(
                    HStack {
                        Text("Light")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.black)
                        Spacer()
                        Text("Medium")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.black)
                        Spacer()
                        Text("Heavy")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                )
                .cornerRadius(6)
                .frame(width: 180)
                .padding(16) // 4. Add padding to create space from the top and right edges
                // .padding(.top, 8) // 5. REMOVE this old padding
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
} 
