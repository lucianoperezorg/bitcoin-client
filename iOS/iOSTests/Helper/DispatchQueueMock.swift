//
//  DispatchQueueMock.swift
//  iOSTests
//
//  Created by Luciano Perez on 06/12/2022.
//

import Foundation
@testable import iOS

final class DispatchQueueMock: DispatchQueueType {
    func async(execute work: @escaping @convention(block) () -> Void) {
        work()
    }
}
