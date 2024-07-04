//
//  EmergencyContactTableViewController.swift
//  Final app project
//
//  Created by Beees on 16/5/2023.
//

import UIKit
import CoreData


class EmergencyContactTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, AddContactViewControllerDelegate, EditContactViewControllerDelegate {
   
    func didFinishEditing() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                if let cell = tableView.cellForRow(at: indexPath) as? ContactTableViewCell {
                    let contact = fetchedResultsController.object(at: indexPath)
                    cell.configure(with: contact)
                }
            }
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<EmergencyContact> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<EmergencyContact> = EmergencyContact.fetchRequest()
        
        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: (UIApplication.shared.delegate as! AppDelegate).persistentContainerEmergencyContact.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Emergency Contacts"
        
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "ContactCell")

        // Registering the cell for the tableView
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Load contacts from CoreData
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Unable to perform fetch: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload table view when the view appears
        tableView.reloadData()
    }
    
    @objc func addContact() {
        let addContactVC = AddContactViewController()
        addContactVC.delegate = self
        navigationController?.pushViewController(addContactVC, animated: true)
    }
    
    // Define the number of rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    // Define the content of each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactTableViewCell
        
        let contact = fetchedResultsController.object(at: indexPath)
        cell.configure(with: contact)
        cell.delegate = self
        
        return cell
    }
    
    @objc private func editContact(_ sender: UIButton) {
        // Determine the cell and index path
        let buttonPosition = sender.convert(CGPoint.zero, to: self.tableView)
        guard let indexPath = self.tableView.indexPathForRow(at: buttonPosition) else {
            return
        }
        
        // Fetch the contact and navigate to the editing interface
        let contact = fetchedResultsController.object(at: indexPath)
        
        let editContactVC = EditContactViewController(contact: contact)
        editContactVC.delegate = self // Set the delegate
        navigationController?.pushViewController(editContactVC, animated: true)
    }

    
    
    // height of cells
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    
    // Enable cell editing
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Handle cell deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        // Fetch Contact
        let contact = fetchedResultsController.object(at: indexPath)
        
        // Delete Contact
        fetchedResultsController.managedObjectContext.delete(contact)
        
        do {
            // Save Changes
            try fetchedResultsController.managedObjectContext.save()
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Unable to save changes after deletion: \(error.localizedDescription)")
        }
    }
    
    // Handle cell moving
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let contactToMove = fetchedResultsController.object(at: fromIndexPath)

        // Create a new contact with the desired order
        let newContact = EmergencyContact(context: fetchedResultsController.managedObjectContext)
        newContact.name = contactToMove.name
        newContact.phoneNumber = contactToMove.phoneNumber
        newContact.imageData = contactToMove.imageData

        // Delete the old contact
        fetchedResultsController.managedObjectContext.delete(contactToMove)

        do {
            try fetchedResultsController.managedObjectContext.save()
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Failed to move contact: \(error)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell, at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        @unknown default:
            fatalError()
        }
    }

    private func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let contact = fetchedResultsController.object(at: indexPath)
        
        // Set up the cell
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.clipsToBounds = true
        
        // Set the name and phone number
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = "Name: \(contact.name ?? "")\nPhone Number: \(contact.phoneNumber ?? "")"
        
        // Set the contact image
        if let imageData = contact.imageData {
            cell.imageView?.image = UIImage(data: imageData)
        }
        
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .white
    }

    // Unsubscribe from any notifications in deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // AddContactViewControllerDelegate methods
    func didAddContact() {
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Unable to fetch new contact: \(error.localizedDescription)")
        }
    }
    
    func didUpdateContact() {
        tableView.reloadData()
    }
}

extension EmergencyContactTableViewController: ContactCellDelegate {
    func didTapEditButton(in cell: ContactTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let contact = fetchedResultsController.object(at: indexPath)
        let editContactVC = EditContactViewController(contact: contact)
        editContactVC.delegate = self // Set the delegate
        navigationController?.pushViewController(editContactVC, animated: true)
    }
}
