//
//  DashboardView.swift
//  META
//
//  Created by Al Amin Dwiesta on 22/07/25.
//

import SwiftUI

struct DashboardView: View {
    @State private var searchText = ""
    
    // Sample data for analytics
    let vehicleData = [
        VehicleAnalytics(type: "Car", count: 9000, percentage: 40.7, color: Color("ColorBluePrimary")),
        VehicleAnalytics(type: "Bus", count: 1000, percentage: 33.3, color: Color("ColorBlueSecondary")),
        VehicleAnalytics(type: "Truck", count: 2000, percentage: 26.0, color: Color("ColorGrayPrimary"))
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
                // Header Section
                headerSection
                
                // Main Content
                mainContent
            }
        }
        .background(Color("ColorGraySecondary"))
        .preferredColorScheme(.light) // Force light mode
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
    
    private var mainContent: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(spacing: 24) {
                // Heatmap Section
                heatmapSection
                
                // Vehicle Count Cards
                vehicleCountCards
            }
            .frame(maxWidth: .infinity)
            
            // Analytics Section
            analyticsSection
                .frame(width: 400)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }
    
    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Heatmap Header
            HStack {
                Text("Heatmap")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("ColorBluePrimary"))
                
                Spacer()
                
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "location")
                            .foregroundColor(Color("ColorGrayPrimary"))
                        Text("Galongan 1")
                            .font(.system(size: 14))
                            .foregroundColor(Color("ColorBluePrimary"))
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(Color("ColorGrayPrimary"))
                        Text("xx/xx/xxxx")
                            .font(.system(size: 14))
                            .foregroundColor(Color("ColorBluePrimary"))
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .foregroundColor(Color("ColorGrayPrimary"))
                        Text("00:00 - 01:00 AM")
                            .font(.system(size: 14))
                            .foregroundColor(Color("ColorBluePrimary"))
                    }
                }
            }
            
            // Map Placeholder with Traffic Flow Visualization
            ZStack {
                // Background map image placeholder
                Rectangle()
                    .fill(Color.green.opacity(0.3))
                    .frame(height: 400)
                    .cornerRadius(12)
                
                // Traffic flow visualization overlay
                VStack {
                    Spacer()
                    
                    Text("JOMBANG")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                    
                    Spacer()
                    
                    // Traffic intensity legend
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(.green)
                            .frame(width: 60, height: 20)
                        Rectangle()
                            .fill(.yellow)
                            .frame(width: 60, height: 20)
                        Rectangle()
                            .fill(.red)
                            .frame(width: 60, height: 20)
                    }
                    .overlay(
                        HStack {
                            Text("Light")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white)
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
                    .padding(.bottom, 16)
                }
                
                // Simulated traffic flow lines
                Canvas { context, size in
                    // Green lines (light traffic)
                    let greenPath = Path { path in
                        path.move(to: CGPoint(x: size.width * 0.1, y: size.height * 0.7))
                        path.addQuadCurve(to: CGPoint(x: size.width * 0.9, y: size.height * 0.8), 
                                        control: CGPoint(x: size.width * 0.5, y: size.height * 0.6))
                    }
                    context.stroke(greenPath, with: .color(.green), style: StrokeStyle(lineWidth: 8))
                    
                    // Yellow lines (medium traffic)
                    let yellowPath = Path { path in
                        path.move(to: CGPoint(x: size.width * 0.2, y: size.height * 0.5))
                        path.addCurve(to: CGPoint(x: size.width * 0.8, y: size.height * 0.4),
                                    control1: CGPoint(x: size.width * 0.4, y: size.height * 0.2),
                                    control2: CGPoint(x: size.width * 0.6, y: size.height * 0.3))
                    }
                    context.stroke(yellowPath, with: .color(.yellow), style: StrokeStyle(lineWidth: 6))
                    
                    // Red lines (heavy traffic)
                    let redPath = Path { path in
                        path.move(to: CGPoint(x: size.width * 0.15, y: size.height * 0.3))
                        path.addLine(to: CGPoint(x: size.width * 0.85, y: size.height * 0.35))
                    }
                    context.stroke(redPath, with: .color(.red), style: StrokeStyle(lineWidth: 4))
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
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
            
            // Table Header
            HStack {
                Text("Header title")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("ColorGrayPrimary"))
                
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(Color("ColorGrayPrimary"))
                
                Spacer()
                
                Text("Number of Vehicle")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("ColorGrayPrimary"))
                
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(Color("ColorGrayPrimary"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color("ColorGraySecondary").opacity(0.3))
            .cornerRadius(8)
            
            // Table Data
            LazyVStack(spacing: 0) {
                ForEach(trafficData, id: \.location) { data in
                    HStack {
                        Text(data.location)
                            .font(.system(size: 14))
                            .foregroundColor(Color("ColorBluePrimary"))
                        
                        Spacer()
                        
                        Text(data.vehicleCount)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color("ColorBluePrimary"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    
                    if data.location != trafficData.last?.location {
                        Divider()
                            .background(Color("ColorGraySecondary"))
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(8)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Data Models
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
