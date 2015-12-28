//
//  CounterPrototype.swift
//  Counter (iOS 8.4)
//
//  Created by Dev on 15/7/9.
//  Copyright (c) 2015年 Dev. All rights reserved.
//

import Foundation

//MARK: - CounterProtocol Protocol

internal protocol CounterProtocol
{
    var timeShowing: String { get }
    
}

//MARK: - CounterPrototype Class

class CounterPrototype: NSObject
{
    //MARK: - Counter Properties
    
    var startDate: NSDate!
    var quitDate: NSDate!
    var stopDate: NSDate!
    var tag = "Default Tag"
    var recorder = NSTimer()
    var timerIsValid = false
    var timeShowing: String {
        get {
            if hour != 0 {
                return NSString(format: "%.2d:%.2d:%.2d", hour, minute, second) as String
            } else if minute != 0 {
                return NSString(format: "%.2d:%.2d", minute, second) as String
            } else {
                return NSString(format: "%.2d:%.2d", second, millisecond) as String
            }
        }
    }
    var timeSet = 0
    var timeCounted = 0
    var timeDisplay: Int { return timeCounted }
    var millisecond: Int { return timeDisplay % 100 }
    var second: Int { return ((timeDisplay - millisecond) / 100) % 60 }
    var minute: Int { return ((timeDisplay - millisecond - second * 60) / (100 * 60)) % 60 }
    var hour: Int { return (timeDisplay - millisecond - second * 60 - minute * (60 * 60)) / (100 * 60 * 60) }
    
    //MARK: - Counter Methods
    
    func oneCount()
    {
        if counterIsNormal() {
             timeCounted = (Int)((NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970 - startDate.timeIntervalSince1970) * 100)
        } else {
            recorder.invalidate()
        }
    }
    
    func startCounting()
    {
        timerIsValid = true
        startDate = NSDate(timeIntervalSinceNow: 0)
        recorder = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("oneCount"), userInfo: nil, repeats: true)
    }
    
    func pauseCounting()
    {
        stopDate = NSDate(timeIntervalSinceNow: 0)
        recorder.invalidate()
    }
    
    func continueCounting()
    {
        if quitDate != nil {
            startDate = NSDate(timeInterval: NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970 - stopDate.timeIntervalSince1970, sinceDate: startDate)
        }
        recorder = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("oneCount"), userInfo: nil, repeats: true)
    }
    
    func timerIsCounting() -> Bool {
        return recorder.valid
    }
    
    func counterIsNormal() -> Bool {
        return true
    }
    
    /*
    func endCounting()
    {
    //To be implemented
    }*/
    
    func finishCounting() -> Int
    {
        timerIsValid = false
        pauseCounting()
        return timeCounted
    }

    func setTime(time: Int){
        //only used in Countdown
    }
    
    func resetCounter()
    {
        timeCounted = 0
    }
}

//MARK: - CountUp Class

class Countup: CounterPrototype
{
    
}

//MARK: - CountDown Class

class Countdown: CounterPrototype
{
    override var timeSet: Int {
        get { return super.timeSet }
        set { super.timeSet = newValue }
    }
    
    override var timeDisplay: Int { return self.timeSet - super.timeCounted }
    
    override func oneCount()
    {
        if timeCounted > timeSet {
            finishCounting()
        }
        if counterIsNormal() {
            timeCounted = (Int)((NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970 - startDate.timeIntervalSince1970) * 100)
        } else {
            recorder.invalidate()
        }
    }
    
    override func counterIsNormal() -> Bool {
        return timeDisplay > 0
    }
}






