//
//  NotesViewController.swift
//  CoolNotes
//
//  Created by Fernando Rodríguez Romero on 11/03/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//

import UIKit

// MARK: - NotesViewController: CoreDataTableViewController

class NotesViewController: CoreDataTableViewController {

    // MARK: Properties
    
    var notebook: Notebook?
    
    // MARK: TableView Data Source
    
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if let context = fetchedResultsController?.managedObjectContext, let note = fetchedResultsController?.object(at: indexPath) as? Note, editingStyle == .delete {
            context.delete(note)
        }
    }
    
    // MARK: Add Note
    
    @IBAction func addNewNote(_ sender: AnyObject) {
        
        if let nb = notebook, let context = fetchedResultsController?.managedObjectContext {
            // Just create a new note and you're done!
            let note = Note(text: "New Note", context: context)
            note.notebook = nb
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "displayNote" {
            
            // Get the note
            // Get the detailVC
            
            if let ip = tableView.indexPathForSelectedRow, let note = fetchedResultsController?.object(at: ip) as? Note, let vc = segue.destination as? NoteViewController {
                
                // Inject the note in the the detailVC
                vc.model = note
            }
        }
    }
}
