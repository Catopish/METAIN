//
//  DateFilterWithCalendar.swift
//  META
//
//  Created by Al Amin Dwiesta on 26/07/25.
//
import SwiftUI

struct DateFilterWithCalendar: View {
    @State private var isExpanded = false
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
    @State private var endDate = Date()
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }
    
    var body: some View {
        // Main date range button only
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                isExpanded.toggle()
            }
        }) {
            HStack {
                Text("\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))")
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
        .overlay(alignment: .topLeading) {
            // Overlay calendar popup - positioned absolutely
            if isExpanded {
                VStack(spacing: 0) {
                    // Spacer to push content below the button
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 44) // Height of the button + small gap
                    
                    // Calendar popup content
                    VStack(spacing: 16) {
                        // Header with date labels
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Start Date")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(dateFormatter.string(from: startDate))
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("End Date")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(dateFormatter.string(from: endDate))
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Divider()
                            .padding(.horizontal, 20)
                        
                        // Side-by-side calendars
                        HStack(spacing: 20) {
                            // Start Date Calendar
                            VStack(alignment: .leading, spacing: 8) {
                                Text("From")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 8)
                                
                                DatePicker("",
                                          selection: $startDate,
                                          displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .frame(maxWidth: 280)
                            }
                            
                            // End Date Calendar
                            VStack(alignment: .leading, spacing: 8) {
                                Text("To")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 8)
                                
                                DatePicker("",
                                          selection: $endDate,
                                          displayedComponents: .date)
                                    .datePickerStyle(.graphical)
                                    .frame(maxWidth: 280)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Action buttons
                        HStack {
                            Button("Today") {
                                startDate = Date()
                                endDate = Date()
                            }
                            .buttonStyle(.borderless)
                            
                            Button("Last 7 Days") {
                                endDate = Date()
                                startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate) ?? Date()
                            }
                            .buttonStyle(.borderless)
                            
                            Button("Last 30 Days") {
                                endDate = Date()
                                startDate = Calendar.current.date(byAdding: .day, value: -30, to: endDate) ?? Date()
                            }
                            .buttonStyle(.borderless)
                            
                            Spacer()
                            
                            Button("Clear") {
                                startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
                                endDate = Date()
                            }
                            .buttonStyle(.borderless)
                            
                            Button("Apply") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isExpanded = false
                                }
                                print("Date range applied: \(startDate) to \(endDate)")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(NSColor.windowBackgroundColor))
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)).combined(with: .move(edge: .top)),
                    removal: .opacity.combined(with: .scale(scale: 0.95))
                ))
                .zIndex(10000) // High z-index to ensure it appears above everything
                .allowsHitTesting(true)
            }
        }
        // Background tap to close
        .background(
            isExpanded ?
            Color.clear
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded = false
                    }
                }
                .zIndex(999)
            : nil
        )
    }
}
#Preview(){
    DateFilterWithCalendar()
        .frame(width: 600, height: 700)
}
