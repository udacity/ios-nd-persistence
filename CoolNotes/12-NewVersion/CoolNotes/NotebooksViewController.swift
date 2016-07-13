//
//  NotebooksViewController.swift
//  CoolNotes
//
//  Created by Fernando Rodríguez Romero on 10/03/16.
//  Copyright © 2016 udacity.com. All rights reserved.
//

import UIKit
import CoreData

class NotebooksViewController: CoreDataTableViewController {

    
    
    @IBAction func addNewNotebook(sender: AnyObject) {
        
        // Create a new notebook... and Core Data takes care of the rest!
        let nb = Notebook(name: "New Notebook",
                          context: fetchedResultsController!.managedObjectContext)
        print("Just created a notebook: \(nb)")
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the title
        title = "CoolNotes"
        
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest(entityName: "Notebook")
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
            NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                            managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK:  - TableView Data Source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        // This method must be implemented by our subclass. There's no way
        // CoreDataTableViewController can know what type of cell we want to
        // use.
        
        
        // Find the right notebook for this indexpath
        let nb = fetchedResultsController!.objectAtIndexPath(indexPath) as! Notebook
        
        // Create the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("NotebookCell", forIndexPath: indexPath)
        
        // Sync notebook -> cell
        cell.textLabel?.text = nb.name
        cell.detailTextLabel?.text = String(format: "%d notes", nb.notes!.count)
        
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let context = fetchedResultsController?.managedObjectContext,
            noteBook = fetchedResultsController?.objectAtIndexPath(indexPath) as? Notebook
            where editingStyle == .Delete{
            
            context.deleteObject(noteBook)
            
        }

    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "displayNote"{
            
            if let notesVC = segue.destinationViewController as? NotesViewController{
                
                // Create Fetch Request
                let fr = NSFetchRequest(entityName: "Note")
 
                fr.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false),
                                      NSSortDescriptor(key: "text", ascending: true)]
                
                // So far we have a search that will match ALL notes. However, we're
                // only interested in those within the current notebook: 
                // NSPredicate to the rescue!
                let indexPath = tableView.indexPathForSelectedRow!
                let notebook = fetchedResultsController?.objectAtIndexPath(indexPath) as? Notebook
                
                let pred = NSPredicate(format: "notebook = %@", argumentArray: [notebook!])
                
                fr.predicate = pred
                
                // Create FetchedResultsController
                let fc = NSFetchedResultsController(fetchRequest: fr,
                                                    managedObjectContext:fetchedResultsController!.managedObjectContext,
                                                    sectionNameKeyPath: "humanReadableAge",
                                                    cacheName: nil)
                
                // Inject it into the notesVC
                notesVC.fetchedResultsController = fc
                
                // Inject the notebook too!
                notesVC.notebook = notebook
                
            }
        }
    }


}


















