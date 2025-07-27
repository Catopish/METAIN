import SwiftUI
import MapKit

// MARK: - Route and Geographic Models
struct RouteOption: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let displayName: String
    
    static let allRoutes: [RouteOption] = [
        RouteOption(name: "all-routes", displayName: "All Routes"),
        RouteOption(name: "jakarta-pagedangan", displayName: "Jakarta - Pagedangan"),
        RouteOption(name: "pagedangan-jakarta", displayName: "Pagedangan - Jakarta"),
        RouteOption(name: "bintaro-out", displayName: "Bintaro Out"),
        RouteOption(name: "bintaro-in", displayName: "Bintaro In"),
        RouteOption(name: "jakarta-pamulang", displayName: "Jakarta - Pamulang"),
        RouteOption(name: "jakarta-alam-sutera", displayName: "Jakarta - Alam Sutera"),
        RouteOption(name: "pagedangan-alam-sutera", displayName: "Pagedangan - Alam Sutera"),
        RouteOption(name: "pagedangan-pamulang", displayName: "Pagedangan - Pamulang"),
        RouteOption(name: "pamulang-pagedangan", displayName: "Pamulang - Pagedangan"),
        RouteOption(name: "pamulang-jakarta", displayName: "Pamulang - Jakarta"),
        RouteOption(name: "alam-sutera-jakarta", displayName: "Alam Sutera - Jakarta"),
        RouteOption(name: "alam-sutera-pagedangan", displayName: "Alam Sutera - Pagedangan")
    ]
}

struct TrafficSegment {
    let start: CLLocationCoordinate2D
    let end: CLLocationCoordinate2D
    let weight: Double   // vehicles per hour for heatmap weighting
    let routeName: String // Add route name for identification
}

// MARK: - Traffic Data Models (Based on Excel Structure)
struct HourlyTrafficData: Identifiable {
    let id = UUID()
    let date: String        // "1 July 2025"
    let timeRange: String   // "00.00 - 01.00"
    let route: String       // "jakarta-pagedangan"
    let carCount: Int       // Mobil
    let busCount: Int       // Bus
    let truckCount: Int     // Truk
    
    var totalVehicles: Int {
        carCount + busCount + truckCount
    }
}

// MARK: - Analytics Models
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

// MARK: - Sample Data
struct TrafficDataService {
    
    static let sampleTrafficSegments: [TrafficSegment] = [
        .init(start: CLLocationCoordinate2D(latitude: -6.30497, longitude: 106.64173),
              end:   CLLocationCoordinate2D(latitude: -6.30617, longitude: 106.64455),
              weight: 2850, routeName: "sample"), // Green level
        .init(start: CLLocationCoordinate2D(latitude: -6.30617, longitude: 106.64455),
              end:   CLLocationCoordinate2D(latitude: -6.30397, longitude: 106.65769),
              weight: 3990, routeName: "sample"), // Yellow level
        .init(start: CLLocationCoordinate2D(latitude: -6.30397, longitude: 106.65769),
              end:   CLLocationCoordinate2D(latitude: -6.30293, longitude: 106.66266),
              weight: 5700, routeName: "sample")  // Red level
    ]
    
    static let sampleVehicleData = [
        VehicleAnalytics(type: "Car", count: 2116, percentage: 40.7, color: Color("ColorBluePrimary"), iconName: "CarCardIcon"),
        VehicleAnalytics(type: "Bus", count: 500, percentage: 33.3, color: Color("ColorBluePrimary"), iconName: "BusCardIcon"),
        VehicleAnalytics(type: "Truck", count: 500, percentage: 26.0, color: Color("ColorBluePrimary"), iconName: "TruckCardIcon")
    ]
    
    static let sampleMonthlyData = [
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
    
    // Sample hourly data based on Excel structure - Updated with realistic traffic volumes for color differentiation
    static let sampleHourlyData: [HourlyTrafficData] = [
        // 00:00 - 01:00 - Scaled up for realistic hourly rates
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "jakarta-pagedangan", carCount: 1590, busCount: 590, truckCount: 1020), // Total: 3200 (Yellow)
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "pagedangan-jakarta", carCount: 2130, busCount: 1005, truckCount: 1335), // Total: 4470 (Red)
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "bintaro-out", carCount: 1600, busCount: 840, truckCount: 990), // Total: 3430 (Yellow)
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "bintaro-in", carCount: 1180, busCount: 1160, truckCount: 410), // Total: 2750 (Green)
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "jakarta-pamulang", carCount: 3600, busCount: 1740, truckCount: 720), // Total: 6060 (Red)
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "jakarta-alam-sutera", carCount: 1650, busCount: 1550, truckCount: 320), // Total: 3520 (Yellow)
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "pagedangan-alam-sutera", carCount: 1050, busCount: 370, truckCount: 1070), // Total: 2490 (Green)
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "pagedangan-pamulang", carCount: 2040, busCount: 960, truckCount: 640), // Total: 3640 (Yellow)
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "pamulang-pagedangan", carCount: 2205, busCount: 2010, truckCount: 705), // Total: 4920 (Red)
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "pamulang-jakarta", carCount: 1245, busCount: 735, truckCount: 615), // Total: 2595 (Green)
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "alam-sutera-jakarta", carCount: 2130, busCount: 1950, truckCount: 600), // Total: 4680 (Red)
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "alam-sutera-pagedangan", carCount: 1260, busCount: 1200, truckCount: 495), // Total: 2955 (Yellow)
        
        // 01:00 - 02:00 - Different traffic patterns for variety
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "jakarta-pagedangan", carCount: 1230, busCount: 720, truckCount: 705), // Total: 2655 (Green)
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "pagedangan-jakarta", carCount: 1425, busCount: 780, truckCount: 915), // Total: 3120 (Yellow)
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "bintaro-out", carCount: 2550, busCount: 1680, truckCount: 705), // Total: 4935 (Red)
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "bintaro-in", carCount: 1770, busCount: 735, truckCount: 690), // Total: 3195 (Yellow)
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "jakarta-pamulang", carCount: 2670, busCount: 2205, truckCount: 495), // Total: 5370 (Red)
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "jakarta-alam-sutera", carCount: 2505, busCount: 885, truckCount: 525), // Total: 3915 (Yellow)
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "pagedangan-alam-sutera", carCount: 1485, busCount: 480, truckCount: 495), // Total: 2460 (Green)
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "pagedangan-pamulang", carCount: 2325, busCount: 645, truckCount: 1785), // Total: 4755 (Red)
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "pamulang-pagedangan", carCount: 2655, busCount: 1845, truckCount: 750), // Total: 5250 (Red)
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "pamulang-jakarta", carCount: 2505, busCount: 1080, truckCount: 720), // Total: 4305 (Red)
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "alam-sutera-jakarta", carCount: 1245, busCount: 750, truckCount: 735), // Total: 2730 (Green)
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "alam-sutera-pagedangan", carCount: 1470, busCount: 1245, truckCount: 525) // Total: 3240 (Yellow)
    ]
    
    // Helper function to get route coordinates based on the provided data
    static func getRouteCoordinates(for route: RouteOption) -> (start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        switch route.name {
        case "jakarta-pagedangan":
            return (
                start: CLLocationCoordinate2D(latitude: -6.28572, longitude: 106.73091),
                end: CLLocationCoordinate2D(latitude: -6.30782, longitude: 106.69069)
            )
        case "pagedangan-jakarta":
            return (
                start: CLLocationCoordinate2D(latitude: -6.30482, longitude: 106.69713),
                end: CLLocationCoordinate2D(latitude: -6.28477, longitude: 106.73216)
            )
        case "bintaro-out":
            return (
                start: CLLocationCoordinate2D(latitude: -6.28984, longitude: 106.72461),
                end: CLLocationCoordinate2D(latitude: -6.28687, longitude: 106.72674)
            )
        case "bintaro-in":
            return (
                start: CLLocationCoordinate2D(latitude: -6.28889, longitude: 106.72886),
                end: CLLocationCoordinate2D(latitude: -6.29013, longitude: 106.72485)
            )
        case "jakarta-pamulang":
            return (
                start: CLLocationCoordinate2D(latitude: -6.29797, longitude: 106.70813),
                end: CLLocationCoordinate2D(latitude: -6.30534, longitude: 106.70586)
            )
        case "jakarta-alam-sutera":
            return (
                start: CLLocationCoordinate2D(latitude: -6.29816, longitude: 106.70786),
                end: CLLocationCoordinate2D(latitude: -6.29894, longitude: 106.69725)
            )
        case "pagedangan-alam-sutera":
            return (
                start: CLLocationCoordinate2D(latitude: -6.30331, longitude: 106.69954),
                end: CLLocationCoordinate2D(latitude: -6.29894, longitude: 106.69725)
            )
        case "pagedangan-pamulang":
            return (
                start: CLLocationCoordinate2D(latitude: -6.30338, longitude: 106.69960),
                end: CLLocationCoordinate2D(latitude: -6.30310, longitude: 106.70402)
            )
        case "pamulang-pagedangan":
            return (
                start: CLLocationCoordinate2D(latitude: -6.30564, longitude: 106.70574),
                end: CLLocationCoordinate2D(latitude: -6.30724, longitude: 106.69257)
            )
        case "pamulang-jakarta":
            return (
                start: CLLocationCoordinate2D(latitude: -6.30290, longitude: 106.70340),
                end: CLLocationCoordinate2D(latitude: -6.29853, longitude: 106.70694)
            )
        case "alam-sutera-pagedangan":
            return (
                start: CLLocationCoordinate2D(latitude: -6.30026, longitude: 106.70040),
                end: CLLocationCoordinate2D(latitude: -6.30380, longitude: 106.69977)
            )
        case "alam-sutera-jakarta":
            return (
                start: CLLocationCoordinate2D(latitude: -6.29989, longitude: 106.69956),
                end: CLLocationCoordinate2D(latitude: -6.29917, longitude: 106.70617)
            )
        default:
            // Default to Jakarta - Alam Sutera coordinates
            return (
                start: CLLocationCoordinate2D(latitude: -6.29816, longitude: 106.70786),
                end: CLLocationCoordinate2D(latitude: -6.29894, longitude: 106.69725)
            )
        }
    }
    
    // Helper function to generate traffic segments for a selected route
    static func getTrafficSegmentsForRoute(_ route: RouteOption) -> [TrafficSegment] {
        if route.name == "all-routes" {
            // Return segments for all routes
            var allSegments: [TrafficSegment] = []
            for routeOption in RouteOption.allRoutes {
                if routeOption.name != "all-routes" {
                    let coordinates = getRouteCoordinates(for: routeOption)
                    let routeTrafficData = sampleHourlyData.filter { $0.route == routeOption.name }
                    let averageTraffic = routeTrafficData.isEmpty ? 3500 : 
                        Double(routeTrafficData.map { $0.totalVehicles }.reduce(0, +)) / Double(routeTrafficData.count)
                    
                    allSegments.append(TrafficSegment(
                        start: coordinates.start,
                        end: coordinates.end,
                        weight: averageTraffic,
                        routeName: routeOption.name
                    ))
                }
            }
            return allSegments
        } else {
            // Return segment for specific route
            let coordinates = getRouteCoordinates(for: route)
            let routeTrafficData = sampleHourlyData.filter { $0.route == route.name }
            let averageTraffic = routeTrafficData.isEmpty ? 3500 : 
                Double(routeTrafficData.map { $0.totalVehicles }.reduce(0, +)) / Double(routeTrafficData.count)
            
            return [TrafficSegment(
                start: coordinates.start,
                end: coordinates.end,
                weight: averageTraffic,
                routeName: route.name
            )]
        }
    }
    
    // Helper function to determine appropriate zoom level
    static func getZoomLevel(for route: RouteOption) -> MKCoordinateSpan {
        switch route.name {
        case "all-routes", "jakarta-pagedangan", "pagedangan-jakarta":
            // Reduced zoom scale (was 0.08, now 0.05 for better visibility)
            return MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        default:
            // Normal zoom for shorter routes
            return MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        }
    }
    
    // Helper function to get center coordinate for route or all routes
    static func getCenterCoordinate(for route: RouteOption) -> CLLocationCoordinate2D {
        if route.name == "all-routes" {
            // Center on overall area covering all routes
            return CLLocationCoordinate2D(latitude: -6.295, longitude: 106.71)
        } else {
            let coordinates = getRouteCoordinates(for: route)
            let centerLat = (coordinates.start.latitude + coordinates.end.latitude) / 2
            let centerLon = (coordinates.start.longitude + coordinates.end.longitude) / 2
            return CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
        }
    }
    
    // Helper function to get vehicle data for selected route
    static func getVehicleDataForRoute(_ route: RouteOption, timeRange: String = "00.00 - 01.00") -> [VehicleAnalytics] {
        if route.name == "all-routes" {
            // Calculate totals for all routes
            let allRouteData = sampleHourlyData.filter { $0.timeRange == timeRange }
            let totalCars = allRouteData.map { $0.carCount }.reduce(0, +)
            let totalBuses = allRouteData.map { $0.busCount }.reduce(0, +)
            let totalTrucks = allRouteData.map { $0.truckCount }.reduce(0, +)
            let grandTotal = totalCars + totalBuses + totalTrucks
            
            return [
                VehicleAnalytics(
                    type: "Car", 
                    count: Double(totalCars), 
                    percentage: grandTotal > 0 ? Double(totalCars) / Double(grandTotal) * 100 : 0,
                    color: Color("ColorBluePrimary"), 
                    iconName: "CarCardIcon"
                ),
                VehicleAnalytics(
                    type: "Bus", 
                    count: Double(totalBuses), 
                    percentage: grandTotal > 0 ? Double(totalBuses) / Double(grandTotal) * 100 : 0,
                    color: Color("ColorBluePrimary"),
                    iconName: "BusCardIcon"
                ),
                VehicleAnalytics(
                    type: "Truck", 
                    count: Double(totalTrucks), 
                    percentage: grandTotal > 0 ? Double(totalTrucks) / Double(grandTotal) * 100 : 0,
                    color: Color("ColorBluePrimary"), 
                    iconName: "TruckCardIcon"
                )
            ]
        } else {
            // Get data for specific route
            let routeData = sampleHourlyData.filter { $0.route == route.name && $0.timeRange == timeRange }
            if let data = routeData.first {
                let total = data.totalVehicles
                return [
                    VehicleAnalytics(
                        type: "Car", 
                        count: Double(data.carCount), 
                        percentage: total > 0 ? Double(data.carCount) / Double(total) * 100 : 0,
                        color: Color("ColorBluePrimary"), 
                        iconName: "CarCardIcon"
                    ),
                    VehicleAnalytics(
                        type: "Bus", 
                        count: Double(data.busCount), 
                        percentage: total > 0 ? Double(data.busCount) / Double(total) * 100 : 0,
                        color: Color("ColorBluePrimary"), 
                        iconName: "BusCardIcon"
                    ),
                    VehicleAnalytics(
                        type: "Truck", 
                        count: Double(data.truckCount), 
                        percentage: total > 0 ? Double(data.truckCount) / Double(total) * 100 : 0,
                        color: Color("ColorBluePrimary"), 
                        iconName: "TruckCardIcon"
                    )
                ]
            } else {
                // Return default data if no specific data found
                return sampleVehicleData
            }
        }
    }
    
    // Helper function to get total traffic and percentage for a specific route
    static func getRouteTrafficInfo(_ route: RouteOption, timeRange: String = "00.00 - 01.00") -> (total: Int, percentage: Double) {
        let allRouteData = sampleHourlyData.filter { $0.timeRange == timeRange }
        let grandTotal = allRouteData.map { $0.totalVehicles }.reduce(0, +)
        
        let routeData = sampleHourlyData.filter { $0.route == route.name && $0.timeRange == timeRange }
        let routeTotal = routeData.first?.totalVehicles ?? 0
        
        let percentage = grandTotal > 0 ? Double(routeTotal) / Double(grandTotal) * 100 : 0
        
        return (total: routeTotal, percentage: percentage)
    }
    
    // Helper function to get data for a specific route
    static func getDataForRoute(_ route: RouteOption, data: MonthlyVehicleData) -> Int {
        switch route.name {
        case "bintaro-out":
            return data.bintaraOut
        case "jakarta-alam-sutera":
            return data.jakartaAlamSutera
        default:
            // Return some sample data for other routes
            return Int.random(in: 2000...8000)
        }
    }
    
    // Helper function to get color for route using specific color assets
    static func colorForRoute(_ route: RouteOption) -> Color {
        switch route.name {
        case "jakarta-pagedangan":
            return Color("RouteJakartaPagedangan")
        case "pagedangan-jakarta":
            return Color("RouteJakartaPagedangan") // Use same color as Jakarta-Pagedangan
        case "bintaro-out":
            return Color("RouteBintaroOut")
        case "bintaro-in":
            return Color("RouteBintaroln")
        case "jakarta-pamulang":
            return Color("RouteJakartaPamulang")
        case "jakarta-alam-sutera":
            return Color("RouteJakartaAlamSutera")
        case "pagedangan-alam-sutera":
            return Color("RoutePagedanganAlamSutera")
        case "pagedangan-pamulang":
            return Color("RoutePagedanganPamulang")
        case "pamulang-pagedangan":
            return Color("RoutePamulangPagedangan")
        case "pamulang-jakarta":
            return Color("RoutePamulangJakarta")
        case "alam-sutera-jakarta":
            return Color("RouteJakartaAlamSutera") // Reuse existing
        case "alam-sutera-pagedangan":
            return Color("RouteAlamSuteraPagedangan")
        default:
            return Color("ColorBluePrimary") // Fallback
        }
    }
    
    // Helper function to get heatmap color based on vehicle count with gradient
    static func heatmapColorForVehicleCount(_ vehicleCount: Double) -> Color {
        let greenThreshold: Double = 2850
        let yellowThreshold: Double = 3990
        let redThreshold: Double = 5700
        
        // Define the key colors
        let greenColor = Color(red: 0x00/255.0, green: 0xFC/255.0, blue: 0x33/255.0) // #00FC33
        let yellowColor = Color(red: 0xF2/255.0, green: 0xFE/255.0, blue: 0x06/255.0) // #F2FE06
        let redColor = Color(red: 0xF9/255.0, green: 0x05/255.0, blue: 0x01/255.0) // #F90501
        
        if vehicleCount <= greenThreshold {
            return greenColor
        } else if vehicleCount <= yellowThreshold {
            // Interpolate between green and yellow
            let ratio = (vehicleCount - greenThreshold) / (yellowThreshold - greenThreshold)
            return interpolateColor(from: greenColor, to: yellowColor, ratio: ratio)
        } else if vehicleCount <= redThreshold {
            // Interpolate between yellow and red
            let ratio = (vehicleCount - yellowThreshold) / (redThreshold - yellowThreshold)
            return interpolateColor(from: yellowColor, to: redColor, ratio: ratio)
        } else {
            return redColor
        }
    }
    
    // Helper function to interpolate between two colors
    private static func interpolateColor(from startColor: Color, to endColor: Color, ratio: Double) -> Color {
        let clampedRatio = max(0, min(1, ratio))
        
        // Convert colors to RGB components for interpolation
        let startComponents = startColor.cgColor?.components ?? [0, 0, 0, 1]
        let endComponents = endColor.cgColor?.components ?? [0, 0, 0, 1]
        
        let r = startComponents[0] + (endComponents[0] - startComponents[0]) * clampedRatio
        let g = startComponents[1] + (endComponents[1] - startComponents[1]) * clampedRatio
        let b = startComponents[2] + (endComponents[2] - startComponents[2]) * clampedRatio
        
        return Color(red: r, green: g, blue: b)
    }
} 
