//
//  AppDelegate.swift
//  Todoey
//
//  Created by iw02 on 26/02/18.
//  Copyright © 2018 iw02. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //print(Realm.Configuration.defaultConfiguration.fileURL)
        
        do {
            _ = try Realm()
        } catch {
            print("Error installing new Realm, \(error)")
        }
        
        
        return true
    }

}

