//
//  NewTaskViewController.swift
//  Counter (July 23)
//
//  Created by Developer on 8/11/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

import UIKit
import CoreData

class NewTaskViewController: UIViewController, UITextFieldDelegate {

    var dataArray: [NSManagedObject] = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext?.executeFetchRequest(NSFetchRequest(entityName: "Task"), error: nil) as? [NSManagedObject])!
    
    func refresh() {
        dataArray = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext?.executeFetchRequest(NSFetchRequest(entityName: "Task"), error: nil) as? [NSManagedObject])!
    }
    
    @IBOutlet weak var taskNameTextField: UITextField!

    var taskViewController: TaskViewController?
    var index: Int!
    
    @IBAction func doneAction(sender: AnyObject) {
        dataArray[index].setValue(taskNameTextField.text, forKey: "taskName")
        taskViewController!.managedObjectContext?.save(nil)
        taskNameTextField.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        taskViewController?.managedObjectContext?.deleteObject(dataArray[(taskViewController?.currentTaskIndex)!])
        taskViewController?.managedObjectContext?.save(nil)
        taskNameTextField.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        doneAction(self)
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        index = taskViewController?.currentTaskIndex
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
