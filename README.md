# METAIN

**Overview**
META is a macOS application built with SwiftUI that leverages a CoreML‑converted YOLOv12 model to detect vehicles in camera or video feeds. It visualizes traffic density as a heatmap on MapKit, presents interactive charts of volume over time, and exports aggregated data as CSV for further analysis.

**Key Features**

- **Vehicle Detection:** Real‑time inference using a YOLOv12 CoreML model (`TrafficModels.swift`).
- **Heatmap Overlay:** Geospatial density overlay on MapKit (`HeatmapSectionView.swift`, `TrafficMapView.swift`).
- **Interactive Charts:** Time‑series and comparison charts via Swift Charts (`ComparisonChartView.swift`, `ComparisonSectionView.swift`, `VehicleCountCardsView.swift`).
- **Raw Data & Export:** View raw detection data and export to CSV (`RawDataView.swift`, SwiftCSV integration).

---

## Project Structure

```text
.
├── LICENSE
├── META
│   ├── Assets.xcassets         # Icons, color sets, logos
│   ├── Components             # Reusable UI (DateFilterWithCalendar.swift, SidebarButton.swift)
│   ├── ContentView.swift      # App entry point
│   ├── Item.swift             # Data model for list items
│   ├── Login/                 # Authentication views
│   ├── METAApp.swift          # @main App struct
│   ├── Models
│   │   └── TrafficModels.swift # CoreML model wrappers
│   ├── RawData
│   │   └── RawDataView.swift   # Table & CSV export UI
│   └── VisualData             # Chart & map views
│       ├── ComparisonChartView.swift
│       ├── ComparisonSectionView.swift
│       ├── HeatmapSectionView.swift
│       ├── TrafficMapView.swift
│       ├── VehicleCountCardsView.swift
│       └── VisualDataView.swift
├── META.xcodeproj
└── README.md
```

---

## Usage

1. **View Heatmap:** Density overlay appears in the Heatmap section.
2. **Explore Charts:** Switch to comparison or summary charts for time‑bucketed counts.
3. **Export CSV:** In Raw Data view, tap “Export” to write `timestamp, latitude, longitude, count` to `~/Documents/META/`.

---

## Architecture

```
CCTV -> Backend -> ML Model -> Redis -> Database <-> Client
```

---

## License

Distributed under the MIT License. See [LICENSE](./LICENSE) for details.
