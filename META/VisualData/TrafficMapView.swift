import SwiftUI
import MapKit
import AppKit

struct TrafficMapView: NSViewRepresentable {
    let segments: [TrafficSegment]
    @Binding var region: MKCoordinateRegion
    let selectedRoute: RouteOption
    
    func makeNSView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.setRegion(region, animated: false)
        map.showsCompass = true
        map.showsUserLocation = false
        return map
    }
    
    func updateNSView(_ nsView: MKMapView, context: Context) {
        nsView.setRegion(region, animated: true)
        // remove old overlays
        nsView.overlays.forEach { nsView.removeOverlay($0) }
        
        // for each segment, request the driving route and draw it
        for segment in segments {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: segment.start))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: segment.end))
            request.transportType = .automobile
            request.requestsAlternateRoutes = false
            request.departureDate = Date()   // include current traffic conditions
            
            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                guard let route = response?.routes.first else { return }
                route.polyline.title = String(segment.weight)
                DispatchQueue.main.async {
                    nsView.addOverlay(route.polyline)
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TrafficMapView
        init(_ parent: TrafficMapView) { self.parent = parent }
        
        func mapView(_ mapView: MKMapView,
                     rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let poly = overlay as? MKPolyline,
                  let weightStr = poly.title,
                  let weight = Double(weightStr)
            else {
                return MKOverlayRenderer(overlay: overlay)
            }
            
            let renderer = MKPolylineRenderer(overlay: poly)
            
            // Use the new gradient color system based on vehicle count
            let color = TrafficDataService.heatmapColorForVehicleCount(weight)
            
            // Convert SwiftUI Color to NSColor
            if let cgColor = color.cgColor {
                renderer.strokeColor = NSColor(cgColor: cgColor)
            } else {
                // Fallback to default color
                renderer.strokeColor = NSColor.systemBlue
            }
            
            // Line width based on traffic intensity
            let baseWidth: CGFloat = 4
            let intensityFactor = CGFloat(weight / 1000) // Scale based on thousands
            renderer.lineWidth = max(baseWidth, baseWidth + intensityFactor)
            renderer.lineCap = .round
            renderer.alpha = 0.8
            
            return renderer
        }
    }
}

// SwiftUI wrapper with modal overlay
struct TrafficMapViewWithOverlay: View {
    let segments: [TrafficSegment]
    @Binding var region: MKCoordinateRegion  
    let selectedRoute: RouteOption
    
    var body: some View {
        ZStack {
            TrafficMapView(segments: segments, region: $region, selectedRoute: selectedRoute)
            
            // Modal overlay for all route selections
            RouteInfoOverlay(selectedRoute: selectedRoute)
        }
    }
}

// Modal overlay component
struct RouteInfoOverlay: View {
    let selectedRoute: RouteOption
    
    private var routeTrafficInfo: (total: Int, percentage: Double) {
        if selectedRoute.name == "all-routes" {
            // For all routes, show total of all routes
            let allRouteData = TrafficDataService.sampleHourlyData.filter { $0.timeRange == "00.00 - 01.00" }
            let grandTotal = allRouteData.map { $0.totalVehicles }.reduce(0, +)
            return (total: grandTotal, percentage: 100.0)
        } else {
            return TrafficDataService.getRouteTrafficInfo(selectedRoute)
        }
    }
    
    private var overlayTitle: String {
        if selectedRoute.name == "all-routes" {
            return "All Routes Combined"
        } else {
            return selectedRoute.displayName
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                // Modal content
                VStack(alignment: .leading, spacing: 8) {
                    Text(overlayTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("ColorBluePrimary"))
                    
                    HStack {
                        Text("Total Vehicles:")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text("\(routeTrafficInfo.total)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    if selectedRoute.name != "all-routes" {
                        HStack {
                            Text("% of Total Traffic:")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text("\(routeTrafficInfo.percentage, specifier: "%.1f")%")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.primary) // Remove color, use primary instead
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 2)
                )
                .padding(.trailing, 16)
                .padding(.bottom, 60) // Position above legend
            }
        }
    }
} 
