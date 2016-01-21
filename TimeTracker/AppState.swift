//
//  AppState.swift
//  TimeTracker
//
//  Created by Sam Ritchie on 19/01/2016.
//  Copyright © 2016 Realm Inc. All rights reserved.
//

import Foundation
import RealmSwift

struct AppState {
    let projects: [Project]
}

protocol StoreSubscriber: AnyObject {
    func stateDidUpdate(state: AppState)
}

class Store {
    private let realm = try! Realm()
    private var notificationToken: NotificationToken? = nil
    private var subscribers: NSHashTable
    
    init() {
        subscribers = NSHashTable.weakObjectsHashTable()
        notificationToken = realm.addNotificationBlock { notification, realm in
            if notification == .RefreshRequired { realm.refresh() }
            let projects = Array(realm.objects(Project.self))
            for sub in self.subscribers.allObjects {
                (sub as? StoreSubscriber)?.stateDidUpdate(AppState(projects: projects))
            }
        }
    }
    
    func subscribe(sub: StoreSubscriber) {
        subscribers.addObject(sub)
        sub.stateDidUpdate(AppState(projects: Array(realm.objects(Project.self))))
    }
    
    func dispatch(action: Action) {
        try! realm.write {
            switch action {
            case let .AddProject(name):
                addProject(name)
            case let .DeleteProject(id):
                deleteProject(id)
            case let .StartActivity(id, start):
                startActivity(id, start: start)
            case let .EndActivity(id, end):
                endActivity(id, end: end)
            }
        }
    }
    
    private func addProject(name: String) {
        let project = Project()
        project.name = name
        realm.add(project)
    }
    
    private func deleteProject(id: String) {
        if let project = realm.objectForPrimaryKey(Project.self, key: id) {
            realm.delete(project.activities)
            realm.delete(project)
        }
    }
    
    private func startActivity(id: String, start: NSDate) {
        if let project = realm.objectForPrimaryKey(Project.self, key: id) {
            let act = Activity()
            act.startDate = start
            project.activities.append(act)
        }
    }
    
    private func endActivity(id: String, end: NSDate) {
        if let project = realm.objectForPrimaryKey(Project.self, key: id),
            let act = project.currentActivity {
            act.endDate = end
        }
    }

}

let store = Store()
