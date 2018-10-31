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

class TableViewController: SwipeTableViewController, UITabBarControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func unwindToTableViewController(segue:UIStoryboardSegue){}
    
    
    // Get the default Realm
    let realm = try! Realm()

    //var segments: Results<Segments>?
    var items: Results<Items>?
    
    //Options Properties
    let optionsRealm = try! Realm()
    var optionsObject: Options?
    //var firstItemAdded: Bool?
    let optionsKey = "optionsKey"
    
    let segmentStringArray: [String] = ["Morning", "Afternoon", "Evening", "Night", "All Day"]
    
    //Set segment after adding an item
    var setSegment: Int?
    func changeSegment() {
        if let segment = setSegment {
            //reloadTableView()
            tabBarController?.selectedIndex = segment
            setSegment = nil
        }
    }
    
    //Footer view
    let footerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        footerView.backgroundColor = .clear
        self.tableView.tableFooterView = footerView
        
        setViewBackgroundGraphic()
        
        loadData()

        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tabBarController?.delegate = self
        self.navigationController?.delegate = self
        guard let selectedTab = tabBarController?.selectedIndex else { fatalError() }
        items = loadItems(segment: selectedTab)
        reloadTableView()
        print("Selected tab is \(selectedTab)")
        
        //load options
        loadOptions()
        
        checkIfFirstItemAdded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        changeSegment()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.items?.count ?? 0
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        guard let item = self.items?[indexPath.row] else { fatalError() }
        cell.textLabel?.text = item.title
        
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
                guard let item = self.items?[indexPath.row] else { fatalError() }
                destination.item = item
            }
        }
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadData() {
        items = realm.objects(Items.self)
    }
    
    //Filter items to relevant segment and return those items
    func loadItems(segment: Int) -> Results<Items> {
        //        guard let filteredItems = items?.filter("segment = \(segment)").sorted(byKeyPath: "dateModified", ascending: true) else { fatalError() }
        //TODO: This could probably still be more efficient. Find a way to load the items minimally
        guard let filteredItems = items?.filter("segment = \(segment)") else { fatalError() }
        print("loadItems run")
        //self.tableView.reloadData()
        return filteredItems
    }
    
    //Override empty delete func from super
    override func updateModel(at indexPath: IndexPath) {
        super.updateModel(at: indexPath)

        guard let items = self.items else { fatalError() }
        let item = items[indexPath.row]
        
        print("Deleting item with title: \(String(describing: item.title))")
        do {
            try self.realm.write {
                self.realm.delete(item)
            }
        } catch {
            print("Error deleting item: \(error)")
        }
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
    
}
