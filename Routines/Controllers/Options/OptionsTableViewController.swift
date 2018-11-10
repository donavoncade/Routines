//
//  OptionsTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/30/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI
import RealmSwift

class OptionsTableViewController: UITableViewController {
    
    @IBOutlet weak var morningSwitch: UISwitch!
    @IBOutlet weak var afternoonSwitch: UISwitch!
    @IBOutlet weak var eveningSwitch: UISwitch!
    @IBOutlet weak var nightSwitch: UISwitch!
    
    @IBOutlet weak var morningSubLabel: UILabel!
    @IBOutlet weak var afternoonSubLabel: UILabel!
    @IBOutlet weak var eveningSubLabel: UILabel!
    @IBOutlet weak var nightSubLabel: UILabel!
    
    
    @IBAction func notificationSwitchToggled(_ sender: UISwitch) {
        switch sender.tag {
        case 1:
            print("Afternoon Switch Toggled \(sender.isOn)")
            addOrRemoveNotifications(isOn: sender.isOn, segment: 1)
            updateNotificationOptions(segment: 1, isOn: sender.isOn)
        case 2:
            print("Evening Switch Toggled \(sender.isOn)")
            addOrRemoveNotifications(isOn: sender.isOn, segment: 2)
            updateNotificationOptions(segment: 2, isOn: sender.isOn)
        case 3:
            print("Night Switch Toggled \(sender.isOn)")
            addOrRemoveNotifications(isOn: sender.isOn, segment: 3)
            updateNotificationOptions(segment: 3, isOn: sender.isOn)
        default:
            print("Morning Switch Toggled \(sender.isOn)")
            addOrRemoveNotifications(isOn: sender.isOn, segment: 0)
            updateNotificationOptions(segment: 0, isOn: sender.isOn)
        }
    }
    
    
    @IBOutlet weak var smartSnoozeSwitch: UISwitch!
    @IBAction func smartSnoozeSwitchToggled(_ sender: UISwitch) {
        setSmartSnooze()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    //TODO: Make this dependant on if pro has been purchased when those options are ready
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int
        switch section {
        case 0:
            numberOfRows = 1
        case 1:
            numberOfRows = 4
        case 2:
            numberOfRows = 1
        case 3:
            numberOfRows = 1
        default:
            numberOfRows = 0
        }
        
        return numberOfRows
    }
    
    //Make the full width of the cell toggle the switch along with typical haptic
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        if indexPath.section == 1 {
            switch indexPath.row {
            case 1:
                print("Tapped Afternoon Cell")
                let isOn = !self.afternoonSwitch.isOn
                self.afternoonSwitch.setOn(isOn, animated: true)
                addOrRemoveNotifications(isOn: isOn, segment: 1)
                print("Afternoon switch is now set to: \(afternoonSwitch.isOn)")
                updateNotificationOptions(segment: 0, isOn: afternoonSwitch.isOn)
                haptic.impactOccurred()
            case 2:
                print("Tapped Evening Cell")
                let isOn = !self.eveningSwitch.isOn
                self.eveningSwitch.setOn(isOn, animated: true)
                addOrRemoveNotifications(isOn: isOn, segment: 2)
                print("Evening switch is now set to: \(eveningSwitch.isOn)")
                updateNotificationOptions(segment: 0, isOn: eveningSwitch.isOn)
                haptic.impactOccurred()
            case 3:
                print("Tapped Night Cell")
                let isOn = !self.nightSwitch.isOn
                self.nightSwitch.setOn(isOn, animated: true)
                addOrRemoveNotifications(isOn: isOn, segment: 3)
                print("Night switch is now set to: \(nightSwitch.isOn)")
                updateNotificationOptions(segment: 0, isOn: nightSwitch.isOn)
                haptic.impactOccurred()
            default:
                print("Tapped Morning Cell")
                let isOn = !self.morningSwitch.isOn
                self.morningSwitch.setOn(isOn, animated: true)
                addOrRemoveNotifications(isOn: isOn, segment: 4)
                print("Morning switch is now set to: \(morningSwitch.isOn)")
                updateNotificationOptions(segment: 0, isOn: morningSwitch.isOn)
                haptic.impactOccurred()
            }
        }
        
        //Smart Snooze
        if indexPath.section == 2 {
            switch indexPath.row {
                
            default:
                self.smartSnoozeSwitch.setOn(!smartSnoozeSwitch.isOn, animated: true)
                setSmartSnooze()
            }
        }
    }

    //MARK: - Options Realm
    
//    //Options Properties
//    let optionsRealm = try! Realm()
//    var optionsObject: Options?
//    //var firstItemAdded: Bool?
//    let optionsKey = "optionsKey"
//
//    //Load Options
//    func loadOptions() {
//        optionsObject = optionsRealm.object(ofType: Options.self, forPrimaryKey: optionsKey)
//    }
    
    func updateNotificationOptions(segment: Int, isOn: Bool) {
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                switch segment {
                case 1:
                    do {
                        try realm.write {
                            print("updateNotificationOptions saving")
                            options?.afternoonNotificationsOn = isOn
                        }
                    } catch {
                        print("updateNotificationOptions failed")
                    }
                case 2:
                    do {
                        try realm.write {
                            print("updateNotificationOptions saving")
                            options?.eveningNotificationsOn = isOn
                        }
                    } catch {
                        print("updateNotificationOptions failed")
                    }
                case 3:
                    do {
                        try realm.write {
                            print("updateNotificationOptions saving")
                            options?.nightNotificationsOn = isOn
                        }
                    } catch {
                        print("updateNotificationOptions failed")
                    }
                default:
                    do {
                        try realm.write {
                            print("updateNotificationOptions saving")
                            options?.morningNotificationsOn = isOn
                        }
                    } catch {
                        print("updateNotificationOptions failed")
                    }
                }
            }
        }
    }
    
    func setUpUI() {
        DispatchQueue.main.async {
            autoreleasepool {
                self.morningSwitch.setOn(self.getSwitchFromOptions(segment: 0), animated: false)
                self.afternoonSwitch.setOn(self.getSwitchFromOptions(segment: 1), animated: false)
                self.eveningSwitch.setOn(self.getSwitchFromOptions(segment: 2), animated: false)
                self.nightSwitch.setOn(self.getSwitchFromOptions(segment: 3), animated: false)
                
                self.smartSnoozeSwitch.setOn(self.smartSnoozeStatus(), animated: false)
                
                self.morningSubLabel.text = self.getOptionTimes(timePeriod: 0)
                self.afternoonSubLabel.text = self.getOptionTimes(timePeriod: 1)
                self.eveningSubLabel.text = self.getOptionTimes(timePeriod: 2)
                self.nightSubLabel.text = self.getOptionTimes(timePeriod: 3)
            }
        }
    }
    
    
    //MARK: smartSnooze
    func smartSnoozeStatus() -> Bool {
        var status = false
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                if let smartSnooze = options?.smartSnooze {
                    status = smartSnooze
                }
            }
        }
        return status
    }
    
    func getSmartSnoozeSwitch() -> Bool {
        var isOn = false
        DispatchQueue.main.sync {
            autoreleasepool {
                isOn = smartSnoozeSwitch.isOn
            }
        }
        return isOn
    }
    
    func setSmartSnooze() {
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                do {
                    try realm.write {
                        options?.smartSnooze = self.getSmartSnoozeSwitch()
                    }
                } catch {
                    print("failed to update smartSnooze")
                }
            }
        }
    }
    
    //END: smartSnooze
    
    func getSwitchFromOptions(segment: Int) -> Bool {
        var isOn = true
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                switch segment {
                case 1:
                    if let on = options?.afternoonNotificationsOn {
                        isOn = on
                    }
                case 2:
                    if let on = options?.eveningNotificationsOn {
                        isOn = on
                    }
                case 3:
                    if let on = options?.nightNotificationsOn {
                        isOn = on
                    }
                default:
                    if let on = options?.morningNotificationsOn {
                        isOn = on
                    }
                }
            }
        }
        return isOn
    }
    
    func getNotificationBool(notificationOption: Bool?) -> Bool {
        var isOn = true
        if let notificationIsOn = notificationOption {
            isOn = notificationIsOn
        }
        return isOn
    }
    
    func getOptionTimes(timePeriod: Int) -> String {
        var time: String = " "
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                var timeOption: DateComponents?
                
                switch timePeriod {
                case 1:
                    timeOption?.hour = options?.afternoonHour
                    timeOption?.minute = options?.afternoonMinute
                case 2:
                    timeOption?.hour = options?.eveningHour
                    timeOption?.minute = options?.eveningMinute
                case 3:
                    timeOption?.hour = options?.nightHour
                    timeOption?.minute = options?.nightMinute
                default:
                    timeOption?.hour = options?.morningHour
                    timeOption?.minute = options?.morningMinute
                }
                
                let periods = ["morning", "afternoon", "evening", "night"]
                let dateFormatter = DateFormatter()
                //dateFormatter.timeStyle = .short
                dateFormatter.locale = Locale.autoupdatingCurrent
                dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
                
                if let dateTime = timeOption {
                    
                    time = "Your \(periods[timePeriod]) begins at \(DateFormatter.localizedString(from: dateTime.date!, dateStyle: .short, timeStyle: .short))"
                } else {
                    
                    let defaultTime = dateFormatter.date(from: defaultTimeStrings[timePeriod])!
                    
                    time = "Your \(periods[timePeriod]) begins at \(getLocalTimeString(date: defaultTime))"
                }
            }
        }
        
        return time
    }
    
    func getOptionTimesAsDate(timePeriod: Int, timeOption: Date?) -> Date {
        var time: Date
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        
        if let setTime = timeOption {
            time = setTime
        } else {
            time = dateFormatter.date(from: defaultTimeStrings[timePeriod])!
        }
        
        return time
    }
//
//    func getHour(date: Date) -> Int {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "HH"
//        let hour = dateFormatter.string(from: date)
//        return Int(hour)!
//    }
//
//    func getMinute(date: Date) -> Int {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "mm"
//        let minutes = dateFormatter.string(from: date)
//        return Int(minutes)!
//    }
    
//    func updateItemUUID(item: Items, uuidString: String) {
//        DispatchQueue(label: realmDispatchQueueLabel).async {
//            autoreleasepool {
//                let realm = try! Realm()
//                do {
//                    try realm.write {
//                        item.uuidString = uuidString
//                    }
//                } catch {
//                    print("updateItemUUID failed")
//                }
//            }
//        }
//    }
    
    //MARK: - Manage Notifications

    //This is the one to run when setting up a brand new notification
    func scheduleNewNotification(title: String, notes: String?, segment: Int, uuidString: String) {
        
        print("running scheduleNewNotification")
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { (settings) in
            //DO not schedule notifications if not authorized
            guard settings.authorizationStatus == .authorized else {
                //self.requestNotificationPermission()
                print("Authorization status has changed to unauthorized for notifications")
                return
            }
            
            DispatchQueue(label: self.realmDispatchQueueLabel).sync {
                autoreleasepool {
                    let realm = try! Realm()
                    let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                    switch segment {
                    case 1:
                        if (options?.afternoonNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString)
                        } else {
                            print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    case 2:
                        if (options?.eveningNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString)
                        } else {
                            print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    case 3:
                        if (options?.nightNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString)
                        } else {
                            print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    default:
                        if (options?.morningNotificationsOn)! {
                            self.createNotification(title: title, notes: notes, segment: segment, uuidString: uuidString)
                        } else {
                            print("Afternoon Notifications toggled off. Aborting")
                            return
                        }
                    }
                }
            }
            
        }
    }
    
    func createNotification(title: String, notes: String?, segment: Int, uuidString: String) {
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
        self.loadOptions()
        
        switch segment {
        case 1:
            dateComponents.hour = afternoonHour
            dateComponents.minute = afternoonMinute
        case 2:
            dateComponents.hour = eveningHour
            dateComponents.minute = eveningMinute
        case 3:
            dateComponents.hour = nightHour
            dateComponents.minute = nightMinute
        default:
            dateComponents.hour = morningHour
            dateComponents.minute = morningMinute
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
    
    public func removeNotification(uuidString: [String]) {
        print("Removing Notifications")
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: uuidString)
    }
    
    func removeNotificationsForSegment(segment: Int) {
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                var uuidStrings: [String] = []
                let realm = try! Realm()
                let items = realm.objects(Items.self).filter("segment = \(segment)")
                for item in 0..<items.count {
                    uuidStrings.append(items[item].uuidString)
                }
                //Might need to move this. But lets try it
                self.removeNotification(uuidString: uuidStrings)
            }
        }
        
    }
    
    func enableNotificationsForSegment(segment: Int) {
        DispatchQueue(label: realmDispatchQueueLabel).async {
            autoreleasepool {
                let realm = try! Realm()
                let items = realm.objects(Items.self).filter("segment = \(segment)")
                for item in 0..<items.count {
                    self.scheduleNewNotification(title: items[item].title!, notes: items[item].notes, segment: items[item].segment, uuidString: items[item].uuidString)
                }
            }
        }
    }
    
    func addOrRemoveNotifications(isOn: Bool, segment: Int) {
        if isOn {
            enableNotificationsForSegment(segment: segment)
        } else {
            removeNotificationsForSegment(segment: segment)
        }
    }

//    func addRemoveNotificationsOnToggle(segment: Int, isOn: Bool) {
//        DispatchQueue(label: realmDispatchQueueLabel).sync {
//            autoreleasepool {
//                let realm = try! Realm()
//                let items = realm.objects(Items.self).filter("segment = \(segment)")
//                if isOn {
//                    print("Turning notifications on for segment \(segment)")
//                    for item in 0..<items.count {
//                        self.scheduleNewNotification(title: items[item].title!, notes: items[item].notes, segment: segment, uuidString: items[item].uuidString)
//                    }
//                } else {
//                    print("Turning notifications off for segment \(segment)")
//                    var uuidStrings: [String]?
//                    for item in 0..<items.count {
//                        uuidStrings?.append(items[item].uuidString)
//                    }
//                    self.removeNotification(uuidString: uuidStrings)
//                }
//            }
//        }
//    }
    
    //MARK: - Conversion functions
    let defaultTimeStrings = ["07:00", "12:00", "17:00", "21:00"]
    
    func getLocalTimeString(date: Date) -> String{
        return DateFormatter.localizedString(from: date, dateStyle: .none, timeStyle: .short)
    }
    
    
    func getTime(timePeriod: Int, timeOption: Date?) -> Date {
        var time: Date
        let dateFormatter = DateFormatter()
        //dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("HH:mm")
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
    
    func getOptionHour(segment: Int) -> Int {
        var hour = Int()
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                switch segment {
                case 1:
                    hour = (options?.afternoonHour)!
                case 2:
                    hour = (options?.eveningHour)!
                case 3:
                    hour = (options?.nightHour)!
                default:
                    hour = (options?.morningHour)!
                }
                
            }
        }
        return hour
    }
    
    func getOptionMinute(segment: Int) -> Int {
        var minute = Int()
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
                switch segment {
                case 1:
                    minute = (options?.afternoonMinute)!
                case 2:
                    minute = (options?.eveningMinute)!
                case 3:
                    minute = (options?.nightMinute)!
                default:
                    minute = (options?.morningMinute)!
                }
                
            }
        }
        return minute
    }
    
    //Set the notification badge count
    func getSegmentCount(segment: Int) -> Int {
        var count = Int()
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                count = realm.objects(Items.self).filter("segment = \(segment)").count
            }
        }
        return count
    }
    
    //Mark: - Realm
    
    let realmDispatchQueueLabel: String = "background"
    let optionsKey = "optionsKey"
    
    lazy var morningHour: Int = 7
    lazy var morningMinute: Int = 0
    
    lazy var afternoonHour: Int = 12
    lazy var afternoonMinute: Int = 0
    
    lazy var eveningHour: Int = 17
    lazy var eveningMinute: Int = 0
    
    lazy var nightHour: Int = 21
    lazy var nightMinute: Int = 0
    
    //Load Options
    func loadOptions() {
        DispatchQueue(label: realmDispatchQueueLabel).sync {
            autoreleasepool {
                let realm = try! Realm()
                if let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey) {
                    self.morningHour = options.morningHour
                    self.morningMinute = options.morningMinute
                    
                    self.afternoonHour = options.afternoonHour
                    self.afternoonMinute = options.afternoonMinute
                    
                    self.eveningHour = options.eveningHour
                    self.eveningMinute = options.eveningMinute
                    
                    self.nightHour = options.nightHour
                    self.nightMinute = options.nightMinute
                }
            }
        }
    }

    //MARK: Items Realm
    
//    var time: [Date?] = []
//
//    func loadTimes() {
//        DispatchQueue(label: realmDispatchQueueLabel).async {
//            autoreleasepool {
//                let realm = try! Realm()
//                let options = realm.object(ofType: Options.self, forPrimaryKey: self.optionsKey)
//                //self.optionsObject = options
//                self.time = [options?.morningStartTime, options?.afternoonStartTime, options?.eveningStartTime, options?.nightStartTime]
//            }
//        }
//    }

//    func getTime(timePeriod: Int, timeOption: Date?) -> Date {
//        var time: Date
//        let defaultTimeStrings = ["07:00 AM", "12:00 PM", "5:00 PM", "9:00 PM"]
//        let dateFormatter = DateFormatter()
//        dateFormatter.timeStyle = .short
//
//        if let setTime = timeOption {
//            time = setTime
//        } else {
//            time = dateFormatter.date(from: defaultTimeStrings[timePeriod])!
//        }
//
//        return time
//    }

}
