//
//  AppDelegate.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import UserNotificationsUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{

    var window: UIWindow?
    
    let center = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        migrateRealm()
        
        center.delegate = self
        
        requestNotificationPermission()
        registerNotificationCategoriesAndActions()
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //checkToCreateOptions()
        loadOptions()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
//    //MARK: - Options Realm
    var timeArray: [Date?] = []
//    //Options Properties
    lazy var realm = try! Realm()
    var optionsObject: Options?
    let optionsKey = "optionsKey"
    let realmDispatchQueueLabel: String = "background"
    
    func migrateRealm() {
        print("performing realm migration")
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
//                    migration.enumerateObjects(ofType: Items.className(), { (newObject, oldObject) in
//                        newObject!["uuidString"] = oldObject!["uuidString"]
//                    })
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        let realm = try! Realm()
    }
    
    func loadTimes() {
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                //self.optionsObject = options
                self.timeArray = [options?.morningStartTime, options?.afternoonStartTime, options?.eveningStartTime, options?.nightStartTime]
            }
        }
    }

    //Load Options
    func loadOptions() {
        optionsObject = realm.object(ofType: Options.self, forPrimaryKey: optionsKey)

        if let currentOptions = realm.object(ofType: Options.self, forPrimaryKey: optionsKey) {
            self.optionsObject = currentOptions
            print("AppDelegate: Options loaded successfully - \(String(describing: optionsObject))")
        } else {
            print("AppDelegate: No Options exist yet. Creating it.")
            let newOptionsObject = Options()
            newOptionsObject.optionsKey = optionsKey
            do {
                try realm.write {
                    realm.add(newOptionsObject, update: false)
                }
            } catch {
                print("Failed to create new options object")
            }
            loadOptions()
        }

    }
    
    func completeItem(uuidString: String) {
        print("running completeItem")
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let item = realm.object(ofType: Items.self, forPrimaryKey: uuidString) {
                    print("Completing item")
                    do {
                        try! realm.write {
                            realm.delete(item)
                        }
                    }
                }
            }
            print("completeItem completed")
        }
    }
    
    func snoozeItem(uuidString: String) {
        print("running snoozeItem")
        var title : String?
        var notes : String?
        var itemSegment : Int?
        var itemuuidString : String?
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let item = realm.object(ofType: Items.self, forPrimaryKey: uuidString) {
                    let segment = item.segment
                    var newSegment = Int()
                    
                    switch segment {
                    case 3:
                        newSegment = 0
                    default:
                        newSegment = segment+1
                    }
                    
                    do {
                        try! realm.write {
                            item.segment = newSegment
                        }
                    }
                    title = item.title
                    notes = item.notes
                    itemSegment = item.segment
                    itemuuidString = item.uuidString
                    print("snoozeItem Completed")
                }
            }
        }
        if let newTitle = title {
            scheduleNewNotification(title: newTitle, notes: notes!, segment: itemSegment!, uuidString: itemuuidString!)
        }
    }
    
    //MARK: - Manage Notifications
    
    func requestNotificationPermission() {
        //let center = UNUserNotificationCenter.current()
        //Request permission to display alerts and play sounds
        if #available(iOS 12.0, *) {
            center.requestAuthorization(options: [.alert, .sound, .badge, .providesAppNotificationSettings]) { (granted, error) in
                // Enable or disable features based on authorization.
                if granted {
                    print("App Delegate: App has notification permission")
                } else {
                    print("App Delegate: App does not have notification permission")
                    return
                }
            }
        } else {
            // Fallback on earlier versions
            center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                // Enable or disable features based on authorization.
                if granted {
                    print("App Delegate: App has notification permission")
                } else {
                    print("App Delegate: App does not have notification permission")
                    return
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        print("taking use to notification settings")
        let navController = NavigationViewController()
        let notificationSettingsVC = OptionsTableViewController()
        navController.pushViewController(notificationSettingsVC, animated: true)
    }
    
    //Notification Categories and Actions
    
    func registerNotificationCategoriesAndActions() {
        //let center = UNUserNotificationCenter.current()
        
        let completeAction = UNNotificationAction(identifier: "complete", title: "Complete", options: UNNotificationActionOptions(rawValue: 0))
        
        let snoozeAction = UNNotificationAction(identifier: "snooze", title: "Snooze", options: UNNotificationActionOptions(rawValue: 0))
        
        let morningCategory = UNNotificationCategory(identifier: "morning", actions: [snoozeAction,completeAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        let afternoonCategory = UNNotificationCategory(identifier: "afternoon", actions: [snoozeAction,completeAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        let eveningCategory = UNNotificationCategory(identifier: "evening", actions: [snoozeAction,completeAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        let nightCategory = UNNotificationCategory(identifier: "night", actions: [snoozeAction,completeAction], intentIdentifiers: [], options: UNNotificationCategoryOptions(rawValue: 0))
        
        center.setNotificationCategories([morningCategory,afternoonCategory,eveningCategory,nightCategory])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("running userNotificationCenter:didReceive:withCompletionHandler")
        if response.notification.request.content.categoryIdentifier == "morning" {
            print("running response: morning")
            switch response.actionIdentifier {
            case "complete":
                completeItem(uuidString: response.notification.request.identifier)
            case "snooze":
                snoozeItem(uuidString: response.notification.request.identifier)
            default:
                break
            }
            
        }
        
        if response.notification.request.content.categoryIdentifier == "afternoon" {
            print("running response: afternoon")
            switch response.actionIdentifier {
            case "complete":
                completeItem(uuidString: response.notification.request.identifier)
            case "snooze":
                snoozeItem(uuidString: response.notification.request.identifier)
            default:
                break
            }
        }
        
        if response.notification.request.content.categoryIdentifier == "evening" {
            print("running response: evening")
            switch response.actionIdentifier {
            case "complete":
                completeItem(uuidString: response.notification.request.identifier)
            case "snooze":
                snoozeItem(uuidString: response.notification.request.identifier)
            default:
                break
            }
        }
        
        if response.notification.request.content.categoryIdentifier == "night" {
            print("running response: night")
            switch response.actionIdentifier {
            case "complete":
                completeItem(uuidString: response.notification.request.identifier)
            case "snooze":
                snoozeItem(uuidString: response.notification.request.identifier)
            default:
                break
            }
        }
        
        completionHandler()
        
    }
    
    func scheduleNewNotification(title: String, notes: String?, segment: Int, uuidString: String) {
        
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: optionsKey)
                switch segment {
                case 1:
                    if !(options?.afternoonNotificationsOn)! {
                        print("Afternoon Notifications toggled off. Aborting")
                        return
                    }
                case 2:
                    if !(options?.eveningNotificationsOn)! {
                        print("Afternoon Notifications toggled off. Aborting")
                        return
                    }
                case 3:
                    if !(options?.nightNotificationsOn)! {
                        print("Afternoon Notifications toggled off. Aborting")
                        return
                    }
                default:
                    if !(options?.morningNotificationsOn)! {
                        print("Afternoon Notifications toggled off. Aborting")
                        return
                    }
                }
            }
        }
        
        print("running scheduleNewNotification")
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { (settings) in
            //DO not schedule notifications if not authorized
            guard settings.authorizationStatus == .authorized else {
                //self.requestNotificationPermission()
                print("Authorization status has changed to unauthorized for notifications")
                return
            }
            
            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString)
            
        }
    }
    
    func createNotification(title: String, notes: String?, segment: Int, uuidString: String) {
        loadTimes()
        print("createNotification running")
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = UNNotificationSound.default
        content.threadIdentifier = String(segment)
        
        if let notesText = notes {
            content.body = notesText
        }
        
        // Assign the category (and the associated actions).
        switch segment {
        case 1:
            content.categoryIdentifier = "afternoon"
        case 2:
            content.categoryIdentifier = "evening"
        case 3:
            content.categoryIdentifier = "night"
        default:
            content.categoryIdentifier = "morning"
        }
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        
        switch segment {
        case 1:
            if let time = self.timeArray[1] {
                dateComponents.hour = getHour(date: getTime(timePeriod: 1, timeOption: time))
                dateComponents.minute = getMinute(date: getTime(timePeriod: 1, timeOption: time))
            }
        case 2:
            if let time = self.timeArray[2] {
                dateComponents.hour = getHour(date: getTime(timePeriod: 2, timeOption: time))
                dateComponents.minute = getMinute(date: getTime(timePeriod: 2, timeOption: time))
            }
        case 3:
            if let time = self.timeArray[3] {
                dateComponents.hour = getHour(date: getTime(timePeriod: 3, timeOption: time))
                dateComponents.minute = getMinute(date: getTime(timePeriod: 3, timeOption: time))
            }
        default:
            if let time = self.timeArray[0] {
                dateComponents.hour = getHour(date: getTime(timePeriod: 0, timeOption: time))
                dateComponents.minute = getMinute(date: getTime(timePeriod: 0, timeOption: time))
            }
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        //Create the request
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        //Schedule the request with the system
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                //TODO: handle notification errors
                print(String(describing: error))
            } else {
                print("Notification created successfully")
            }
        }
        
    }
    
    //MARK: - Conversion functions
    func getTime(timePeriod: Int, timeOption: Date?) -> Date {
        var time: Date
        let defaultTimeStrings = ["07:00", "12:00", "17:00", "21:00 PM"]
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        
        if let setTime = timeOption {
            time = setTime
        } else {
            time = dateFormatter.date(from: defaultTimeStrings[timePeriod])!
        }
        
        return time
    }
    
    func getHour(date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hour = dateFormatter.string(from: date)
        return Int(hour)!
    }
    
    func getMinute(date: Date) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        let minutes = dateFormatter.string(from: date)
        return Int(minutes)!
    }
    
}

