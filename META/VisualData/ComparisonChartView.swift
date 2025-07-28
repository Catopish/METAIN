import SwiftUI

struct ComparisonChartView: View {
    let chartData: [RouteChartData]
    let isShowingDays: Bool // true for daily view, false for monthly view
    
    @State private var hoveredPoint: (routeId: UUID, pointIndex: Int)? = nil
    @State private var hoverPosition: CGPoint = .zero
    @State private var isHovering: Bool = false
    
    private var maxValue: Int {
        chartData.flatMap { $0.dataPoints }.map { $0.value }.max() ?? 13000
    }
    
    private var dataPointCount: Int {
        chartData.first?.dataPoints.count ?? 12
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Y-axis labels and chart area
            HStack(alignment: .bottom, spacing: 8) {
                // Y-axis
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(Array(stride(from: maxValue, through: 2000, by: -1000)), id: \.self) { value in
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
                
                // Chart area with hover detection
                ZStack {
                    // Chart canvas
                    Canvas { context, size in
                        // Draw grid lines (vertical)
                        for i in 0..<dataPointCount {
                            let x = size.width * CGFloat(i) / CGFloat(dataPointCount - 1)
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
                        
                        // Draw lines and points for each route
                        for routeData in chartData {
                            // Draw line
                            let routePath = Path { path in
                                for (index, dataPoint) in routeData.dataPoints.enumerated() {
                                    let x = size.width * CGFloat(index) / CGFloat(dataPointCount - 1)
                                    let y = size.height - (size.height * CGFloat(dataPoint.value) / CGFloat(maxValue))
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            context.stroke(routePath, with: .color(routeData.color), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            
                            // Draw data points
                            for (index, dataPoint) in routeData.dataPoints.enumerated() {
                                let x = size.width * CGFloat(index) / CGFloat(dataPointCount - 1)
                                let y = size.height - (size.height * CGFloat(dataPoint.value) / CGFloat(maxValue))
                                
                                let isHovered = hoveredPoint?.routeId == routeData.id && hoveredPoint?.pointIndex == index
                                let pointSize: CGFloat = isHovered ? 8 : 5
                                
                                // Draw point
                                let pointPath = Path { path in
                                    path.addEllipse(in: CGRect(
                                        x: x - pointSize/2,
                                        y: y - pointSize/2,
                                        width: pointSize,
                                        height: pointSize
                                    ))
                                }
                                context.fill(pointPath, with: .color(routeData.color))
                                
                                // Draw white border for hovered point
                                if isHovered {
                                    context.stroke(pointPath, with: .color(.white), style: StrokeStyle(lineWidth: 2))
                                }
                            }
                        }
                    }
                    .frame(height: 240)
                    
                    // Invisible overlay for hover detection - positioned to not interfere with tooltip
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .onContinuousHover { phase in
                                switch phase {
                                case .active(let location):
                                    isHovering = true
                                    handleHover(at: location, in: geometry.size)
                                case .ended:
                                    isHovering = false
                                    // Add small delay before hiding to prevent flickering
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        if !isHovering {
                                            hoveredPoint = nil
                                        }
                                    }
                                }
                            }
                    }
                    .frame(height: 240)
                    
                    // Tooltip - positioned to not interfere with hover
                    if let hoveredPoint = hoveredPoint,
                       let routeData = chartData.first(where: { $0.id == hoveredPoint.routeId }),
                       hoveredPoint.pointIndex < routeData.dataPoints.count {
                        let dataPoint = routeData.dataPoints[hoveredPoint.pointIndex]
                        
                        TooltipView(
                            route: routeData.route,
                            dataPoint: dataPoint,
                            color: routeData.color
                        )
                        .position(x: min(max(80, hoverPosition.x), 600), y: max(80, hoverPosition.y - 60))
                        .allowsHitTesting(false) // Prevent tooltip from interfering with hover
                        .zIndex(1000)
                    }
                }
            }
            
            // X-axis labels
            HStack(spacing: 0) {
                Text("") // Empty space for Y-axis
                    .frame(width: 58)
                
                HStack(spacing: 0) {
                    if let firstRoute = chartData.first {
                        ForEach(firstRoute.dataPoints.indices, id: \.self) { index in
                            Text(firstRoute.dataPoints[index].label)
                                .font(.system(size: 10))
                                .foregroundColor(Color("ColorGrayPrimary"))
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                Text(isShowingDays ? "Day" : "Month")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("ColorGrayPrimary"))
                    .padding(.leading, 16)
            }
        }
    }
    
    private func handleHover(at location: CGPoint, in size: CGSize) {
        // Find closest data point with improved tolerance
        let pointWidth = size.width / CGFloat(max(1, dataPointCount - 1))
        let closestIndex = Int(round(location.x / pointWidth))
        
        guard closestIndex >= 0 && closestIndex < dataPointCount else {
            return // Don't clear hoveredPoint immediately to prevent flickering
        }
        
        // Find closest route with increased tolerance for better stability
        var closestRoute: RouteChartData?
        var closestDistance: CGFloat = .infinity
        
        for routeData in chartData {
            guard closestIndex < routeData.dataPoints.count else { continue }
            
            let dataPoint = routeData.dataPoints[closestIndex]
            let x = size.width * CGFloat(closestIndex) / CGFloat(max(1, dataPointCount - 1))
            let y = size.height - (size.height * CGFloat(dataPoint.value) / CGFloat(maxValue))
            
            let distance = sqrt(pow(location.x - x, 2) + pow(location.y - y, 2))
            
            if distance < closestDistance && distance < 30 { // Increased tolerance to 30 for better stability
                closestDistance = distance
                closestRoute = routeData
            }
        }
        
        if let route = closestRoute {
            hoveredPoint = (routeId: route.id, pointIndex: closestIndex)
            hoverPosition = location
        }
    }
}

struct TooltipView: View {
    let route: RouteOption
    let dataPoint: ChartDataPoint
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Route name with colored indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(route.displayName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("ColorBluePrimary"))
            }
            
            // Vehicle data
            Text("Vehicle")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
            
            Text("\(dataPoint.value.formatted())")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            // Breakdown data
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text("\(dataPoint.carCount.formatted()) Car")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                HStack {
                    Text("\(dataPoint.busCount.formatted()) Bus")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                HStack {
                    Text("\(dataPoint.truckCount.formatted()) Truck")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .frame(width: 140)
    }
} 
