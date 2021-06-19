//
//  LoadingView.swift
//  
//
//  Created by Kamaal M Farah on 19/06/2021.
//

import SwiftUI
import SalmonUI

public struct LoadingView: View {
    @Binding public var isLoading: Bool

    public init(isLoading: Binding<Bool>) {
        self._isLoading = isLoading
    }

    public var body: some View {
        #if canImport(UIKit)
        KActivityIndicator(isAnimating: $isLoading, style: .medium)
        #else
        KActivityIndicator(isAnimating: $isLoading, style: .spinning)
        #endif
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(isLoading: .constant(true))
    }
}
