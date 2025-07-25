//
//  VisualDataView.swift
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

// MARK: - Visual Data View
struct VisualDataView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -6.90389, longitude: 107.61861),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    // Sample analytics data
    let vehicleData = [
        VehicleAnalytics(type: "Car", count: 2116, percentage: 40.7, color: Color("ColorBluePrimary"), iconName: "CarCardIcon"),
        VehicleAnalytics(type: "Bus", count: 500, percentage: 33.3, color: Color("ColorBlueSecondary"), iconName: "BusCardIcon"),
        VehicleAnalytics(type: "Truck", count: 500, percentage: 26.0, color: Color("ColorGrayPrimary"), iconName: "TruckCardIcon")
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
    
    // Sample data for comparison chart
    let monthlyData = [
        MonthlyVehicleData(month: "Jan", bintaraOut: 4200, jakartaAlamSutera: 4500),
        MonthlyVehicleData(month: "Feb", bintaraOut: 4400, jakartaAlamSutera: 4300),
        MonthlyVehicleData(month: "Mar", bintaraOut: 7800, jakartaAlamSutera: 6200),
        MonthlyVehicleData(month: "Apr", bintaraOut: 7200, jakartaAlamSutera: 5800),
        MonthlyVehicleData(month: "May", bintaraOut: 12500, jakartaAlamSutera: 6000),
        MonthlyVehicleData(month: "Jun", bintaraOut: 5500, jakartaAlamSutera: 5200),
        MonthlyVehicleData(month: "Jul", bintaraOut: 6000, jakartaAlamSutera: 4800),
        MonthlyVehicleData(month: "Aug", bintaraOut: 10500, jakartaAlamSutera: 8500),
        MonthlyVehicleData(month: "Sep", bintaraOut: 3500, jakartaAlamSutera: 3200),
        MonthlyVehicleData(month: "Oct", bintaraOut: 2500, jakartaAlamSutera: 2800),
        MonthlyVehicleData(month: "Nov", bintaraOut: 7500, jakartaAlamSutera: 6200),
        MonthlyVehicleData(month: "Dec", bintaraOut: 11000, jakartaAlamSutera: 4200)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Heatmap Section
                heatmapSection
                
                // Vehicle Count Cards
                vehicleCountCards
                
                // Comparison Section
                comparisonSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
        .background(Color("ColorGraySecondary"))
        .preferredColorScheme(.light)
    }
    
    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Heatmap")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("ColorBluePrimary"))
                
                Spacer()
                
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "location")
                            .foregroundColor(Color("ColorGrayPrimary"))
                        Text("Jakarta - Alam sutera")
                            .font(.system(size: 14))
                            .foregroundColor(Color("ColorBluePrimary"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("ColorGrayPrimary").opacity(0.3), lineWidth: 1)
                    )
                    
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(Color("ColorGrayPrimary"))
                        Text("20/06/2025 - 5/07/2025")
                            .font(.system(size: 14))
                            .foregroundColor(Color("ColorBluePrimary"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("ColorGrayPrimary").opacity(0.3), lineWidth: 1)
                    )
                }
            }
            
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
    
    private var vehicleCountCards: some View {
        HStack(spacing: 20) {
            ForEach(vehicleData, id: \.type) { data in
                VStack(alignment: .center, spacing: 12) {
                    Image(data.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                    
                    VStack(spacing: 4) {
                        Text(data.type)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("ColorBluePrimary"))
                        
                        Text("\(Int(data.count).formatted())")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(data.color)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
    }
    
    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Comparison of vehicle volumes")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color("ColorBluePrimary"))
            
            HStack(spacing: 16) {
                // Year selector
                HStack(spacing: 8) {
                    Text("2025")
                        .font(.system(size: 14))
                        .foregroundColor(Color("ColorBluePrimary"))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Color("ColorGrayPrimary"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("ColorGrayPrimary").opacity(0.3), lineWidth: 1)
                )
                
                // Time period selector
                HStack(spacing: 8) {
                    Text("All Months")
                        .font(.system(size: 14))
                        .foregroundColor(Color("ColorBluePrimary"))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Color("ColorGrayPrimary"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("ColorGrayPrimary").opacity(0.3), lineWidth: 1)
                )
                
                // Route selector
                HStack(spacing: 8) {
                    Text("Route")
                        .font(.system(size: 14))
                        .foregroundColor(Color("ColorBluePrimary"))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(Color("ColorGrayPrimary"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color("ColorGrayPrimary").opacity(0.3), lineWidth: 1)
                )
                
                Spacer()
            }
            
            // Chart
            comparisonChart
            
            // Legend
            HStack(spacing: 24) {
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color("ColorBluePrimary"))
                        .frame(width: 16, height: 3)
                        .cornerRadius(1.5)
                    Text("Bintara Out")
                        .font(.system(size: 14))
                        .foregroundColor(Color("ColorBluePrimary"))
                }
                
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(Color("ColorGrayPrimary"))
                        .frame(width: 16, height: 3)
                        .cornerRadius(1.5)
                    Text("Jakarta - Alam sutera")
                        .font(.system(size: 14))
                        .foregroundColor(Color("ColorBluePrimary"))
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var comparisonChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Y-axis labels and chart area
            HStack(alignment: .bottom, spacing: 8) {
                // Y-axis
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(Array(stride(from: 13000, through: 2000, by: -1000)), id: \.self) { value in
                        Text("\(value.formatted())")
                            .font(.system(size: 10))
                            .foregroundColor(Color("ColorGrayPrimary"))
                            .frame(height: 20)
                    }
                    Text("Volume")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color("ColorGrayPrimary"))
                        .padding(.top, 8)
                }
                .frame(width: 50)
                
                // Chart area
                Canvas { context, size in
                    // Draw grid lines
                    for i in 0...11 {
                        let x = size.width * CGFloat(i) / 11
                        let gridPath = Path { path in
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: size.height))
                        }
                        context.stroke(gridPath, with: .color(Color("ColorGraySecondary").opacity(0.5)), style: StrokeStyle(lineWidth: 0.5))
                    }
                    
                    // Draw horizontal grid lines
                    for i in 0...11 {
                        let y = size.height * CGFloat(i) / 11
                        let gridPath = Path { path in
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: size.width, y: y))
                        }
                        context.stroke(gridPath, with: .color(Color("ColorGraySecondary").opacity(0.5)), style: StrokeStyle(lineWidth: 0.5))
                    }
                    
                    // Draw Bintara Out line (blue)
                    let bintaraPath = Path { path in
                        for (index, data) in monthlyData.enumerated() {
                            let x = size.width * CGFloat(index) / CGFloat(monthlyData.count - 1)
                            let y = size.height - (size.height * CGFloat(data.bintaraOut) / 13000)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    context.stroke(bintaraPath, with: .color(Color("ColorBluePrimary")), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    
                    // Draw Jakarta - Alam sutera line (gray)
                    let jakartaPath = Path { path in
                        for (index, data) in monthlyData.enumerated() {
                            let x = size.width * CGFloat(index) / CGFloat(monthlyData.count - 1)
                            let y = size.height - (size.height * CGFloat(data.jakartaAlamSutera) / 13000)
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    context.stroke(jakartaPath, with: .color(Color("ColorGrayPrimary")), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
                .frame(height: 240)
            }
            
            // X-axis labels
            HStack(spacing: 0) {
                Text("") // Empty space for Y-axis
                    .frame(width: 58)
                
                HStack(spacing: 0) {
                    ForEach(monthlyData, id: \.month) { data in
                        Text(data.month)
                            .font(.system(size: 10))
                            .foregroundColor(Color("ColorGrayPrimary"))
                            .frame(maxWidth: .infinity)
                    }
                }
                
                Text("Month")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("ColorGrayPrimary"))
                    .padding(.leading, 16)
            }
        }
    }
}

// MARK: - Models
struct VehicleAnalytics {
    let type: String
    let count: Double
    let percentage: Double
    let color: Color
    let iconName: String
}

struct MonthlyVehicleData {
    let month: String
    let bintaraOut: Int
    let jakartaAlamSutera: Int
}

#Preview {
    VisualDataView()
} 