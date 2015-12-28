//
//  CounterViewController.swift
//  Counter (July 23)
//
//  Created by Developer on 7/24/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class CounterViewController: UIViewController {

    //MARK: - Variables
    
    var previousViewController: TaskViewController?
    var currentTask: NSManagedObject?
    @IBOutlet weak var taskNameTitle: UINavigationItem!
    @IBOutlet weak var taskDurationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var switchMode: SevenSwitch!
    @IBOutlet weak var startPauseButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var taskHourLabel: UILabel!
    
    let countup = Countup()
    let countdown = Countdown()
    var counter: CounterPrototype = Countup()
    var isCountup: Bool { return switchMode.on }
    var updateTextTimer = NSTimer()
    var dataArray: [NSManagedObject] = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext?.executeFetchRequest(NSFetchRequest(entityName: "Task"), error: nil) as? [NSManagedObject])!
    
    let alphaValue: CGFloat = 0.3
    //MARK: - Button Methods
    
    @IBAction func timerPauseOrContinue(sender: AnyObject) {
        switchMode.enabled = false
        switchMode.alpha = alphaValue
        doneButton.enabled = true
        doneButton.alpha = 1.0
        if !counter.timerIsValid {
            counter.timeSet = (Int)(timePicker.countDownDuration) * 100
        }
        
        if !switchMode.on {
            timeLabel.hidden = false
            timePicker.hidden = true
        }
        
        if counter.timerIsCounting() {
            startPauseButton.setTitle("Start", forState: .Normal)
            resetButton.enabled = true
            resetButton.alpha = 1.0
            counter.pauseCounting()
            updateTextTimer.invalidate()
            
            if !switchMode.on {
                var app:UIApplication = UIApplication.sharedApplication()
                for oneEvent in app.scheduledLocalNotifications {
                    var notification = oneEvent as! UILocalNotification
                    let userInfoCurrent = notification.userInfo as! [String:AnyObject]
                    let uid = userInfoCurrent["uid"] as! Int
                    if uid == (previousViewController?.currentTaskIndex)! {
                        //Cancelling local notification
                        app.cancelLocalNotification(notification)
                        //println("Notification Canceled")
                        break;
                    }
                }
            }
        } else {
            startPauseButton.setTitle("Pause", forState: .Normal)
            resetButton.enabled = false
            resetButton.alpha = alphaValue + 0.1
            if counter.timerIsValid {
                counter.continueCounting()
            } else {
                counter.startCounting()
            }
            updateTextTimer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: Selector("updateTimeLabel"), userInfo: nil, repeats: true)
            
            if !switchMode.on {
                
//                var app:UIApplication = UIApplication.sharedApplication()
//                for oneEvent in app.scheduledLocalNotifications {
//                    var notification = oneEvent as! UILocalNotification
//                    let userInfoCurrent = notification.userInfo as! [String:AnyObject]
//                    let uid = userInfoCurrent["uid"] as! Int
//                    if uid == (previousViewController?.currentTaskIndex)! {
//                        //Cancelling local notification
//                        app.cancelLocalNotification(notification)
//                        println("Notification Canceled")
//                        break;
//                    }
//                }
                if (sender as? CounterViewController != self) {
                    //Notification
                    var notification = UILocalNotification()
                    notification.userInfo = ["uid": (previousViewController?.currentTaskIndex)!]
                    notification.category = "categoryTest"
                    notification.alertBody = "Counting Finished"
                    notification.soundName = UILocalNotificationDefaultSoundName
                    notification.fireDate = NSDate(timeIntervalSinceNow: (Double)(counter.timeSet - counter.timeCounted) / 100)
                    notification.timeZone = NSTimeZone.systemTimeZone()
                    UIApplication.sharedApplication().scheduleLocalNotification(notification)
                    //println("Notification Scheduled")
                }
            }
        }
    }
   
    func initializeDatePicker() {
        timePicker.datePickerMode = UIDatePickerMode.CountDownTimer
        timePicker.minuteInterval = 1
        timePicker.countDownDuration = 5
    }

    @IBAction func swichMode(sender: AnyObject) {
        counter.pauseCounting()
        if isCountup {
            timePicker.hidden = true
            timeLabel.hidden = false
            counter = countup
        } else {
            timePicker.hidden = false
            timeLabel.hidden = true
            counter = countdown
            counter.timeSet = dataArray[(previousViewController?.currentTaskIndex)!].valueForKey("taskCountdownTimeSet") as! Int
        }
        counter.resetCounter()
        updateTimeLabel()
    }

    @IBAction func resetCounter(sender: AnyObject) {
        counter.timeCounted = 0
        counter.timerIsValid = false
        updateTimeLabel()
        if !switchMode.on {
            timePicker.hidden = false
            timeLabel.hidden = true
        }
        startPauseButton.setTitle("Start", forState: .Normal)
        resetButton.enabled = true
        resetButton.alpha = 1.0
        counter.pauseCounting()
        updateTextTimer.invalidate()
        switchMode.enabled = true
        switchMode.alpha = 1.0
        doneButton.enabled = false
        doneButton.alpha = alphaValue + 0.2
    }

    @IBAction func finishCounting(sender: AnyObject) {
        
        if !switchMode.on && counter.timeCounted > counter.timeSet {
            counter.timeCounted = counter.timeSet
        }
        self.currentTask?.setValue((self.currentTask?.valueForKey("taskDuration") as! Int) + self.counter.timeCounted, forKey: "taskDuration")
        self.previousViewController?.managedObjectContext?.save(nil)
        counter.timeSet = dataArray[(previousViewController?.currentTaskIndex)!].valueForKey("taskCountdownTimeSet") as! Int
        counter.timeCounted = 0
        updateTextTimer.invalidate()
        resetCounter(self)
        
        var app:UIApplication = UIApplication.sharedApplication()
        for oneEvent in app.scheduledLocalNotifications {
            var notification = oneEvent as! UILocalNotification
            var userInfoCurrent = notification.userInfo as! [String:AnyObject]
            var uid = userInfoCurrent["uid"] as! Int
            if uid == (previousViewController?.currentTaskIndex)! {
                //Cancelling local notification
                app.cancelLocalNotification(notification)
                //println("Notification Canceled")
                break;
            }
        }
    }
 
    //MARK: - Other Methods
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editTask" {
            var destinationViewController = segue.destinationViewController as! TaskEditViewController
            destinationViewController.counterViewController = self
        }
    }

    func updateTimeLabel() {
        if !switchMode.on && counter.timeCounted >= counter.timeSet && counter.timeSet != 0{
            finishCounting(self)
            AudioServicesPlaySystemSound(1022)
        }
        timeLabel.text = counter.timeShowing
        var tempDuration = currentTask!.valueForKey("taskDuration") as? Int
        var durationString = NSString(format: "%.1f", (Double)(tempDuration!) / 360000.0) as String
        taskDurationLabel.text = "\(durationString)"
        
        if dataArray[previousViewController!.currentTaskIndex].valueForKey("taskDuration") as! Int > 360000 {
            taskHourLabel.text = "Hours"
        } else {
            taskHourLabel.text = "Hour"
        }
    }
    
    func quitTime() -> NSTimeInterval {
        return (NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970 - counter.quitDate.timeIntervalSince1970)
    }
    
    //MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetButton.setTitle("Reset", forState: .Normal)
        startPauseButton.setTitle("Start", forState: .Normal)
        initializeDatePicker()
        timePicker.hidden = true
        doneButton.enabled = false
        doneButton.alpha = alphaValue + 0.2
        currentTask = previousViewController?.dataArray[(previousViewController?.currentTaskIndex)!]

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //load data from CoreData
        if dataArray[(previousViewController?.currentTaskIndex)!].valueForKey("taskStarted") != nil {         //if it is not the first time you run the task
            //Other user task preferences
            switchMode.on = dataArray[(previousViewController?.currentTaskIndex)!].valueForKey("taskCountup") as! Bool //Which counter does the user prefer
            swichMode(self)
            
            if dataArray[(previousViewController?.currentTaskIndex)!].valueForKey("taskStarted") as! Bool {   //if the task is in process
                counter.timerIsValid = true
                counter.startDate = dataArray[(previousViewController?.currentTaskIndex)!].valueForKey("taskStartTime") as! NSDate //give the date back
                
                timePicker.hidden = true
                
                if dataArray[(previousViewController?.currentTaskIndex)!].valueForKey("taskCounterIsCounting") as! Bool { //If timer is counting
                    if !switchMode.on {
                        switchMode.enabled = true
                        switchMode.alpha = 1.0
                        startPauseButton.setTitle("Start", forState: .Normal)
                        resetButton.enabled = true
                        resetButton.alpha = 1.0
                    }
                    counter.pauseCounting()
                } else {                                                                                                  //if timer is not counting
                    if !switchMode.on {
                        switchMode.enabled = false
                        switchMode.alpha = alphaValue
                        startPauseButton.setTitle("Pause", forState: .Normal)
                        resetButton.enabled = false
                        resetButton.alpha = alphaValue + 0.1
                    }
                    counter.continueCounting()
                    counter.quitDate = dataArray[(previousViewController?.currentTaskIndex)!].valueForKey("taskQuitTime") as! NSDate
                    counter.startDate = NSDate(timeInterval: quitTime(), sinceDate: counter.startDate)
                    counter.timeCounted = (Int)((NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970 - counter.startDate.timeIntervalSince1970) * 100)
                }
                counter.timeSet = dataArray[(previousViewController?.currentTaskIndex)!].valueForKey("taskCountdownTimeSet") as! Int
                timerPauseOrContinue(self)
                updateTimeLabel()
            }
        }
        taskNameTitle.title = currentTask!.valueForKey("taskName") as? String
        updateTimeLabel()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if !counter.timerIsCounting() && counter.timerIsValid {
            counter.startDate = NSDate(timeInterval: NSDate(timeIntervalSinceNow: 0).timeIntervalSince1970 - counter.stopDate.timeIntervalSince1970, sinceDate: counter.startDate)}
        //save data to CoreData
        dataArray[(previousViewController?.currentTaskIndex)!].setValue(counter.startDate, forKey: "taskStartTime")
        dataArray[(previousViewController?.currentTaskIndex)!].setValue(counter.timerIsValid, forKey: "taskStarted")
        dataArray[(previousViewController?.currentTaskIndex)!].setValue(isCountup, forKey: "taskCountup")
        dataArray[(previousViewController?.currentTaskIndex)!].setValue(counter.timerIsCounting(), forKey: "taskCounterIsCounting")
        dataArray[(previousViewController?.currentTaskIndex)!].setValue(NSDate(timeIntervalSinceNow: 0), forKey: "taskQuitTime")
        dataArray[(previousViewController?.currentTaskIndex)!].setValue(counter.timeSet, forKey: "taskCountdownTimeSet")
        previousViewController?.managedObjectContext?.save(nil)
        updateTextTimer.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
