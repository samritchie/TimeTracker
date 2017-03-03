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
        notificationToken = store.addNotificationBlock { [weak self] (_) in
            self?.updateView()
        }
    }

    func updateView() {
        tableView.reloadData()
        hideNewProjectView()
    }

    @IBAction func showNewProjectView(_ sender: AnyObject) {
        tableView.tableHeaderView?.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: view.frame.size.width, height: 44))
        tableView.tableHeaderView?.isHidden = false
        tableView.tableHeaderView = tableView.tableHeaderView // tableHeaderView needs to be reassigned to recognize new height
        newProjectTextField.becomeFirstResponder()
    }
    
    func hideNewProjectView() {
        tableView.tableHeaderView?.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: view.frame.size.width, height: 0))
        tableView.tableHeaderView?.isHidden = true
        tableView.tableHeaderView = tableView.tableHeaderView
        newProjectTextField.endEditing(true)
        newProjectTextField.text = nil
    }
    
    @IBAction func addButtonTapped() {
        guard let name = newProjectTextField.text else { return }
        store.addProject(name)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") as! ProjectCell
        cell.project = projects[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        store.deleteProject(projects[indexPath.row])
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
                activityButton.setTitle("Stop", for: UIControlState())
            } else {
                elapsedTimeLabel.text = DateComponentsFormatter().string(from: project.elapsedTime)
                activityButton.setTitle("Start", for: UIControlState())
            }
        }
    }
    
    @IBAction func activityButtonTapped() {
        guard let project = project else { return }
        if project.currentActivity == nil {
            store.startActivity(project, startDate: Date() as NSDate)
        } else {
            store.endActivity(project, endDate: Date() as NSDate)
        }
    }
}
