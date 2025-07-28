//
//  RawDataView.swift
//  META
//
//  Created by Al Amin Dwiesta on 22/07/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct RawDataView: View {
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var showingExporter = false
    @State private var csvDocument: CSVDocument?
    
    // Date range state for filtering
    @State private var startDate = Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
    @State private var endDate = Date()
    
    let filterOptions = ["All", "Car", "Bus", "Truck"]
    
    // Callback for when date range changes
    private func onDateRangeChanged() {
        // This could be used to filter data by date range in the future
        // For now, we'll keep the existing filtering behavior
    }
    
    var filteredData: [HourlyTrafficData] {
        TrafficDataService.getRawData().filter { entry in
            searchText.isEmpty ||
            entry.route.localizedCaseInsensitiveContains(searchText) ||
            entry.date.localizedCaseInsensitiveContains(searchText) ||
            entry.timeRange.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var totalVehicles: (mobil: Int, bus: Int, truk: Int) {
        let totals = filteredData.reduce((mobil: 0, bus: 0, truk: 0)) { result, entry in
            (mobil: result.mobil + entry.carCount,
             bus: result.bus + entry.busCount,
             truk: result.truk + entry.truckCount)
        }
        return totals
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Controls Section
            controlsSection
                .zIndex(2)
            
            // Data Table
            dataTable
                .zIndex(1)
        }
        .background(Color("ColorGraySecondary"))
        .preferredColorScheme(.light)
        .fileExporter(
            isPresented: $showingExporter,
            document: csvDocument,
            contentType: .commaSeparatedText,
            defaultFilename: "traffic_data_\(Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-"))"
        ) { result in
            switch result {
            case .success(let url):
                print("CSV exported successfully to: \(url)")
            case .failure(let error):
                print("Export failed: \(error.localizedDescription)")
            }
            csvDocument = nil
        }
    }
    
    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Traffic Logs")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color("ColorBluePrimary"))
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CSV file")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("ColorBluePrimary"))
                    
                    DateFilterWithCalendar(startDate: $startDate, endDate: $endDate, onDateRangeChanged: onDateRangeChanged)
                        .frame(width: 250, height: 30)
                }
                
                Spacer()
                
                
                // Export Button
                Button(action: {
                    exportToCSV()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14))
                        Text("Export")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color("ColorBluePrimary"))
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            

        }
        .padding(24)
        .background(Color("ColorGraySecondary"))
//        .background(Color.white)
    }
    
    private var dataTable: some View {
        VStack(spacing: 0) {
            // Unified table with header and body
            VStack(spacing: 0) {
                // Table Header
                HStack(spacing: 0) {
                    Text("Tanggal")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color("ColorGrayPrimary"))
                        .frame(width: 120, alignment: .leading)
                        .padding(.leading, 24)
                    
                    Text("Jam")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color("ColorGrayPrimary"))
                        .frame(width: 120, alignment: .leading)
                    
                    Text("Rute")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color("ColorGrayPrimary"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Mobil")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color("ColorGrayPrimary"))
                        .frame(width: 80, alignment: .center)
                    
                    Text("Bus")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color("ColorGrayPrimary"))
                        .frame(width: 80, alignment: .center)
                    
                    Text("Truk")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color("ColorGrayPrimary"))
                        .frame(width: 80, alignment: .center)
                        .padding(.trailing, 24)
                }
                .padding(.vertical, 16)
                .background(Color("ColorGraySecondary").opacity(0.3))
                
                // Table Body
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(filteredData.enumerated()), id: \.element.id) { index, entry in
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Text(entry.date)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("ColorBluePrimary"))
                                        .frame(width: 120, alignment: .leading)
                                        .padding(.leading, 24)
                                    
                                    Text(entry.timeRange)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("ColorBluePrimary"))
                                        .frame(width: 120, alignment: .leading)
                                    
                                    Text(entry.route)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("ColorBluePrimary"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("\(entry.carCount)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color("ColorBluePrimary"))
                                        .frame(width: 80, alignment: .center)
                                    
                                    Text("\(entry.busCount)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color("ColorBlueSecondary"))
                                        .frame(width: 80, alignment: .center)
                                    
                                    Text("\(entry.truckCount)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color("ColorGrayPrimary"))
                                        .frame(width: 80, alignment: .center)
                                        .padding(.trailing, 24)
                                }
                                .padding(.vertical, 12)
                                .background(
                                    index % 2 == 0 ?
                                    Color("ColorGraySecondary").opacity(0.05) :
                                    Color.white
                                )
                                
                                if index < filteredData.count - 1 {
                                    Divider()
                                        .background(Color("ColorGraySecondary").opacity(0.3))
                                }
                            }
                        }
                    }
                }
                .background(Color.white)
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(24)
    }
    
    // MARK: - Export Functions
    private func exportToCSV() {
        let csvString = generateCSV()
        csvDocument = CSVDocument(text: csvString)
        showingExporter = true
    }
    
    private func generateCSV() -> String {
        var csvString = "Tanggal,Jam,Rute,Mobil,Bus,Truk\n"
        
        for entry in filteredData {
            // Escape commas in route names if needed
            let route = entry.route.contains(",") ? "\"\(entry.route)\"" : entry.route
            csvString += "\(entry.date),\(entry.timeRange),\(route),\(entry.carCount),\(entry.busCount),\(entry.truckCount)\n"
        }
        
        // Add summary row
        csvString += "\nTotal,,,\(totalVehicles.mobil),\(totalVehicles.bus),\(totalVehicles.truk)\n"
        
        return csvString
    }
}

// MARK: - CSV Document
struct CSVDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.commaSeparatedText] }
    
    var text: String
    
    init(text: String) {
        self.text = text
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}

#Preview {
    RawDataView()
        .frame(width: 1200, height: 700)
}
