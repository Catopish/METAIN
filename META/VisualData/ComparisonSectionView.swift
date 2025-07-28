import SwiftUI

struct ComparisonSectionView: View {
    @Binding var selectedYear: Int
    @Binding var selectedMonth: String
    @Binding var selectedRoutes: Set<RouteOption>
    
    let years = Array(2015...2025)
    let months = ["All Months", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let monthlyData: [MonthlyVehicleData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Comparison Of Vehicle Volumes")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color("ColorBluePrimary"))
            
            HStack(spacing: 16) {
                // Year Dropdown - with calendar icon
                Menu {
                    ForEach(years, id: \.self) { year in
                        Button("\(year)") {
                            selectedYear = year
                        }
                    }
                } label: {
                    HStack {
                        Text("\(selectedYear)")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(NSColor.controlBackgroundColor))
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 100)
                
                // Month Dropdown - with clock icon
                Menu {
                    ForEach(months, id: \.self) { month in
                        Button(month) {
                            selectedMonth = month
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedMonth)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(NSColor.controlBackgroundColor))
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 140)
                
                // Route Multi-Select Dropdown - with route icon
                Menu {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(RouteOption.allRoutes) { route in
                            Button(action: {
                                if selectedRoutes.contains(route) {
                                    selectedRoutes.remove(route)
                                } else {
                                    selectedRoutes.insert(route)
                                }
                            }) {
                                HStack {
                                    Image(systemName: selectedRoutes.contains(route) ? "checkmark.square.fill" : "square")
                                        .foregroundColor(selectedRoutes.contains(route) ? Color("ColorBluePrimary") : Color("ColorGrayPrimary"))
                                    
                                    Text(route.displayName)
                                        .foregroundColor(Color("ColorBluePrimary"))
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } label: {
                    HStack {
                        Text("Route (\(selectedRoutes.count))")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "road.lanes")
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(NSColor.controlBackgroundColor))
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 140)
                
                Spacer()
            }
            
            // Chart
            ComparisonChartView(selectedRoutes: selectedRoutes, monthlyData: monthlyData)
            
            // Legend - Dynamic based on selected routes
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(selectedRoutes), id: \.id) { route in
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(TrafficDataService.colorForRoute(route))
                            .frame(width: 16, height: 3)
                            .cornerRadius(1.5)
                        Text(route.displayName)
                            .font(.system(size: 14))
                            .foregroundColor(Color("ColorBluePrimary"))
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
} 
