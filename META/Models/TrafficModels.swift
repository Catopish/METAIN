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
              weight: 50),
        .init(start: CLLocationCoordinate2D(latitude: -6.30617, longitude: 106.64455),
              end:   CLLocationCoordinate2D(latitude: -6.30397, longitude: 106.65769),
              weight: 150),
        .init(start: CLLocationCoordinate2D(latitude: -6.30397, longitude: 106.65769),
              end:   CLLocationCoordinate2D(latitude: -6.30293, longitude: 106.66266),
              weight: 300)
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
    
    // Helper function to get color for route
    static func colorForRoute(_ route: RouteOption) -> Color {
        let colors = [
            Color("ColorBluePrimary"),
            Color("ColorBlueSecondary"),
            Color("ColorGrayPrimary"),
            Color("ColorRedPrimary"),
            Color("ColorRedSecondary")
        ]
        let index = RouteOption.allRoutes.firstIndex(of: route) ?? 0
        return colors[index % colors.count]
    }
} 
