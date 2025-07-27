import SwiftUI
import MapKit

// MARK: - Route and Geographic Models
struct RouteOption: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let displayName: String
    
    static let allRoutes: [RouteOption] = [
        RouteOption(name: "jakarta-pagedangan", displayName: "Jakarta - Pagedangan"),
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
              weight: 2850), // Green level
        .init(start: CLLocationCoordinate2D(latitude: -6.30617, longitude: 106.64455),
              end:   CLLocationCoordinate2D(latitude: -6.30397, longitude: 106.65769),
              weight: 3990), // Yellow level
        .init(start: CLLocationCoordinate2D(latitude: -6.30397, longitude: 106.65769),
              end:   CLLocationCoordinate2D(latitude: -6.30293, longitude: 106.66266),
              weight: 5700)  // Red level
    ]
    
    static let sampleVehicleData = [
        VehicleAnalytics(type: "Car", count: 2116, percentage: 40.7, color: Color("ColorBluePrimary"), iconName: "CarCardIcon"),
        VehicleAnalytics(type: "Bus", count: 500, percentage: 33.3, color: Color("ColorBlueSecondary"), iconName: "BusCardIcon"),
        VehicleAnalytics(type: "Truck", count: 500, percentage: 26.0, color: Color("ColorGrayPrimary"), iconName: "TruckCardIcon")
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
    
    // Sample hourly data based on Excel structure
    static let sampleHourlyData: [HourlyTrafficData] = [
        // 00:00 - 01:00
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "jakarta-pagedangan", carCount: 159, busCount: 59, truckCount: 102),
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "bintaro-out", carCount: 80, busCount: 84, truckCount: 99),
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "bintaro-in", carCount: 118, busCount: 116, truckCount: 41),
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "jakarta-pamulang", carCount: 180, busCount: 116, truckCount: 48),
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "jakarta-alam-sutera", carCount: 165, busCount: 155, truckCount: 32),
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "pagedangan-alam-sutera", carCount: 175, busCount: 37, truckCount: 179),
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "pagedangan-pamulang", carCount: 102, busCount: 48, truckCount: 32),
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "pamulang-pagedangan", carCount: 147, busCount: 134, truckCount: 47),
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "pamulang-jakarta", carCount: 83, busCount: 49, truckCount: 41),
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "alam-sutera-jakarta", carCount: 142, busCount: 130, truckCount: 40),
        HourlyTrafficData(date: "1 July 2025", timeRange: "00.00 - 01.00", route: "alam-sutera-pagedangan", carCount: 84, busCount: 80, truckCount: 33),
        
        // 01:00 - 02:00
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "jakarta-pagedangan", carCount: 82, busCount: 48, truckCount: 47),
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "bintaro-out", carCount: 170, busCount: 112, truckCount: 47),
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "bintaro-in", carCount: 118, busCount: 49, truckCount: 46),
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "jakarta-pamulang", carCount: 178, busCount: 147, truckCount: 33),
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "jakarta-alam-sutera", carCount: 167, busCount: 59, truckCount: 35),
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "pagedangan-alam-sutera", carCount: 99, busCount: 32, truckCount: 33),
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "pagedangan-pamulang", carCount: 155, busCount: 43, truckCount: 119),
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "pamulang-pagedangan", carCount: 177, busCount: 123, truckCount: 50),
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "pamulang-jakarta", carCount: 167, busCount: 72, truckCount: 48),
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "alam-sutera-jakarta", carCount: 83, busCount: 50, truckCount: 49),
        HourlyTrafficData(date: "1 July 2025", timeRange: "01.00 - 02.00", route: "alam-sutera-pagedangan", carCount: 98, busCount: 83, truckCount: 35)
    ]
    
    // Helper function to get route coordinates based on the provided data
    static func getRouteCoordinates(for route: RouteOption) -> (start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        switch route.name {
        case "jakarta-pagedangan":
            return (
                start: CLLocationCoordinate2D(latitude: -6.28572, longitude: 106.73091),
                end: CLLocationCoordinate2D(latitude: -6.30782, longitude: 106.69069)
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
        let coordinates = getRouteCoordinates(for: route)
        
        // Get sample traffic data for this route if available
        let routeTrafficData = sampleHourlyData.filter { $0.route == route.name }
        let averageTraffic = routeTrafficData.isEmpty ? 3500 : 
            Double(routeTrafficData.map { $0.totalVehicles }.reduce(0, +)) / Double(routeTrafficData.count)
        
        // Create a single traffic segment for the route
        return [TrafficSegment(
            start: coordinates.start,
            end: coordinates.end,
            weight: averageTraffic
        )]
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
