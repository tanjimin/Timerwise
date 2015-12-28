//
//  TaskEditViewController.swift
//  Counter (July 23)
//
//  Created by Developer on 7/27/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

import UIKit
import CoreData

class TaskEditViewController: UIViewController, UITextFieldDelegate {
    
    var dataArray: [NSManagedObject] = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext?.executeFetchRequest(NSFetchRequest(entityName: "Task"), error: nil) as? [NSManagedObject])!
    
    func refresh() {
        dataArray = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext?.executeFetchRequest(NSFetchRequest(entityName: "Task"), error: nil) as? [NSManagedObject])!
    }
    
    @IBOutlet weak var taskNameTextField: UITextField!
    var counterViewController: CounterViewController?
    var taskViewController: TaskViewController?
    var index: Int!
    
    @IBAction func doneAction(sender: AnyObject) {
        dataArray[index].setValue(taskNameTextField.text, forKey: "taskName")
        if counterViewController != nil {
            counterViewController!.previousViewController?.managedObjectContext?.save(nil)
        } else {
            taskViewController!.managedObjectContext?.save(nil)
        }
        taskNameTextField.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        taskViewController?.managedObjectContext?.deleteObject(dataArray[(taskViewController?.currentTaskIndex)!])
        taskViewController?.managedObjectContext?.save(nil)
        taskNameTextField.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        if counterViewController != nil {
            index = counterViewController?.previousViewController?.currentTaskIndex
        } else {
            index = taskViewController?.currentTaskIndex
        }
        taskNameTextField.delegate = self
        taskNameTextField.text = dataArray[index].valueForKey("taskName") as! String
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        taskNameTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
