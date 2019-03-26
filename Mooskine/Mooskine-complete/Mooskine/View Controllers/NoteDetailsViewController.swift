//
//  NoteDetailsViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreData

class NoteDetailsViewController: UIViewController {
    /// A text view that displays a note's text
    @IBOutlet weak var textView: UITextView!

    /// The note being displayed and edited
    var note: Note!
    
    var dataController:DataController!
    
    var saveObserverToken: Any?

    /// A closure that is run when the user asks to delete the current note
    var onDelete: (() -> Void)?

    /// A date formatter for the view controller's title text
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    /// The accessory view used when displaying the keyboard
    var keyboardToolbar: UIToolbar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let creationDate = note.creationDate {
            navigationItem.title = dateFormatter.string(from: creationDate)
        }
        textView.attributedText = note.attributedText
        
        // keyboard toolbar configuration
        configureToolbarItems()
        configureTextViewInputAccessoryView()
        
        addSaveNotificationObserver()
    }
    
    deinit {
        removeSaveNotificationObserver()
    }

    @IBAction func deleteNote(sender: Any) {
        presentDeleteNotebookAlert()
    }
}

// -----------------------------------------------------------------------------
// MARK: - Editing

extension NoteDetailsViewController {
    func presentDeleteNotebookAlert() {
        let alert = UIAlertController(title: "Delete Note", message: "Do you want to delete this note?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: deleteHandler))
        present(alert, animated: true, completion: nil)
    }

    func deleteHandler(alertAction: UIAlertAction) {
        onDelete?()
    }
}

// -----------------------------------------------------------------------------
// MARK: - UITextViewDelegate

extension NoteDetailsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        note.attributedText = textView.attributedText
        try? dataController.viewContext.save()
    }
}

// MARK: - Toolbar

extension NoteDetailsViewController {
    /// Returns an array of toolbar items. Used to configure the view controller's
    /// `toolbarItems' property, and to configure an accessory view for the
    /// text view's keyboard that also displays these items.
    func makeToolbarItems() -> [UIBarButtonItem] {
        let trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped(sender:)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let bold = UIBarButtonItem(image: #imageLiteral(resourceName: "toolbar-bold"), style: .plain, target: self, action: #selector(boldTapped(sender:)))
        let red = UIBarButtonItem(image: #imageLiteral(resourceName: "toolbar-underline"), style: .plain, target: self, action: #selector(redTapped(sender:)))
        let cow = UIBarButtonItem(image: #imageLiteral(resourceName: "toolbar-cow"), style: .plain, target: self, action: #selector(cowTapped(sender:)))
        
        return [space, trash, space, bold, space, red, space, cow, space]
    }
    
    /// Configure the current toolbar
    func configureToolbarItems() {
        toolbarItems = makeToolbarItems()
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    /// Configure the text view's input accessory view -- this is the view that
    /// appears above the keyboard. We'll return a toolbar populated with our
    /// view controller's toolbar items, so that the toolbar functionality isn't
    /// hidden when the keyboard appears
    func configureTextViewInputAccessoryView() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        toolbar.items = makeToolbarItems()
        textView.inputAccessoryView = toolbar
    }
    
    @IBAction func deleteTapped(sender: Any) {
        showDeleteAlert()
    }
    
    @IBAction func boldTapped(sender: Any) {
        let newText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        newText.addAttribute(.font, value: UIFont(name: "OpenSans-Bold", size: 22) as Any, range: textView.selectedRange)
        
        let selectedTextRange = textView.selectedTextRange
        
        textView.attributedText = newText
        textView.selectedTextRange = selectedTextRange
        note.attributedText = textView.attributedText
        ((try? dataController?.viewContext.save()) as ()??)
    }
    
    @IBAction func redTapped(sender: Any) {
        let newText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.red,
            .underlineStyle: 1,
            .underlineColor: UIColor.red
        ]
        newText.addAttributes(attributes, range: textView.selectedRange)
        
        let selectedTextRange = textView.selectedTextRange
        
        textView.attributedText = newText
        textView.selectedTextRange = selectedTextRange
        note.attributedText = textView.attributedText
        try? dataController?.viewContext.save()
    }
    
    @IBAction func cowTapped(sender: Any) {
        let backgroundContext:NSManagedObjectContext! = dataController?.backgroundContext
        
        let newText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        
        let selectedRange = textView.selectedRange
        let selectedText = textView.attributedText.attributedSubstring(from: selectedRange)
        
        let noteID = note.objectID
        
        dataController?.backgroundContext.perform {
            let backgroundNote = backgroundContext.object(with: noteID) as! Note
            
            let cowText = Pathifier.makeMutableAttributedString(for: selectedText, withFont: UIFont(name: "AvenirNext-Heavy", size: 56)!, withPatternImage: #imageLiteral(resourceName: "texture-cow"))
            
            sleep(5)
            
            newText.replaceCharacters(in: selectedRange, with: cowText)
            
            backgroundNote.attributedText = newText
            try? backgroundContext.save()
        }
    }
    
    // MARK: Helper methods for actions
    private func showDeleteAlert() {
        let alert = UIAlertController(title: "Delete Note?", message: "Are you sure you want to delete the current note?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.onDelete?()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
}

extension NoteDetailsViewController {

    func addSaveNotificationObserver() {
        removeSaveNotificationObserver()
        saveObserverToken = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: dataController?.viewContext, queue: nil, using: handleSaveNotification(notification:))
    }
    
    func removeSaveNotificationObserver() {
        if let token = saveObserverToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    fileprivate func reloadText() {
        textView.attributedText = note.attributedText
    }
    
    func handleSaveNotification(notification:Notification) {
        DispatchQueue.main.async {
            self.reloadText()
        }
    }
}

