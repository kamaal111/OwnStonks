//
//  AppLogo.swift
//
//
//  Created by Kamaal M Farah on 19/12/2023.
//

import SwiftUI

struct AppLogo: View {
    let size: CGFloat
    let curvedCornersSize: CGFloat
    let backgroundColor: Color

    var body: some View {
        ZStack {
            backgroundColor
            Text("Hello, World!")
        }
        .frame(width: size, height: size)
        .cornerRadius(curvedCornersSize)
    }
}

#Preview {
    AppLogo(size: 150, curvedCornersSize: 16, backgroundColor: .red)
}
