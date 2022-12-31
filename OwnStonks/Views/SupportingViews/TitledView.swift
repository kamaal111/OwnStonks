//
//  TitledView.swift
//  OwnStonks
//
//  Created by Kamaal M Farah on 30/12/2022.
//

import SwiftUI
import SalmonUI

struct TitledView<Content: View>: View {
    let title: String
    let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.accentColor)
                .padding(.bottom, -(AppSizes.extraSmall.rawValue))
                .padding(.top, .extraSmall)
                .ktakeWidthEagerly(alignment: .leading)
            content()
                .ktakeWidthEagerly(alignment: .leading)
                .padding(.leading, -12)
        }
    }
}

struct TitledView_Previews: PreviewProvider {
    static var previews: some View {
        TitledView(title: "Title") {
            Text("Content")
        }
    }
}
