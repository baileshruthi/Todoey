//
//  CategoryViewController.swift
//  Todoey
//
//  Created by iw02 on 28/02/18.
//  Copyright © 2018 iw02. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories : Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
        tableView.separatorStyle = .none
       
    }

    //MARK: - TableView Datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            
            cell.textLabel?.text = category.name //?? "No Categories Added yet"
            cell.accessoryType = .disclosureIndicator
            
            guard let categoryColour = UIColor(hexString: category.colour) else {fatalError()}
            cell.backgroundColor = categoryColour //UIColor(hexString: category.colour)?? "1D9BF6")
            cell.textLabel?.textColor = ContrastColorOf(categoryColour, returnFlat: true)
            cell.tintColor = ContrastColorOf(categoryColour, returnFlat: true)
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexpath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexpath.row]
        }
    }
    
    
    //MARK: - Add new Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat.hexValue()
            
            self.save(category: newCategory)
        }
        
        alert.addAction(action)
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Create new Category"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - TableView Data Manipulation methods
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
    }
    
    //MARK: - Delete data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        //update our data model
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
}












