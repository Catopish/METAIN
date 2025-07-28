import SwiftUI

struct VehicleCountCardsView: View {
    let vehicleData: [VehicleAnalytics]
    let selectedRoute: RouteOption
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Vehicle cards
            HStack(spacing: 20) {
                ForEach(vehicleData, id: \.type) { data in
                    HStack(spacing: 16) {
                        // Icon on the left
                        Image(data.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                        
                        // Text information on the right
                        VStack(alignment: .leading, spacing: 4) {
                            Text(data.type)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("ColorBluePrimary"))
                            
                            Text("\(Int(data.count).formatted())")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color("ColorBluePrimary")) // Use consistent color for all
                            
                            // Show percentage
                            Text("\(data.percentage, specifier: "%.1f")% from total vehicles")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                            
                        }
                        
                        Spacer()
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
