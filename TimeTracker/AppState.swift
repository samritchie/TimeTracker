//
//  AppState.swift
//  TimeTracker
//
//  Created by Sam Ritchie on 19/01/2016.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {

    var projects: Results<Project> {
        return objects(Project.self)
    }
    
    // MARK: Actions
    func addProject(name: String) {
        do {
            try write {
                let project = Project()
                project.name = name
                add(project)
            }
        } catch {
            print("Add Project action failed: \(error)")
        }
   }
    
    func deleteProject(id: String) {
        guard let project = objectForPrimaryKey(Project.self, key: id) else { return }
        
        do {
            try write {
                delete(project.activities)
                delete(project)
            }
        } catch {
            print("Delete Project action failed: \(error)")
        }
    }
    
    func startActivity(projectId: String, startDate: NSDate) {
        guard let project = objectForPrimaryKey(Project.self, key: projectId) else { return }
        
        do {
            try write {
                let act = Activity()
                act.startDate = startDate
                project.activities.append(act)
            }
        } catch {
            print("Start Activity action failed: \(error)")
        }
    }
    
    func endActivity(projectId: String, endDate: NSDate) {
        guard let project = objectForPrimaryKey(Project.self, key: projectId) else { return }
        guard let activity = project.currentActivity else { return }
        
        do {
            try write {
                activity.endDate = endDate
            }
        } catch {
            print("End Activity action failed: \(error)")
        }
     }

}

let store = try! Realm()
