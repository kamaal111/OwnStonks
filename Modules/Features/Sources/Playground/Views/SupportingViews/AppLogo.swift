//
//  AppLogo.swift
//
//
//  Created by Kamaal M Farah on 19/12/2023.
//

import Charts
import SwiftUI
import KamaalUI
import SharedUI

struct AppLogo: View {
    let size: CGFloat
    let curvedCornersSize: CGFloat
    let backgroundColors: [Color]
    let chartColor: Color
    let dollarColor: Color

    var body: some View {
        ZStack {
            gradientBackgroundColor
            dollar
            chart
        }
        .frame(width: size, height: size)
        .cornerRadius(curvedCornersSize)
    }

    private var dollar: some View {
        Image(systemName: "dollarsign.circle")
            .kSize(.squared(size / 2.5))
            .bold()
            .foregroundColor(dollarColor)
            .padding(.top, -(size / 4))
    }

    private var chart: some View {
        Chart {
            ForEach(plots) { plot in
                LineMark(x: plot.xValue, y: plot.yValue)
                    .lineStyle(.init(lineWidth: size / 20))
            }
        }
        .foregroundColor(chartColor)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .opacity(0.7)
    }

    private var gradientBackgroundColor: some View {
        LinearGradient(colors: backgroundColors, startPoint: .top, endPoint: .bottom)
    }
}

private let plots = (0 ..< 9)
    .map { value in
        let yValue: CGFloat =
            if value == 1 { 0.0 }
            else if value % 2 == 0 { 0.1 * CGFloat(value) }
            else { (0.1 * CGFloat(value)) - 0.2 }

        return PlotItem(id: UUID(), point: CGPoint(x: CGFloat(value), y: yValue))
    }

private struct PlotItem: Identifiable {
    let id: UUID
    let point: CGPoint

    var xValue: PlottableValue<Int> {
        .value("X", Int(point.x))
    }

    var yValue: PlottableValue<Double> {
        .value("Y", Double(point.y))
    }
}

#Preview {
    AppLogo(
        size: 150,
        curvedCornersSize: 16,
        backgroundColors: [.red, .yellow],
        chartColor: .green,
        dollarColor: .black
    )
}
