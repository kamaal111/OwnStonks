//
//  TestCacheStorage.swift
//
//
//  Created by Kamaal M Farah on 12/01/2024.
//

import StonksKit
import Foundation

final class TestCacheStorage: StonksKitCacheStorable {
    var closesCache: [Date: [String: StonksTickersClosesResponse]]?
    var infoCache: [Date: [String: StonksTickersInfoResponse]]?
}
