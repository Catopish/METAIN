//
//  DashboardView.swift
//  META
//
//  Created by Al Amin Dwiesta on 22/07/25.
//

import SwiftUI
import MapKit
import AppKit

// MARK: - Data Model
struct TrafficSegment {
    let start: CLLocationCoordinate2D
    let end: CLLocationCoordinate2D
    let weight: Double   // vehicles per hour for heatmap weighting
}

// MARK: - macOS Map Wrapper
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
            // normalize weight to 0...1
            let t = min(max((weight - 0) / 200, 0), 1)
            renderer.strokeColor = NSColor(
                red:   CGFloat(t),
                green: CGFloat(1 - t),
                blue:  0,
                alpha: 0.8
            )
            renderer.lineWidth = CGFloat(4 + (weight / 100))
            renderer.lineCap = .round
            return renderer
        }
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @State private var searchText = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -6.90389, longitude: 107.61861),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    // Sample analytics data
    let vehicleData = [
        VehicleAnalytics(type: "Car", count: 9000, percentage: 40.7, color: Color("ColorBluePrimary")),
        VehicleAnalytics(type: "Bus", count: 1000, percentage: 33.3, color: Color("ColorBlueSecondary")),
        VehicleAnalytics(type: "Truck", count: 2000, percentage: 26.0, color: Color("ColorGrayPrimary"))
    ]
    
    // Sample segments for map heatmap
    let trafficSegments: [TrafficSegment] = [
        .init(start: CLLocationCoordinate2D(latitude: -6.30497, longitude: 106.64173),
              end:   CLLocationCoordinate2D(latitude: -6.30617, longitude: 106.64455),
              weight: 50),
        .init(start: CLLocationCoordinate2D(latitude: -6.30617, longitude: 106.64455),
              end:   CLLocationCoordinate2D(latitude: -6.30397, longitude: 106.65769),
              weight: 150),
        .init(start: CLLocationCoordinate2D(latitude: -6.30397, longitude: 106.65769),
              end:   CLLocationCoordinate2D(latitude: -6.30293, longitude: 106.66266),
              weight: 300)
    ]
    
    let trafficData = [
        TrafficFlowData(location: "Off Ramp Serpong 2", vehicleCount: "120,021"),
        TrafficFlowData(location: "Off Ramp Serpong 7", vehicleCount: "120,021"),
        TrafficFlowData(location: "On Ramp Serpong 3", vehicleCount: "120,021"),
        TrafficFlowData(location: "On Ramp Serpong 6", vehicleCount: "120,021"),
        TrafficFlowData(location: "Off Ramp Pondok Aren 1", vehicleCount: "120,021"),
        TrafficFlowData(location: "On Ramp pondok Aren 2", vehicleCount: "120,021"),
        TrafficFlowData(location: "Off Ramp Pondok Ranji Jakarta", vehicleCount: "120,021")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                HStack(alignment: .top, spacing: 24) {
                    VStack(spacing: 24) {
                        heatmapSection
                        vehicleCountCards
                    }
                    .frame(maxWidth: .infinity)
                    
                    analyticsSection
                        .frame(width: 400)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 24)
            }
        }
        .background(Color("ColorGraySecondary"))
        .preferredColorScheme(.light)
    }
    
    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Heatmap")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color("ColorBluePrimary"))
            
            TrafficMapView(segments: trafficSegments, region: $region)
                .frame(height: 400)
                .cornerRadius(12)
                .shadow(radius: 4)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hi there")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Color("ColorGrayPrimary"))
                
                Text("Kaori Hanami")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Color("ColorBluePrimary"))
            }
            
            Spacer()
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("ColorGrayPrimary"))
                    .font(.system(size: 16))
                
                TextField("Search", text: $searchText)
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
            .frame(width: 300)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 32)
        .background(Color.white)
    }
    private var vehicleCountCards: some View {
        HStack(spacing: 20) {
            ForEach(vehicleData, id: \.type) { data in
                VStack(alignment: .leading, spacing: 8) {
                    Text(data.type)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("ColorBluePrimary"))
                    
                    Text("\(Int(data.count).formatted())")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(data.color)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    private var analyticsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Analytics Header and Pie Chart
            VStack(alignment: .leading, spacing: 16) {
                Text("Analytics")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("ColorBluePrimary"))
                
                // Pie Chart
                ZStack {
                    // Pie chart using Canvas
                    Canvas { context, size in
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        let radius: CGFloat = min(size.width, size.height) / 2 - 20
                        
                        var startAngle: Angle = .degrees(-90)
                        
                        for data in vehicleData {
                            let endAngle = startAngle + .degrees(data.percentage * 360 / 100)
                            
                            let path = Path { path in
                                path.move(to: center)
                                path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
                            }
                            
                            context.fill(path, with: .color(data.color))
                            
                            startAngle = endAngle
                        }
                    }
                    .frame(width: 200, height: 200)
                    
                    // Center percentages
                    VStack {
                        ForEach(vehicleData, id: \.type) { data in
                            Text("\(data.percentage, specifier: "%.1f")%")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(data.color)
                        }
                    }
                }
                
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(vehicleData, id: \.type) { data in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(data.color)
                                .frame(width: 12, height: 12)
                            
                            HStack {
                                Text(data.type)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color("ColorBluePrimary"))
                                
                                Spacer()
                                
                                Text("\(data.percentage, specifier: "%.1f")%")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color("ColorGrayPrimary"))
                            }
                        }
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("View Detail")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("ColorBluePrimary"))
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 12))
                                .foregroundColor(Color("ColorBluePrimary"))
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color("ColorGraySecondary"))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Traffic Data Table
            trafficDataTable
        }
    }
    
    private var trafficDataTable: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .foregroundColor(Color("ColorGrayPrimary"))
                    Text("Filter lines...")
                        .font(.system(size: 14))
                        .foregroundColor(Color("ColorGrayPrimary"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color("ColorGraySecondary").opacity(0.5))
                .cornerRadius(6)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text("Columns")
                        .font(.system(size: 14))
                        .foregroundColor(Color("ColorBluePrimary"))
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Color("ColorGrayPrimary"))
                }
            }
            
            // ... rest of DashboardView unchanged ...
        }
        
    }
    
}

// MARK: - Models
struct VehicleAnalytics {
    let type: String
    let count: Double
    let percentage: Double
    let color: Color
}

struct TrafficFlowData {
    let location: String
    let vehicleCount: String
}

#Preview {
    DashboardView()
}
