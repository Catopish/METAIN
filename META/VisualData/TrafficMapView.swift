import SwiftUI
import MapKit
import AppKit

struct TrafficMapView: NSViewRepresentable {
    let segments: [TrafficSegment]
    @Binding var region: MKCoordinateRegion
    let selectedRoute: RouteOption
    let onRouteSelected: (RouteOption) -> Void
    
    func makeNSView(context: Context) -> MKMapView {
        let map = MKMapView(frame: .zero)
        map.delegate = context.coordinator
        map.setRegion(region, animated: false)
        map.showsCompass = true
        map.showsUserLocation = false
        
        // Enable user interaction
        map.isScrollEnabled = true
        map.isZoomEnabled = true
        map.isRotateEnabled = true
        map.isPitchEnabled = false
        
        // Add click gesture recognizer for route selection
        let clickGesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleMapClick(_:)))
        clickGesture.numberOfClicksRequired = 1
        clickGesture.delaysPrimaryMouseButtonEvents = false
        map.addGestureRecognizer(clickGesture)
        
        print("Map view created with gesture recognizer")
        
        return map
    }
    
    func updateNSView(_ nsView: MKMapView, context: Context) {
        nsView.setRegion(region, animated: true)
        // remove old overlays
        nsView.overlays.forEach { nsView.removeOverlay($0) }
        
        // Update coordinator with the callback and map reference
        context.coordinator.onRouteSelected = onRouteSelected
        context.coordinator.mapView = nsView
        context.coordinator.segments = segments
        
        // Load routes with caching to avoid API throttling
        context.coordinator.loadRoutesWithCaching(segments: segments, mapView: nsView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TrafficMapView
        var onRouteSelected: ((RouteOption) -> Void)?
        weak var mapView: MKMapView?
        var segments: [TrafficSegment] = []
        
        // Cache for storing route polylines to avoid repeated API calls
        private static var routeCache: [String: MKPolyline] = [:]
        private var pendingRequests: Set<String> = []
        
        init(_ parent: TrafficMapView) { 
            self.parent = parent 
        }
        
        func loadRoutesWithCaching(segments: [TrafficSegment], mapView: MKMapView) {
            for segment in segments {
                let cacheKey = "\(segment.start.latitude),\(segment.start.longitude)-\(segment.end.latitude),\(segment.end.longitude)"
                
                // Check if we already have this route cached
                if let cachedPolyline = Self.routeCache[cacheKey] {
                    // Use cached route - convert MKMapPoint to CLLocationCoordinate2D
                    let points = cachedPolyline.points()
                    let coordinates = (0..<cachedPolyline.pointCount).map { i in
                        points[i].coordinate
                    }
                    
                    let polylineCopy = MKPolyline(coordinates: coordinates, count: coordinates.count)
                    polylineCopy.title = String(segment.weight)
                    polylineCopy.subtitle = segment.routeName
                    mapView.addOverlay(polylineCopy)
                    continue
                }
                
                // Check if we're already requesting this route
                if pendingRequests.contains(cacheKey) {
                    continue
                }
                
                // Add fallback straight line immediately while we fetch the real route
                let straightLineCoords = [segment.start, segment.end]
                let fallbackPolyline = MKPolyline(coordinates: straightLineCoords, count: straightLineCoords.count)
                fallbackPolyline.title = String(segment.weight)
                fallbackPolyline.subtitle = segment.routeName
                mapView.addOverlay(fallbackPolyline)
                
                // Request real route from directions API (but cache it)
                pendingRequests.insert(cacheKey)
                
                let request = MKDirections.Request()
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: segment.start))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: segment.end))
                request.transportType = .automobile
                request.requestsAlternateRoutes = false
                
                let directions = MKDirections(request: request)
                directions.calculate { [weak self] response, error in
                    guard let self = self else { return }
                    
                    self.pendingRequests.remove(cacheKey)
                    
                    if let route = response?.routes.first {
                        // Cache the polyline for future use
                        Self.routeCache[cacheKey] = route.polyline
                        
                        DispatchQueue.main.async {
                            // Remove the fallback straight line
                            if let fallbackOverlay = mapView.overlays.first(where: { overlay in
                                if let polyline = overlay as? MKPolyline,
                                   polyline.subtitle == segment.routeName,
                                   polyline.pointCount == 2 {
                                    return true
                                }
                                return false
                            }) {
                                mapView.removeOverlay(fallbackOverlay)
                            }
                            
                            // Add the real route
                            route.polyline.title = String(segment.weight)
                            route.polyline.subtitle = segment.routeName
                            mapView.addOverlay(route.polyline)
                        }
                    } else if let error = error {
                        print("Directions error for \(segment.routeName): \(error.localizedDescription)")
                        // Keep the straight line fallback if directions fail
                    }
                }
            }
        }
        
        @objc func handleMapClick(_ gestureRecognizer: NSClickGestureRecognizer) {
            guard let mapView = mapView else { return }
            
            let point = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            
            print("Map clicked at: \(coordinate.latitude), \(coordinate.longitude)")
            
            // Find the closest route segment to the click (using original segments for accurate detection)
            var closestRoute: RouteOption?
            var closestDistance: Double = Double.infinity
            
            for segment in segments {
                let distance = distanceToSegment(from: coordinate, segment: segment)
                print("Distance to \(segment.routeName): \(distance)")
                
                if distance < closestDistance && distance < 0.01 { // 0.01 degrees threshold (~1km)
                    closestDistance = distance
                    if let routeOption = RouteOption.allRoutes.first(where: { $0.name == segment.routeName }) {
                        closestRoute = routeOption
                    }
                }
            }
            
            if let selectedRoute = closestRoute {
                print("Route selected: \(selectedRoute.name)")
                onRouteSelected?(selectedRoute)
            } else {
                print("No route detected within threshold (closest distance: \(closestDistance))")
            }
        }
        
        // Calculate distance from a point to a line segment (using original coordinates)
        private func distanceToSegment(from point: CLLocationCoordinate2D, segment: TrafficSegment) -> Double {
            let start = segment.start
            let end = segment.end
            
            // Vector from start to end
            let dx = end.longitude - start.longitude
            let dy = end.latitude - start.latitude
            
            // Vector from start to point
            let px = point.longitude - start.longitude
            let py = point.latitude - start.latitude
            
            // Calculate the parameter t for the closest point on the line
            let dotProduct = px * dx + py * dy
            let lengthSquared = dx * dx + dy * dy
            
            let t = max(0, min(1, lengthSquared == 0 ? 0 : dotProduct / lengthSquared))
            
            // Find the closest point on the line segment
            let closestX = start.longitude + t * dx
            let closestY = start.latitude + t * dy
            
            // Calculate distance from point to closest point on segment
            let distanceX = point.longitude - closestX
            let distanceY = point.latitude - closestY
            
            return sqrt(distanceX * distanceX + distanceY * distanceY)
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            // Handle annotation selection if needed
        }
        
        func mapView(_ mapView: MKMapView, didSelect overlay: MKOverlay) {
            // Handle overlay (polyline) selection as backup
            if let polyline = overlay as? MKPolyline,
               let routeName = polyline.subtitle,
               let routeOption = RouteOption.allRoutes.first(where: { $0.name == routeName }) {
                print("Overlay selected: \(routeName)")
                onRouteSelected?(routeOption)
            }
        }
        
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
            
            // Line width based on traffic intensity - make lines slightly thicker for easier clicking
            let baseWidth: CGFloat = 8 // Increased further for better clickability
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
    let onRouteSelected: (RouteOption) -> Void
    let startDate: Date
    let endDate: Date
    
    var body: some View {
        ZStack {
            TrafficMapView(
                segments: segments, 
                region: $region, 
                selectedRoute: selectedRoute,
                onRouteSelected: onRouteSelected
            )
            .allowsHitTesting(true) // Ensure map can receive touches
            
            // Modal overlay for all route selections
            RouteInfoOverlay(
                selectedRoute: selectedRoute,
                startDate: startDate,
                endDate: endDate
            )
            .allowsHitTesting(false) // Allow touches to pass through to the map
        }
    }
}

// Modal overlay component
struct RouteInfoOverlay: View {
    let selectedRoute: RouteOption
    let startDate: Date
    let endDate: Date
    
    private var routeTrafficInfo: (total: Int, percentage: Double) {
        if selectedRoute.name == "all-routes" {
            // For all routes, show total of all routes for the date range
            let daysDifference = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
            let multiplier = max(1, daysDifference + 1)
            let allRouteData = TrafficDataService.sampleHourlyData.filter { $0.timeRange == "00.00 - 01.00" }
            let grandTotal = allRouteData.map { $0.totalVehicles }.reduce(0, +) * multiplier
            return (total: grandTotal, percentage: 100.0)
        } else {
            return TrafficDataService.getRouteTrafficInfo(selectedRoute, startDate: startDate, endDate: endDate)
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
