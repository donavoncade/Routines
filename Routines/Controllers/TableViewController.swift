//
//  TableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/21/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit
import UserNotifications
import UserNotificationsUI

class TableViewController: SwipeTableViewController, UITabBarControllerDelegate{
    
    @IBAction func unwindToTableViewController(segue:UIStoryboardSegue){}
    
    let realmDispatchQueueLabel: String = "background"
    
    let optionsKey = "optionsKey"
    
    let segmentStringArray: [String] = ["Morning", "Afternoon", "Evening", "Night", "All Day"]
    
    //Set segment after adding an item
    var passedSegment: Int?
    func changeSegment(segment: Int?) {
        if let newSegment = segment {
            passedSegment = nil
            self.tabBarController?.selectedIndex = newSegment
        }
    }
    
    //Footer view
    let footerView = UIView()
    var selectedTab = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        
        footerView.backgroundColor = .clear
        self.tableView.tableFooterView = footerView
        
        setViewBackgroundGraphic()

        self.tabBarController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("View Will Appear")
        self.tabBarController?.tabBar.isHidden = false
        reloadTableView()
        updateBadge()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let selectedTab = self.tabBarController?.selectedIndex else { fatalError() }
        print("Selected tab is \(selectedTab)")
        self.filteredItems = self.items?.filter("segment = \(selectedTab)")
        print("viewDidAppear \n")
        changeSegment(segment: passedSegment)
    }
    
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        self.selectedTab = tabBarController.selectedIndex
//    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.filteredItems?.count{
            print("Rows for section: \(count)")
            return count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let count = self.filteredItems?.count {
            if count > 0 {
                cell.textLabel?.text = self.filteredItems?[indexPath.row].title
            }
        }
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addSegue" {
            
            let destination = segue.destination as! AddTableViewController
            //set segment based on current tab
            guard let selectedTab = tabBarController?.selectedIndex else { fatalError() }
            destination.editingSegment = selectedTab
            //Set right bar item as "Save"
            destination.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: destination, action: #selector(destination.saveButtonPressed))
            //Disable button until all values are filled
            destination.navigationItem.rightBarButtonItem?.isEnabled = false
        }

        if segue.identifier == "editSegue" {
            let destination = segue.destination as! AddTableViewController
            //Set right bar item as "Save"
            destination.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: destination, action: #selector(destination.saveButtonPressed))
            //Disable button until a value is changed
            destination.navigationItem.rightBarButtonItem?.isEnabled = false
            //pass in current item
            if let indexPath = tableView.indexPathForSelectedRow {
                let realm = try! Realm()
                destination.item = realm.objects(Items.self).filter("segment = \(indexPath.section)")[indexPath.row]
            }
        }
    }
    
    //MARK: - Model Manipulation Methods
    
//    func loadData() -> Results<Items> {
//        return realm.objects(Items.self)
//    }
    
    //Filter items to relevant segment and return those items
//    func loadItems(segment: Int) -> Results<Items> {
//        guard let filteredItems = items?.filter("segment = \(segment)") else { fatalError() }
//        print("loadItems run")
//        //self.tableView.reloadData()
//        return filteredItems
//    }
    
    //Override empty delete func from super
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)
        
        let realm = try! Realm()
        do {
            try! realm.write {
                let item = self.filteredItems?[indexPath.row]
                realm.delete(item!)
            }
        }
        
        self.updateBadge()
    }
    
    //TODO: Animated reload would be nice
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    //Set background graphic
    func setViewBackgroundGraphic() {
        
        //let imageSize:CGFloat = UIScreen.main.bounds.width * 0.893
        
        let backgroundImageView = UIImageView()
        let backgroundImage = UIImage(imageLiteralResourceName: "inlay")
        
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFit
        
        self.tableView.backgroundView = backgroundImageView
        
    }
    
    //Update tab bar badge counts
    func updateBadge() {
        
        if let tabs = self.tabBarController?.tabBar.items {
            
            for tab in 0..<tabs.count {
                let count = getSegmentCount(segment: tab)
                print("Count for tab \(tab) is \(count)")
                if count > 0 {
                    tabs[tab].badgeValue = "\(count)"
                } else {
                    tabs[tab].badgeValue = nil
                }
            }
        }
    }
    
    func getSegmentCount(segment: Int) -> Int {
        let realm = try! Realm()
        return realm.objects(Items.self).filter("segment = \(segment)").count
    }
    
    //MARK: - Manage Notifications
    
    func removeNotification(uuidString: String) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [uuidString])
    }
    
    //MARK: - Realm
    
    // Get the default Realm
    let realm = try! Realm()
    var items: Results<Items>?
    var filteredItems: Results<Items>?

    func loadItems() {
        items = self.realm.objects(Items.self)
    }
    
}
