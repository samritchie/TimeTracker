//
//  Store.swift
//  TimeTracker
//
//  Created by Sam Ritchie on 19/01/2016.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import Foundation
import RealmSwift


// MARK: Model Classes

class Project: Object {
    dynamic var name: String
    let activities = List<Activity>()

    init(name: String) {
        self.name = name
        super.init()
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    var elapsedTime: NSTimeInterval {
        return activities.reduce(0) { time, activity in
            guard let end = activity.endDate else { return time }
            return time + end.timeIntervalSinceDate(activity.startDate)
        }
    }

    var currentActivity: Activity? {
        return activities.filter("endDate == nil").first
    }

    // MARK: Actions

    func startActivity(startDate: NSDate) {
        let act = Activity(startDate: startDate)
        activities.append(act)
    }

    func deleteProject() {
        realm!.delete(activities)
        realm!.delete(self)
    }
}

class Activity: Object {
    dynamic var startDate: NSDate
    dynamic var endDate: NSDate?

    init(startDate: NSDate) {
        self.startDate = startDate
        super.init()
    }

    required init() {
        fatalError("init() has not been implemented")
    }
}


// MARK: Extensions

extension Results where T: Project {
    func addProject(name: String) {
        realm!.add(Project(name: name))
    }
}

extension Realm {
    var projects: Results<Project> {
        return objects(Project.self)
    }
}


// MARK: Globals

let store = try! Realm()
