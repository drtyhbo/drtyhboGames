//
//  AppDelegate.swift
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/2/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import Crashlytics
import Fabric
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


  private func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
        cacheModels()

        return true
    }

    private func cacheModels() {
        let modelNames = [
            "cube",
            "gem",
            "gravity",
            "seeker",
            "flyer",
            "ship"]
        for modelName in modelNames {
          ModelLoader.sharedLoader.loadWithName(name: modelName)
        }
    }
}

