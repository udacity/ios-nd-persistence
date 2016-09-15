//
//  NoteViewController.swift
//  CoolNotes
//
//  Created by Fernando Rodríguez Romero on 24/03/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//

import UIKit

// MARK: - NoteViewController: UITableViewController

class NoteViewController: UITableViewController {
    
    // MARK: Properties
    
    var model : Note?
    
    // MARK: Outlets
    
    @IBOutlet weak var relativeDateView: UILabel!
    @IBOutlet weak var dateView: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncViewsWithModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    // MARK: Sync View with Model
    
    func syncViewsWithModel() {
        
        if let model = model {
            
            // Text
            textView.text = model.text
            
            // date
            let dateFmt = DateFormatter()
            dateFmt.dateStyle = .short
            dateView.text = dateFmt.string(from: model.creationDate! as Date)
            
            // Relative date
            let relativeFmt = DateFormatter()
            relativeFmt.timeStyle = .none
            relativeFmt.dateStyle = .short
            relativeFmt.doesRelativeDateFormatting = true
            relativeFmt.locale = Locale.current
            
            relativeDateView.text = relativeFmt.string(from: model.creationDate! as Date)
        }
    }
    
    // MARK: TableView Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    /*
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        // Configure the cell...
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath],with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
 
    */
}
