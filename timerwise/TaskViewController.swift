//
//  TaskViewController.swift
//  Counter (July 23)
//
//  Created by Developer on 7/23/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

import UIKit
import CoreData

class TaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var statsButton: UIBarButtonItem!
    
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext
    var currentTaskIndex = 0
    var dataArray: [NSManagedObject] = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext?.executeFetchRequest(NSFetchRequest(entityName: "Task"), error: nil) as? [NSManagedObject])!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTableView.delegate = self
        taskTableView.dataSource = self
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 105 / 255, green: 215 / 255, blue: 200 / 255, alpha: 1.00)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        self.navigationController?.navigationBar.translucent = false
        // Do any additional setup after loading the view.
        //screenShotTest()
    }
    
    func screenShotTest() {
        addNewTaskWithTime("Study", hourTime: 16.3, started: false)
        addNewTaskWithTime("Workout", hourTime: 11.2, started: false)
        addNewTaskWithTime("Homework", hourTime: 14.1, started: false)
        addNewTaskWithTime("Nap", hourTime: 6.5, started: false)
        addNewTaskWithTime("Party", hourTime: 5.7, started: false)
        addNewTaskWithTime("Gaming", hourTime: 6.2, started: false)
        refresh()
    }

    func addNewTaskWithTime(name: String, hourTime: Double, started: Bool) {
        var exactTime = hourTime * 360000
        var entity = NSEntityDescription.entityForName("Task", inManagedObjectContext: managedObjectContext!)
        var newObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext!)
        managedObjectContext!.save(nil)
        refresh()
        dataArray[dataArray.count - 1].setValue(name, forKey: "taskName")
        dataArray[dataArray.count - 1].setValue(exactTime, forKey: "taskDuration")
        //dataArray[dataArray.count - 1].setValue(started, forKey: "taskStarted")
        managedObjectContext!.save(nil)
        refresh()
        currentTaskIndex = dataArray.count - 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
        taskTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let normalCell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath) as! TaskTableViewCell
        normalCell.taskNameLabel.text = (dataArray[indexPath.row]).valueForKey("taskName") as? String
        var duration: AnyObject? = dataArray[indexPath.row].valueForKey("taskDuration")
        var durationString = NSString(format: "%.1f", (Double)(duration! as! Int) / 360000.0) as String
        normalCell.taskDurationLabel.text = "\(durationString)"
        normalCell.selectedBackgroundView = UIView(frame: normalCell.frame)
        normalCell.selectedBackgroundView.backgroundColor = UIColor(red: 150 / 255, green: 205 / 255, blue: 200 / 255, alpha: 0.50)
        if dataArray[indexPath.row].valueForKey("taskDuration") != nil {
            if dataArray[indexPath.row].valueForKey("taskDuration") as! Int > 360000 {
                normalCell.hourLabel.text = "Hours"
            } else {
                normalCell.hourLabel.text = "Hour"
            }
        } else {
            normalCell.hourLabel.text = "Hour"
        }
        if dataArray[indexPath.row].valueForKey("taskStarted") != nil {
            if dataArray[indexPath.row].valueForKey("taskStarted") as! Bool {
                normalCell.smallDot.image = UIImage(named: "smallGreenDots@2x.png")
            } else {
                normalCell.smallDot.image = UIImage(named: "smallGrayDots@2x.png")
            }
        } else {
            normalCell.smallDot.image = UIImage(named: "smallGrayDots@2x.png")
        }
        return normalCell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            managedObjectContext?.deleteObject(dataArray[indexPath.row])
            managedObjectContext?.save(nil)
            refresh()
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func swapTable(index1: Int, index2: Int) {
        var name: AnyObject? = dataArray[index1].valueForKey("taskName")
        var duration: AnyObject? = dataArray[index1].valueForKey("taskDuration")
        dataArray[index1].setValue(dataArray[index2].valueForKey("taskName"), forKey: "taskName")
        dataArray[index1].setValue(dataArray[index2].valueForKey("taskDuration"), forKey: "taskDuration")
        dataArray[index2].setValue(name, forKey: "taskName")
        dataArray[index2].setValue(duration, forKey: "taskDuration")
    }
    
    func tableMove(fromIndex: Int, toIndex: Int, swapTable: (Int, Int) -> Void) {
        var count = toIndex - fromIndex
        var movement = toIndex
        var indecrement = count > 0 ? -1 : 1
        var i = 0
        if abs(fromIndex - movement) > 0 {
            for (i = 0; i < abs(count); i++) {
                swapTable(fromIndex, movement)
                movement += indecrement
            }
        }
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        tableMove(fromIndexPath.row, toIndex: toIndexPath.row, swapTable: swapTable)
        managedObjectContext?.save(nil)
        refresh()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row >= dataArray.count {
            performSegueWithIdentifier("addNewTask", sender: self)
        } else {
            currentTaskIndex = (tableView.indexPathForSelectedRow()?.row)!
            performSegueWithIdentifier("goToCurrentTask", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row >= dataArray.count {
            return false
        } else {
            return true
        }
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row >= dataArray.count {
            return false
        } else {
            return true
        }
    }
    
    
    @IBAction func addNewTask(sender: AnyObject) {
        performSegueWithIdentifier("addNewTask", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addNewTask" {
            var destinationViewController = segue.destinationViewController as? NewTaskViewController
            destinationViewController?.taskViewController = self
            var entity = NSEntityDescription.entityForName("Task", inManagedObjectContext: managedObjectContext!)
            var newObject = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedObjectContext!)
            managedObjectContext!.save(nil)
            refresh()
            dataArray[dataArray.count - 1].setValue("New Task", forKey: "taskName")
            dataArray[dataArray.count - 1].setValue(0, forKey: "taskDuration")
            managedObjectContext!.save(nil)
            refresh()
            currentTaskIndex = dataArray.count - 1
        } else {
            var destinationViewController = segue.destinationViewController as? CounterViewController
            destinationViewController?.previousViewController = self
        }
    }
    

    @IBAction func enterEditMode(sender: AnyObject) {
        taskTableView.setEditing(!taskTableView.editing, animated: true)
        if taskTableView.editing {
            editButton.title = "Done"
            statsButton.enabled = false
        } else {
            editButton.title = "Edit"
            statsButton.enabled = true
        }
    }
    
    func refresh() {
        dataArray = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext?.executeFetchRequest(NSFetchRequest(entityName: "Task"), error: nil) as? [NSManagedObject])!
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
