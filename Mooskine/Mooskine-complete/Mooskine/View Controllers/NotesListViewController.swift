//
//  NotesListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreData

class NotesListViewController: UIViewController, UITableViewDataSource {
    /// A table view that displays a list of notes for a notebook
    @IBOutlet weak var tableView: UITableView!

    /// The notebook whose notes are being displayed
    var notebook: Notebook!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Note>!

    /// A date formatter for date text in note cells
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Note> = Note.fetchRequest()
        let predicate = NSPredicate(format: "notebook == %@", notebook)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(notebook)-notes")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = notebook.name
        navigationItem.rightBarButtonItem = editButtonItem
        
        setupFetchedResultsController()
        
        updateEditButtonState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }

    // -------------------------------------------------------------------------
    // MARK: - Actions

    @IBAction func addTapped(sender: Any) {
        addNote()
    }

    // -------------------------------------------------------------------------
    // MARK: - Editing

    // Adds a new `Note` to the end of the `notebook`'s `notes` array
    func addNote() {
        let note = Note(context: dataController.viewContext)
        note.creationDate = Date()
        note.notebook = notebook
        try? dataController.viewContext.save()
    }

    // Deletes the `Note` at the specified index path
    func deleteNote(at indexPath: IndexPath) {
        let noteToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(noteToDelete)
        try? dataController.viewContext.save()
    }

    func updateEditButtonState() {
       navigationItem.rightBarButtonItem?.isEnabled = fetchedResultsController.sections![0].numberOfObjects > 0
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    // -------------------------------------------------------------------------
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aNote = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.defaultReuseIdentifier, for: indexPath) as! NoteCell

        // Configure cell
        cell.textPreviewLabel.attributedText = aNote.attributedText
        
        if let creationDate = aNote.creationDate {
            cell.dateLabel.text = dateFormatter.string(from: creationDate)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteNote(at: indexPath)
        default: () // Unsupported
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If this is a NoteDetailsViewController, we'll configure its `Note`
        // and its delete action
        if let vc = segue.destination as? NoteDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.note = fetchedResultsController.object(at: indexPath)
                vc.dataController = dataController

                vc.onDelete = { [weak self] in
                    if let indexPath = self?.tableView.indexPathForSelectedRow {
                        self?.deleteNote(at: indexPath)
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}

extension NotesListViewController:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}
