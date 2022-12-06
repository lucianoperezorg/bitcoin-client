//
//  SchedulerTimer.swift
//  Domain
//
//  Created by Luciano Perez on 05/12/2022.
//

import Foundation

public protocol SchedulerTimerType: AnyObject {
    func startObserving(observed: SchedulerTimerDelegate)
    func stopObserving()
    var schedulerTimerDelegate: SchedulerTimerDelegate? { get set }
}

public class SchedulerTimer: SchedulerTimerType {
    private let frecuency: TimeInterval
    private var timer: Timer?
    private let repeats: Bool
    
    weak public var schedulerTimerDelegate: SchedulerTimerDelegate?
    
    public init(frecuency: TimeInterval, repeats: Bool = true) {
        self.frecuency = frecuency
        self.repeats = repeats
    }
    
    private func scheduledTimer() {
        timer = Timer.scheduledTimer(timeInterval: frecuency, target: self, selector: #selector(handlerCalled), userInfo: nil, repeats: repeats)
    }
    
    public func startObserving(observed: SchedulerTimerDelegate) {
        schedulerTimerDelegate = observed
        scheduledTimer()
        handlerCalled()
    }
    
    public func stopObserving() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc private func handlerCalled() {
        schedulerTimerDelegate?.handlerTriggered()
    }
}
