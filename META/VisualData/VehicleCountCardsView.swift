import SwiftUI

struct VehicleCountCardsView: View {
    let vehicleData: [VehicleAnalytics]
    let selectedRoute: RouteOption
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Vehicle cards
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
                            
                            // Show percentage for individual route selection
                            if selectedRoute.name != "all-routes" {
                                Text("\(data.percentage, specifier: "%.1f")%")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
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
    }
} 
