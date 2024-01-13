//
//  StonksPerformanceChart.swift
//
//
//  Created by Kamaal M Farah on 07/01/2024.
//

import Charts
import SwiftUI
import KamaalUI
import KamaalExtensions

struct StonksPerformanceChart: View {
    let closes: ClosesData
    let purchasedPrice: Double?

    var body: some View {
        Chart {
            ForEach(plots) { plot in
                LineMark(x: plot.xValue, y: plot.yValue)
            }
        }
        .foregroundColor(chartColor)
        .chartXAxis(.hidden)
        .ktakeWidthEagerly()
    }

    private var chartColor: Color {
        let sortedCloseDates = sortedCloseDates
        guard sortedCloseDates.count > 1 else { return .green }

        let lastClose = closes.data[sortedCloseDates.last!]!
        let firstClose = if let purchasedPrice { purchasedPrice } else { closes.data[sortedCloseDates[0]]! }
        if firstClose < lastClose {
            return .green
        }

        return .red
    }

    private var plots: [PlotItem] {
        sortedCloseDates
            .compactMap { date in
                guard let close = closes.data[date] else { return nil }

                return PlotItem(id: date, value: close)
            }
    }

    private var sortedCloseDates: [Date] {
        closes.data
            .keys
            .sorted(by: { date1, date2 in date1.compare(date2) == .orderedAscending })
    }
}

private struct PlotItem: Identifiable {
    let id: Date
    let value: Double

    var xValue: PlottableValue<String> {
        .value(Self.dateFormatter.string(from: id), "\(id.dayNumberOfWeek)")
    }

    var yValue: PlottableValue<Double> {
        .value("Y", value)
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}

#Preview {
    StonksPerformanceChart(closes: ClosesData(currency: .AUD, data: [:]), purchasedPrice: 22)
}
