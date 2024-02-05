//
//  ViewController.swift
//  ZenList
//
//  Created by Zaenal Arif on 04/02/24.
//

import UIKit
import CoreData

class ZenListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadDataFromDatabase()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = itemArray[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.IdentifierKey.todoItemCell, for: indexPath)
        
        cell.accessoryType = item.done == true ? .checkmark : .none
        cell.textLabel?.text = item.title
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveDataToDatabase()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new to-do list item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { action in
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            
            self.itemArray.append(newItem)
            
            self.saveDataToDatabase()
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Core Database Methods
    
    func saveDataToDatabase() {
        do {
            try context.save()
        } catch {
            print("Error save data: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadDataFromDatabase(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error load data: \(error)")
        }
        
        tableView.reloadData()
    }
}

extension ZenListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "\(K.AttributeCoreDataKey.title) CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: K.AttributeCoreDataKey.title, ascending: true)]
        
        loadDataFromDatabase(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadDataFromDatabase()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
