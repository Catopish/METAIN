import SwiftUI
import MapKit

struct HeatmapSectionView: View {
    @Binding var selectedRoute: RouteOption
    @Binding var region: MKCoordinateRegion
    let trafficSegments: [TrafficSegment]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Heatmap")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color("ColorBluePrimary"))
            
            // Filters row - positioned below title
            HStack(spacing: 16) {
                // Route Dropdown - exact same style as DateFilterWithCalendar
                Menu {
                    ForEach(RouteOption.allRoutes) { route in
                        Button(route.displayName) {
                            selectedRoute = route
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
                DateFilterWithCalendar()
                    .frame(width: 200)
                
                Spacer()
            }
            .zIndex(1000) // Move z-index to the entire filter row
            
            // Map - with lower z-index
            TrafficMapView(segments: trafficSegments, region: $region)
                .frame(height: 400)
                .cornerRadius(12)
                .shadow(radius: 4)
                .zIndex(1) // Lower z-index than date filter
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
} 
