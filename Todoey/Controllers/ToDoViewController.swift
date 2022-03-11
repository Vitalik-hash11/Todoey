//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class ToDoViewController: UITableViewController {

    var itemList = [Item]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory : Category? {
        didSet {
            loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoIdentifier", for: indexPath)
        cell.textLabel?.text = itemList[indexPath.row].title
        cell.accessoryType = itemList[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //deleting
//        let removed = itemList.remove(at: indexPath.row)
//        context.delete(removed)
        itemList[indexPath.row].done = !itemList[indexPath.row].done
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - Add new action
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new todo item?", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add todo", style: .default) { (alertAction) in
            if  textField.text! != "" {
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                self.itemList.append(newItem)
                self.saveItems()
            }
        }
        
        alert.addTextField { alerttextField in
            alerttextField.placeholder = "Add new todo"
            textField = alerttextField
        }
        alert.addAction(action);
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Saving items in user defaults
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Savint itemList failed")
        }
    
        
        self.tableView.reloadData()
    }
    
    func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let savePredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [savePredicate, categoryPredicate])
        } else {
            request.predicate = categoryPredicate
        }

        do {
            itemList = try context.fetch(request)
        } catch {
            print("Fetching items from db failed")
        }
        tableView.reloadData()
    }
}

extension ToDoViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
    
        loadData(with: request, predicate: predicate)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("Cancel")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            searchBarSearchButtonClicked(searchBar)
        }
    }
}

