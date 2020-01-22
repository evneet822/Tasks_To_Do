//
//  TaskTableViewController.swift
//  TasksToDo
//
//  Created by Evneet kaur on 2020-01-19.
//  Copyright © 2020 Evneet kaur. All rights reserved.
//

import UIKit
import CoreData

class TaskTableViewController: UITableViewController,UISearchBarDelegate {
    
    
    var contextEntity : NSManagedObjectContext?
    var tasks: [NSManagedObject]?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        
        let appdeleagte = UIApplication.shared.delegate as! AppDelegate
        let context = appdeleagte.persistentContainer.viewContext
        contextEntity = context
        
        loadCoreData()
        print("load data")
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tasks?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "tasksCell")
            cell?.textLabel?.text = tasks![indexPath.row].value(forKey: "title") as? String
        cell?.detailTextLabel?.text = "Days worked: \(tasks![indexPath.row].value(forKey: "daysAdded") as! Int)"
        cell?.backgroundColor = .white
        let addedDays = tasks![indexPath.row].value(forKey: "daysAdded") as! Int
        let neededDays = tasks![indexPath.row].value(forKey: "daysNeeded") as! Int
        if addedDays >= neededDays{
            cell?.backgroundColor = .cyan
        }
        
            return cell!
        
        

        // Configure the cell...

        
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let destination = segue.destination as? ViewController{
            if let cell = sender as? UITableViewCell{
                let taskTitle = tasks![tableView.indexPath(for: cell)!.row].value(forKey: "title") as! String
                destination.titleVC = taskTitle
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TasksEntity")
                   request.predicate = NSPredicate(format: "title contains[c] %@", searchText)
                   
                   do{
                       let result = try contextEntity?.fetch(request)
                       tasks = (result as! [NSManagedObject])
                   }catch{
                       print(error)
                   }
                   tableView.reloadData()
        if searchText == ""{
            loadCoreData()
        }
        
        
       
    
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let title = self.tasks![indexPath.row].value(forKey: "title") as! String
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TasksEntity")
        request.predicate = NSPredicate(format: "title contains %@", title)
        request.returnsObjectsAsFaults = false
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, success) in
            
            do{
                let data = try self.contextEntity?.fetch(request)
                            for ob in data as! [NSManagedObject]{
                                self.contextEntity?.delete(ob)
                                self.tasks?.remove(at: indexPath.row)
                                tableView.deleteRows(at: [indexPath], with: .fade)
            //                    print("item deleted")
                            }
                        }catch{
                            print("item not deleted")
                        }
                        
                        do {
                            try self.contextEntity?.save()
                            self.loadCoreData()
                        }catch{
                            print("not saved")
                        }
        }
        
        let shareAction = UIContextualAction(style: .normal, title: "Add Day") { (action, view, success) in
            do{
                let data = try self.contextEntity?.fetch(request)
                for ob in data as! [NSManagedObject]{
                    var days = ob.value(forKey: "daysAdded") as! Int
                    days += 1
                    ob.setValue(days, forKey: "daysAdded")
                    }
            }catch{
                print(error)
            }
            do{
                try self.contextEntity?.save()
                self.loadCoreData()
            }catch{
                print(error)
            }
            
        }
        
        shareAction.backgroundColor = .gray
        return UISwipeActionsConfiguration(actions: [deleteAction,shareAction])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCoreData()
    }
    
    
    func loadCoreData(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TasksEntity")
        
        do{
            let result = try contextEntity?.fetch(request)
            tasks = (result as! [NSManagedObject])
        }catch{
            print(error)
        }
        tableView.reloadData()
    }
    func clearCoreData(){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TasksEntity")
        
        do{
            let result = try contextEntity?.fetch(request)
            if result is [NSManagedObject]{
                for resultitem in result as! [NSManagedObject]{
                    contextEntity?.delete(resultitem)
                }
            }
        }catch{
            print(error)
        }
        do{
            try contextEntity?.save()
        }catch{
            print(error)
        }
    }
    
    
    @IBAction func sortByDate(_ sender: UIBarButtonItem) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TasksEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "taskStarted", ascending: false)]
        do{
            
            let result = try contextEntity?.fetch(request)
            tasks = (result as! [NSManagedObject])
        
        }catch{
            print(error)
        }
        tableView.reloadData()
        
    }
    
    
    @IBAction func sortByTitle(_ sender: UIBarButtonItem) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TasksEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        do{
            
            let result = try contextEntity?.fetch(request)
            tasks = (result as! [NSManagedObject])
        
        }catch{
            print(error)
        }
        tableView.reloadData()
        
    }
    
}
