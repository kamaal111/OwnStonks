//
//  PerformanceLineChart.swift
//
//
//  Created by Kamaal M Farah on 24/01/2024.
//

import Charts
import SwiftUI
import ForexKit
import KamaalUI
import SharedModels

public struct PerformanceLineChart: View {
    public let data: [Date: Double]
    public let currency: Currencies
    public let initialPrice: Double?

    public init(data: [Date: Double], currency: Currencies, initialPrice: Double?) {
        self.data = data
        self.currency = currency
        self.initialPrice = initialPrice
    }

    public var body: some View {
        VStack {
            if let lastPrice {
                profitView(lastPrice: lastPrice)
            }
            chartsView
        }
        .ktakeWidthEagerly()
    }

    private var chartsView: some View {
        Chart(plots, id: \.id) { plot in
            LineMark(x: plot.xValue, y: plot.yValue)
        }
        .foregroundColor(chartColor)
        .chartXAxis(.hidden)
        .chartYScale(domain: [minPrice, maxPrice])
    }

    private func profitView(lastPrice: Double) -> some View {
        HStack {
            Text(Money(value: lastPrice, currency: currency).localized)
                .foregroundColor(chartColor)
            if let profitPercentage {
                Text("\(profitPercentage.toFixed(2))%")
                    .foregroundColor(.secondary)
                    .font(.callout)
            }
        }
        .ktakeWidthEagerly(alignment: .trailing)
    }

    private var chartColor: Color {
        let plots = plots
        guard let firstClose = initialPrice ?? plots.first?.value else { return .gray }
        guard let lastClose = plots.last?.value else { return .gray }

        if firstClose < lastClose {
            return .green
        }

        if firstClose > lastClose {
            return .red
        }

        return .gray
    }

    private var maxPrice: Double {
        let maxValue = plots.map(\.value).max()
        assert(maxValue != nil)
        return max(maxValue ?? 0, initialPrice ?? 0)
    }

    private var minPrice: Double {
        let minValue = plots.map(\.value).min()
        assert(minValue != nil)
        return min(minValue ?? 0, initialPrice ?? .greatestFiniteMagnitude)
    }

    private var profitPercentage: Double? {
        guard let initialPrice else { return nil }
        guard let lastPrice else {
            assertionFailure("Should have last price at this point")
            return nil
        }

        return ((lastPrice - initialPrice) / lastPrice) * 100
    }

    private var lastPrice: Double? {
        guard let lastPriceDate = data.keys.max() else { return nil }
        return data[lastPriceDate]
    }

    private var plots: [PlotItem] {
        data
            .keys
            .sorted(by: { date1, date2 in date1.compare(date2) == .orderedAscending })
            .enumerated()
            .compactMap { index, date -> PlotItem? in
                guard let close = data[date] else { return nil }
                return PlotItem(id: index, date: date, value: close)
            }
    }
}

private struct PlotItem: Identifiable {
    let id: Int
    let date: Date
    let value: Double

    var xValue: PlottableValue<Int> {
        .value(id.string, id)
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
    PerformanceLineChart(data: [:], currency: .AUD, initialPrice: nil)
}
