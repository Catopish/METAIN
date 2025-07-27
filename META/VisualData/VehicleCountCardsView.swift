import SwiftUI

struct VehicleCountCardsView: View {
    let vehicleData: [VehicleAnalytics]
    
    var body: some View {
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
} 
