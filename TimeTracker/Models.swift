//
//  Models.swift
//  TimeTracker
//
//  Created by Sam Ritchie on 19/01/2016.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import Foundation
import RealmSwift

class Project: Object {
    dynamic var id: String = NSUUID().UUIDString
    dynamic var name: String = ""
    let activities = List<Activity>()
    
    override class func primaryKey() -> String { return "id" }
}

class Activity: Object {
    dynamic var startDate: NSDate?
    dynamic var endDate: NSDate?
}

extension Project {
    var elapsedTime: NSTimeInterval {
        return activities.reduce(0) { time, activity in
            guard let start = activity.startDate,
                let end = activity.endDate else { return time }
            return time + end.timeIntervalSinceDate(start)
        }
    }
    
    var currentActivity: Activity? {
        return activities.filter("endDate == nil").first
    }
}