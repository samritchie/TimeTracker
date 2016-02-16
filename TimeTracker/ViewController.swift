//
//  ViewController.swift
//  TimeTracker
//
//  Created by Sam Ritchie on 19/01/2016.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UITableViewController {

    let projects = store.projects
    var notificationToken: NotificationToken?
    @IBOutlet var newProjectTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateView()
        notificationToken = projects.addNotificationBlock { [weak self] (_) in
            self?.updateView()
        }
    }

    func updateView() {
        tableView.reloadData()
        hideNewProjectView()
    }

    @IBAction func showNewProjectView(sender: AnyObject) {
        tableView.tableHeaderView?.frame = CGRect(origin: CGPointZero, size: CGSize(width: view.frame.size.width, height: 44))
        tableView.tableHeaderView?.hidden = false
        tableView.tableHeaderView = tableView.tableHeaderView // tableHeaderView needs to be reassigned to recognize new height
        newProjectTextField.becomeFirstResponder()
    }
    
    func hideNewProjectView() {
        tableView.tableHeaderView?.frame = CGRect(origin: CGPointZero, size: CGSize(width: view.frame.size.width, height: 0))
        tableView.tableHeaderView?.hidden = true
        tableView.tableHeaderView = tableView.tableHeaderView
        newProjectTextField.endEditing(true)
        newProjectTextField.text = nil
    }
    
    @IBAction func addButtonTapped() {
        guard let name = newProjectTextField.text else { return }
        try! projects.realm!.write {
            projects.addProject(name)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProjectCell") as! ProjectCell
        cell.project = projects[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let project = projects[indexPath.row]
        try! project.realm!.write {
            project.deleteProject()
        }
    }
}


class ProjectCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var elapsedTimeLabel: UILabel!
    @IBOutlet var activityButton: UIButton!
    
    var project: Project? {
        didSet {
            guard let project = project else { return }
            nameLabel.text = project.name
            if project.currentActivity != nil {
                elapsedTimeLabel.text = "⌚️"
                activityButton.setTitle("Stop", forState: .Normal)
            } else {
                elapsedTimeLabel.text = NSDateComponentsFormatter().stringFromTimeInterval(project.elapsedTime)
                activityButton.setTitle("Start", forState: .Normal)
            }
        }
    }
    
    @IBAction func activityButtonTapped() {
        guard let project = project else { return }

        try! project.realm!.write {
            if let currentActivity = project.currentActivity {
                currentActivity.endDate = NSDate()
            } else {
                project.startActivity(NSDate())
            }
        }
    }
}