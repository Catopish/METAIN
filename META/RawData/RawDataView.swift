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
    
    let filterOptions = ["All", "Car", "Bus", "Truck"]
    
    let rawTrafficData = [
        RawTrafficEntry(id: 1, tanggal: "1 July 2025", jam: "00.00 - 01.00", route: "jakarta-pagedangan", mobil: 159, bus: 59, truk: 102),
        RawTrafficEntry(id: 2, tanggal: "1 July 2025", jam: "00.00 - 01.00", route: "bintaro-out", mobil: 80, bus: 84, truk: 99),
        RawTrafficEntry(id: 3, tanggal: "1 July 2025", jam: "00.00 - 01.00", route: "bintaro-in", mobil: 118, bus: 116, truk: 41),
        RawTrafficEntry(id: 4, tanggal: "1 July 2025", jam: "00.00 - 01.00", route: "jakarta-pamulang", mobil: 180, bus: 116, truk: 48),
        RawTrafficEntry(id: 5, tanggal: "1 July 2025", jam: "00.00 - 01.00", route: "jakarta-alam sutera", mobil: 165, bus: 155, truk: 32),
        RawTrafficEntry(id: 6, tanggal: "1 July 2025", jam: "00.00 - 01.00", route: "pagedangan-alam sutera", mobil: 175, bus: 37, truk: 179),
        RawTrafficEntry(id: 7, tanggal: "1 July 2025", jam: "00.00 - 01.00", route: "pagedangan-pamulang", mobil: 102, bus: 48, truk: 32),
        RawTrafficEntry(id: 8, tanggal: "1 July 2025", jam: "00.00 - 01.00", route: "pamulang-pagedangan", mobil: 147, bus: 134, truk: 47),
        RawTrafficEntry(id: 9, tanggal: "1 July 2025", jam: "00.00 - 01.00", route: "pamulang-jakarta", mobil: 83, bus: 49, truk: 41),
        RawTrafficEntry(id: 10, tanggal: "1 July 2025", jam: "00.00 - 01.00", route: "alam sutera-jakarta", mobil: 142, bus: 130, truk: 40),
        RawTrafficEntry(id: 11, tanggal: "1 July 2025", jam: "00.00 - 01.00", route: "alam sutera-pagedangan", mobil: 84, bus: 80, truk: 33),
        RawTrafficEntry(id: 12, tanggal: "1 July 2025", jam: "01.00 - 02.00", route: "jakarta-pagedangan", mobil: 82, bus: 48, truk: 47),
        RawTrafficEntry(id: 13, tanggal: "1 July 2025", jam: "01.00 - 02.00", route: "bintaro-out", mobil: 170, bus: 112, truk: 47),
        RawTrafficEntry(id: 14, tanggal: "1 July 2025", jam: "01.00 - 02.00", route: "bintaro-in", mobil: 118, bus: 49, truk: 46)
    ]
    
    var filteredData: [RawTrafficEntry] {
        rawTrafficData.filter { entry in
            searchText.isEmpty ||
            entry.route.localizedCaseInsensitiveContains(searchText) ||
            entry.tanggal.localizedCaseInsensitiveContains(searchText) ||
            entry.jam.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var totalVehicles: (mobil: Int, bus: Int, truk: Int) {
        let totals = filteredData.reduce((mobil: 0, bus: 0, truk: 0)) { result, entry in
            (mobil: result.mobil + entry.mobil,
             bus: result.bus + entry.bus,
             truk: result.truk + entry.truk)
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
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CSV file")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("ColorBluePrimary"))
                    
                    DateFilterWithCalendar()
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
        .background(Color.white)
    }
    
    private var dataTable: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Table Header
            HStack(spacing: 0) {
                Text("Tanggal")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("ColorGrayPrimary"))
                    .frame(width: 120, alignment: .leading)
                    .padding(.leading, 24)
                
                Text("Jam")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("ColorGrayPrimary"))
                    .frame(width: 120, alignment: .leading)
                
                Text("Rute")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("ColorGrayPrimary"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Mobil")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("ColorGrayPrimary"))
                    .frame(width: 80, alignment: .center)
                
                Text("Bus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("ColorGrayPrimary"))
                    .frame(width: 80, alignment: .center)
                
                Text("Truk")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color("ColorGrayPrimary"))
                    .frame(width: 80, alignment: .center)
                    .padding(.trailing, 24)
            }
            .padding(.vertical, 16)
            .background(Color("ColorGraySecondary").opacity(0.3))
            
            // Table Rows
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredData, id: \.id) { entry in
                        HStack(spacing: 0) {
                            Text(entry.tanggal)
                                .font(.system(size: 14))
                                .foregroundColor(Color("ColorBluePrimary"))
                                .frame(width: 120, alignment: .leading)
                                .padding(.leading, 24)
                            
                            Text(entry.jam)
                                .font(.system(size: 14))
                                .foregroundColor(Color("ColorBluePrimary"))
                                .frame(width: 120, alignment: .leading)
                            
                            Text(entry.route)
                                .font(.system(size: 14))
                                .foregroundColor(Color("ColorBluePrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text("\(entry.mobil)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("ColorBluePrimary"))
                                .frame(width: 80, alignment: .center)
                            
                            Text("\(entry.bus)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("ColorBlueSecondary"))
                                .frame(width: 80, alignment: .center)
                            
                            Text("\(entry.truk)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("ColorGrayPrimary"))
                                .frame(width: 80, alignment: .center)
                                .padding(.trailing, 24)
                        }
                        .padding(.vertical, 12)
                        .background(
                            entry.id % 2 == 0 ?
                            Color("ColorGraySecondary").opacity(0.05) :
                            Color.white
                        )
                        
                        if entry.id != filteredData.last?.id {
                            Divider()
                                .background(Color("ColorGraySecondary").opacity(0.3))
                        }
                    }
                }
            }
            .background(Color.white)
        }
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
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
            csvString += "\(entry.tanggal),\(entry.jam),\(route),\(entry.mobil),\(entry.bus),\(entry.truk)\n"
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

// MARK: - Data Model
struct RawTrafficEntry {
    let id: Int
    let tanggal: String
    let jam: String
    let route: String
    let mobil: Int
    let bus: Int
    let truk: Int
}


#Preview {
    RawDataView()
        .frame(width: 1200, height: 700)
}
