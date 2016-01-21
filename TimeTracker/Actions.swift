//
//  Actions.swift
//  TimeTracker
//
//  Created by Sam Ritchie on 19/01/2016.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import Foundation

enum Action {
    case AddProject(name: String)
    case DeleteProject(id: String)
    case StartActivity(projectId: String, startDate: NSDate)
    case EndActivity(projectId: String, endDate: NSDate)
}