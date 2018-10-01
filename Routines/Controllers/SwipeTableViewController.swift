//
//  SwipeTableViewController.swift
//  Routines
//
//  Created by Donavon Buchanan on 9/29/18.
//  Copyright © 2018 Donavon Buchanan. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SwipeTableViewCell
        
        //SwipeTableViewCell delegate
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil}
        
        let completeAction = SwipeAction(style: .destructive, title: "Complete") { (action, indexPath) in
            // handle action by updating model with deletion
            self.updateModel(at: indexPath)
            //action.fulfill(with: .reset)
            //tableView.reloadData()
            //editActionsOptionsForRowAt takes care of the table reload
        }
        
        let snoozeAction = SwipeAction(style: .default, title: "Snooze") { (action, indexPath) in
            //handle snooze
            self.snoozeItem(at: indexPath)
        }
        
        //customize the action appearance
//        completeAction.image = UIImage(named: "completed")
        completeAction.backgroundColor = UIColor.init(displayP3Red:0.15,green:0.56,blue:0.25,alpha:1.00)
        snoozeAction.backgroundColor = .orange
        
        return [completeAction, snoozeAction]
    }

    //continue dragging to delete
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func updateModel(at indexPath: IndexPath) {
        //Update data model
    }
    
    func snoozeItem(at indexPath: IndexPath) {
        //Update data model to snooze
    }

}