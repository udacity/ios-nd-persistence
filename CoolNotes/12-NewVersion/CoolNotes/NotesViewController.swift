//
//  NotesViewController.swift
//  CoolNotes
//
//  Created by Fernando Rodríguez Romero on 11/03/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//

import UIKit

class NotesViewController: CoreDataTableViewController {

    var notebook : Notebook?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:  - TableView Data Source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get the note
        let note = fetchedResultsController?.object(at: indexPath) as! Note
        
        // Get the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath)
        
        // Sync note -> cell
        cell.textLabel?.text = note.text
        
        // Return the cell
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        
        
        if let context = fetchedResultsController?.managedObjectContext,
            note = fetchedResultsController?.object(at: indexPath) as? Note
            where editingStyle == .delete{
            
            context.delete(note)
            
        }
    }
    
    
 
    @IBAction func addNewNote(_ sender: AnyObject) {
        
        if let nb = notebook, context = fetchedResultsController?.managedObjectContext{

            // Just create a new note and you're done!
            let note = Note(text: "New Note", context: context)
            note.notebook = nb
            
        }
        
        
    }
    
    
    // MARK:  - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "displayNote" {
            
            
            // Get the note
            // Get the detailVC
            
            if let ip = tableView.indexPathForSelectedRow,
                note = fetchedResultsController?.object(at: ip) as? Note,
                vc = segue.destinationViewController as? NoteViewController{
                
                // Inject the note in the the detailVC
                vc.model = note
                
            }
            
        }
    }
}
