//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoViewController: SwipeTableViewController {

    var itemList: Results<Item>?
    let realm = try! Realm(queue: DispatchQueue.main)
    var selectedCategory : Category? {
        didSet {
            loadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70.0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let saveItemList = itemList {
            cell.textLabel?.text = saveItemList[indexPath.row].title
            cell.accessoryType = saveItemList[indexPath.row].done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items found"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemList?[indexPath.row] {
            do {
                try realm.write({
                    item.done = !item.done
                })
            } catch {
                print("Update item failed \(error)")
            }
            tableView.reloadData()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    //MARK: - Add new action
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new todo item?", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add todo", style: .default) { (alertAction) in
            if  textField.text! != "" {
                if let saveCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.creationDate = Date()
                            saveCategory.items.append(newItem)
                        }
                    } catch {
                        print("Saving item failed, \(error)")
                    }
                    self.tableView.reloadData()
                }
            }
        }
        
        alert.addTextField { alerttextField in
            alerttextField.placeholder = "Add new todo"
            textField = alerttextField
        }
        alert.addAction(action);
        
        present(alert, animated: true, completion: nil)
    }
    
    override func deleteItem(at indexPath: IndexPath) {
        let index = indexPath.row
        if let item = self.itemList?[index] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
            } catch {
                print("Deleting todo item failed \(error)")
            }
        }
    }
    
    
    //MARK: - Methods of manipulation with data model
    
    func loadData() {
        
        itemList = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }
}

extension ToDoViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        itemList = itemList?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "creationDate", ascending: true)
        
        tableView.reloadData()

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

