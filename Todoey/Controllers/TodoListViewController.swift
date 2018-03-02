//
//  ViewController.swift
//  Todoey
//
//  Created by iw02 on 26/02/18.
//  Copyright © 2018 iw02. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController{
    
    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? {
        didSet{
            loadItems()
        }
        
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        guard let colourHex = selectedCategory?.colour else {fatalError()}
        updateNavBar(withHexCode: colourHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar(withHexCode colourHexCode: String){
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller doesnot exists")}
        guard let navBarColour = UIColor(hexString: colourHexCode) else{fatalError()}
        
        navBar.barTintColor = navBarColour
        navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColour, returnFlat: true)]
        searchBar.barTintColor = navBarColour
        
        //Remove border from search bar
        navBar.backgroundImage(for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        navBar.shadowImage = UIImage()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        
    }
    
    //MARK: - TableView Datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            //condition to execute percentage tinting colour to the cells
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage:CGFloat(indexPath.row)/CGFloat(todoItems!.count) * 0.35){
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
                cell.tintColor = ContrastColorOf(colour, returnFlat: true)
                }

//                print("version 1: \(CGFloat(indexPath.row / todoItems!.count))")
//                print("version 2: \(CGFloat(indexPath.row) / CGFloat(todoItems!.count))")

            // Terenary operator
            cell.accessoryType = item.done ? .checkmark : .none
        }else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    // realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        tableView.reloadData()
        
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
//        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
//             tableView.cellForRow(at: indexPath)?.accessoryType = .none
//        } else {
//             tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark     --> toggling
//        }
        
//        todoItems[indexPath.row].done = !todoItems[indexPath.row].done
//
//        saveitems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new item Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            //what will happen once the user clicks the Add item button UIAlert
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
         // Add Textfield to PopUp
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
            
        }
        // Add Button to PopUp
        alert.addAction(action)
        // "Init" PopUp with Button
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Model Manipulation methods
    
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
}

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }

//        let request : NSFetchRequest<Item> = Item.fetchRequest()
//
//        let predicate = NSPredicate(format:"title CONTAINS[cd] %@", searchBar.text!)
//
//        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//
//        loadItems(with: request, predicate: predicate)
   

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }

}

