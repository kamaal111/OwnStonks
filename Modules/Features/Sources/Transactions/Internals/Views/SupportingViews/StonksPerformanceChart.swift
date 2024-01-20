//
//  StonksPerformanceChart.swift
//
//
//  Created by Kamaal M Farah on 07/01/2024.
//

import Charts
import SwiftUI
import KamaalUI
import SharedModels
import KamaalExtensions

struct StonksPerformanceChart: View {
    let closes: ClosesData
    let purchasedPrice: Double?

    var body: some View {
        VStack {
            if let lastClose = closes.lastClose {
                profitView(lastClose: lastClose)
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
        .chartYScale(domain: [minClose, maxClose])
    }

    private func profitView(lastClose: Double) -> some View {
        HStack {
            Text(Money(value: lastClose, currency: closes.currency).localized)
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
        guard let firstClose = purchasedPrice ?? plots.first?.value else { return .gray }
        guard let lastClose = plots.last?.value else { return .gray }

        if firstClose < lastClose {
            return .green
        }

        if firstClose > lastClose {
            return .red
        }

        return .gray
    }

    private var profitPercentage: Double? {
        guard let purchasedPrice else { return nil }
        guard let lastClose = closes.lastClose else {
            assertionFailure("Should have last close at this point")
            return nil
        }

        return ((lastClose - purchasedPrice) / lastClose) * 100
    }

    private var maxClose: Double {
        let maxValue = plots.map(\.value).max()
        assert(maxValue != nil)
        return max(maxValue ?? 0, purchasedPrice ?? 0)
    }

    private var minClose: Double {
        let minValue = plots.map(\.value).min()
        assert(minValue != nil)
        return min(minValue ?? 0, purchasedPrice ?? .greatestFiniteMagnitude)
    }

    private var plots: [PlotItem] {
        closes.data
            .keys
            .sorted(by: { date1, date2 in date1.compare(date2) == .orderedAscending })
            .enumerated()
            .compactMap { index, date -> PlotItem? in
                guard let close = closes.data[date] else { return nil }
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
    StonksPerformanceChart(closes: ClosesData(currency: .AUD, data: [:]), purchasedPrice: 22)
}
