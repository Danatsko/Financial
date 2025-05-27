//
//  StatisticsCharts.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI
import Charts

struct StatisticsCharts: View {
    var data: [String: Double]
    @Binding var typePeriod: PeriodEnum


    private var isDailyView: Bool { typePeriod == .day }

    private var chartPoints: [ChartDataPoint] {
        data
            .compactMap { key, value in
                ChartDataPoint(key: key, value: value, parser: robustStringToDate)
            }
            .sorted { $0.originalKey < $1.originalKey }
    }

    private var yAxisDomain: ClosedRange<Double> {
        let allValues = chartPoints.map { $0.value }
        let maxValue = allValues.max() ?? 0
        let minUpperBound: Double = max(1000, maxValue * 0.1)
        let upperBound = max(maxValue * 1.1, minUpperBound)
        let lowerBound: Double = 0
        guard upperBound > lowerBound else { return lowerBound...(lowerBound + minUpperBound) }
        return lowerBound...upperBound
    }

    var body: some View {
        VStack(alignment: .leading) {
            
            if chartPoints.isEmpty {
                Text("Not found data for display.")
                    .foregroundColor(.secondary)
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(chartPoints) { point in
                        if let date = point.date {
                            if isDailyView {
                                let hour = Calendar.current.component(.hour, from: date)
                                AreaMark(
                                    x: .value("Hour", hour),
                                    y: .value("Value", point.value)
                                )
                                .foregroundStyle(Color.cyan.opacity(0.3))
                                .interpolationMethod(.catmullRom)

                                LineMark(
                                    x: .value("Hour", hour),
                                    y: .value("Value", point.value)
                                )
                                .foregroundStyle(Color.cyan)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                .interpolationMethod(.catmullRom)

                                PointMark(
                                    x: .value("Hour", hour),
                                    y: .value("Value", point.value)
                                )
                                .foregroundStyle(Color.orange)
                                .symbolSize(point.value > 0 ? 50 : 0)

                            } else {
                                AreaMark(
                                    x: .value("Date", date, unit: .day),
                                    y: .value("Value", point.value)
                                )
                                .foregroundStyle(Color.cyan.opacity(0.3))
                                .interpolationMethod(.catmullRom)

                                LineMark(
                                    x: .value("Date", date, unit: .day),
                                    y: .value("Value", point.value)
                                )
                                .foregroundStyle(Color.cyan)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                                .interpolationMethod(.catmullRom)

                                PointMark(
                                    x: .value("Date", date, unit: .day),
                                    y: .value("Value", point.value)
                                )
                                .foregroundStyle(Color.orange)
                                .symbolSize(point.value > 0 ? 50 : 0)
                            }
                        } else {
                             let _ = print("⚠️ StatisticsCharts: Could not decrypt the date for the key \(point.originalKey)")
                        }
                    }
                }
                .chartXAxis {
                    if isDailyView {
                        AxisMarks(values: .stride(by: 3)) { value in
                            AxisGridLine()
                            AxisTick()
                            if let hour = value.as(Int.self) {
                                AxisValueLabel("\(hour):00")
                            }
                        }
                    } else {
                        AxisMarks(values: .automatic()) { value in
                            AxisGridLine()
                            AxisTick()
                            if value.as(Date.self) != nil {
                                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                         AxisGridLine()
                         AxisTick()
                         if let doubleValue = value.as(Double.self) {
                              AxisValueLabel(String(format: "%.0f", doubleValue))
                         }
                    }
                }
                .chartYScale(domain: yAxisDomain)
                .frame(height: 300)
                .padding([.horizontal, .bottom])
            }
        }
        .padding(.top)
    }

    private func robustStringToDate(_ string: String) -> Date? {
        let isoFormatterWithFractions = ISO8601DateFormatter()
        isoFormatterWithFractions.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatterWithFractions.date(from: string) { return date }
        
        let isoFormatterWithoutFractions = ISO8601DateFormatter()
        isoFormatterWithoutFractions.formatOptions = [.withInternetDateTime]
        if let date = isoFormatterWithoutFractions.date(from: string) { return date }
        
        return nil
    }
    
    
}


struct ChartDataPoint: Identifiable {
    let id: String
    let date: Date?
    let value: Double
    let originalKey: String

    init?(key: String, value: Double, parser: (String) -> Date?) {
        self.id = key
        self.originalKey = key
        self.date = parser(key)
        self.value = value
    }
}
