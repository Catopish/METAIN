import SwiftUI
import MapKit
import AppKit

struct TrafficMapView: NSViewRepresentable {
    let segments: [TrafficSegment]
    @Binding var region: MKCoordinateRegion
    
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
