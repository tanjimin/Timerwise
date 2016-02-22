//
//  StatsViewController.swift
//  Counter (July 23)
//
//  Created by Developer on 7/27/15.
//  Copyright (c) 2015 Developer. All rights reserved.
//

import UIKit
import CoreData

class StatsViewController: UIViewController, ChartViewDelegate, UITableViewDelegate, UITableViewDataSource  {
    
    var dataArray: [NSManagedObject] = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext?.executeFetchRequest(NSFetchRequest(entityName: "Task"), error: nil) as? [NSManagedObject])!
    var sum: Int!
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var infoTaskTableView: UITableView!
    
    
    func totalTime() -> Int {
        var sum = 0
        var i = 0
        for (i = 0; i < dataArray.count; i++){
        sum += dataArray[i].valueForKey("taskDuration") as! Int
        }
        return sum
    }
    
    //MARK: - ViewContoller Lifecycle
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoTaskTableView.delegate = self
        infoTaskTableView.dataSource = self
        pieChart.delegate = self
        pieChart.usePercentValuesEnabled = false
        pieChart.holeTransparent = true
        pieChart.centerTextFont  = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        pieChart.holeRadiusPercent = 0.5
        pieChart.transparentCircleRadiusPercent = 0.6
        pieChart.descriptionText = ""
        pieChart.drawCenterTextEnabled = true
        pieChart.drawHoleEnabled = true
        pieChart.rotationEnabled = true
        pieChart.centerText = ""
        pieChart.backgroundColor = UIColor.clearColor()
        
        setDataCount(dataArray.count)
        pieChart.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: ChartEasingOption.EaseInOutBack)
        
        sum = totalTime()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        pieChart.usePercentValuesEnabled = true
    }
    
    //MARK: - Charts Setting
    
    func setDataCount(count: Int)
    {
        var yVals1: [BarChartDataEntry] = []
        var xVals: [String] = []
        
        for (var i = 0; i < count; i++) {
            yVals1.append(BarChartDataEntry(value: (Double)((dataArray[i].valueForKey("taskDuration")) as! Int), xIndex: i))
            xVals.append(dataArray[i % dataArray.count].valueForKey("taskName") as! String)
        }
        
        var dataSet = PieChartDataSet(yVals: yVals1, label: "")
        dataSet.sliceSpace = 3.0
        
        var colors: [UIColor] = []
        colors += ChartColorTemplates.liberty()
        dataSet.colors = colors
        
        var data = PieChartData(xVals: xVals, dataSet: dataSet)
        
        pieChart.data = data
        
        pieChart.highlightValues(nil)
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        infoTaskTableView.selectRowAtIndexPath(NSIndexPath(forRow: highlight.xIndex, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.Top)
    }
    
    func updateData() {
        dataArray = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext?.executeFetchRequest(NSFetchRequest(entityName: "Task"), error: nil) as? [NSManagedObject])!
    }
    
    //MARK: - TableView Setting
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath) as! StatsTableViewCell
        cell.taskNameLabel.text = (dataArray[indexPath.row]).valueForKey("taskName") as? String
        var duration: Int = dataArray[indexPath.row].valueForKey("taskDuration") as! Int
        if (sum != 0) {
            cell.taskDurationLabel.text = "\(duration * 100 / sum!)%"
        }
        cell.selectedBackgroundView = UIView(frame: cell.frame)
        cell.selectedBackgroundView.backgroundColor = UIColor(red: 150 / 255, green: 205 / 255, blue: 200 / 255, alpha: 0.50)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        pieChart.highlightValue(xIndex: indexPath.row, dataSetIndex: 0, callDelegate: false)
    }
    
    @IBAction func viewFinished(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
