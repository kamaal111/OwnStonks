//
//  StonksPerformanceChart.swift
//
//
//  Created by Kamaal M Farah on 07/01/2024.
//

import SwiftUI

struct StonksPerformanceChart: View {
    let closes: [Date: Double]

    var body: some View {
        Text("Hello, World!")
            .onAppear(perform: {
                print("🐸🐸🐸 closes", closes)
            })
    }
}

#Preview {
    StonksPerformanceChart(closes: [:])
}
