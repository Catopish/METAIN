import SwiftUI

struct ComparisonChartView: View {
    let selectedRoutes: Set<RouteOption>
    let monthlyData: [MonthlyVehicleData]
    
    var body: some View {
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
                    
                    // Draw lines for selected routes
                    for route in selectedRoutes {
                        let routePath = Path { path in
                            for (index, data) in monthlyData.enumerated() {
                                let x = size.width * CGFloat(index) / CGFloat(monthlyData.count - 1)
                                let y = size.height - (size.height * CGFloat(TrafficDataService.getDataForRoute(route, data: data)) / 13000)
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        context.stroke(routePath, with: .color(TrafficDataService.colorForRoute(route)), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    }
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
