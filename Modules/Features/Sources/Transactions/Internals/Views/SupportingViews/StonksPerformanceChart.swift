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
        let sortedCloseDates = sortedCloseDates
        guard sortedCloseDates.count > 1 else { return .green }

        let lastClose = closes.data[sortedCloseDates.last!]!
        let firstClose = if let purchasedPrice { purchasedPrice } else { closes.data[sortedCloseDates[0]]! }
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
        assert(closes.highestClose != nil)
        let highestClose = closes.highestClose ?? 0
        if let purchasedPrice {
            return max(highestClose, purchasedPrice)
        }
        return highestClose
    }

    private var minClose: Double {
        assert(closes.lowestClose != nil)
        let lowestClose = closes.lowestClose ?? .greatestFiniteMagnitude
        if let purchasedPrice {
            return min(lowestClose, purchasedPrice)
        }
        return lowestClose
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
