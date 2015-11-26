//
//  AppDelegate.swift
//  MetalTutorial
//
//  Created by Andreas Binnewies on 10/2/15.
//  Copyright © 2015 drtyhbo productions. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
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
            ModelLoader.sharedLoader.loadWithName(modelName)
        }
    }
}

