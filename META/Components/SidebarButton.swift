//
//  SidebarButton.swift
//  META
//
//  Created by Al Amin Dwiesta on 22/07/25.
//

import SwiftUI

struct SidebarButton: View {
    let title: String
    let systemIcon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 232, height: 56)
                    .background(isSelected ? Color("ColorGraySecondary") : Color.clear)
                    .cornerRadius(30)
                    .offset(x: 0, y: 0)
                    .shadow(
                        color: isSelected ? Color(red: 0, green: 0, blue: 0, opacity: 0.25) : Color.clear,
                        radius: isSelected ? 4 : 0,
                        y: isSelected ? 4 : 0
                    )
                
                // Icon background
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 30, height: 30)
                    .cornerRadius(15)
                    .offset(x: -86, y: 0)
                    .overlay(
                        Image(systemName: systemIcon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("ColorBluePrimary"))
                            .offset(x: -86, y: 0)
                    )
                
                // Title
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("ColorBluePrimary"))
                    .offset(x: -20, y: 0)
            }
            .frame(width: 232, height: 56)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 12) {
        SidebarButton(
            title: "Dashboard",
            systemIcon: "speedometer",
            isSelected: true
        ) { }
        
        SidebarButton(
            title: "Heatmap",
            systemIcon: "square.grid.3x3.fill",
            isSelected: false
        ) { }
        
        SidebarButton(
            title: "Analytics",
            systemIcon: "chart.bar",
            isSelected: false
        ) { }
    }
    .padding()
    .background(Color("ColorGraySecondary"))
} 
