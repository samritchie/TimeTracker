//
//  ViewController.swift
//  TimeTracker
//
//  Created by Sam Ritchie on 19/01/2016.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, StoreSubscriber {

    var projects = [Project]()
    @IBOutlet var newProjectTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.subscribe(self)
    }

    func stateDidUpdate(state: AppState) {
        self.projects = state.projects
        tableView.tableHeaderView?.frame = CGRectZero
        tableView.tableHeaderView?.hidden = true
        tableView.tableHeaderView = tableView.tableHeaderView
        newProjectTextField.text = nil
        self.tableView.reloadData()
    }

    @IBAction func showNewItem() {
        tableView.tableHeaderView?.frame = CGRect(origin: CGPointZero, size: CGSize(width: view.frame.size.width, height: 44))
        tableView.tableHeaderView?.hidden = false
        tableView.tableHeaderView = tableView.tableHeaderView
    }
    
    @IBAction func addButtonTapped() {
        store.dispatch(.AddProject(name: newProjectTextField.text!))
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProjectCell") as! ProjectCell
        let project = projects[indexPath.row]
        
        cell.id = project.id
        cell.nameLabel.text = project.name
        if let currentActivity = project.currentActivity {
            cell.elapsedTimeLabel.text = "⌚️"
            cell.activityButton.setTitle("Stop", forState: .Normal)
        } else {
            cell.elapsedTimeLabel.text = NSDateComponentsFormatter().stringFromTimeInterval(project.elapsedTime)
            cell.activityButton.setTitle("Start", forState: .Normal)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        store.dispatch(.DeleteProject(id: projects[indexPath.row].id))
    }
}


class ProjectCell: UITableViewCell {
    var id: String!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var elapsedTimeLabel: UILabel!
    @IBOutlet var activityButton: UIButton!
    
    @IBAction func activityButtonTapped(sender: UIButton) {
        if sender.titleLabel?.text == "Start" {
            store.dispatch(.StartActivity(projectId: id, startDate: NSDate()))
        } else {
            store.dispatch(.EndActivity(projectId: id, endDate: NSDate()))
        }
    }
}