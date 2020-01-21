//
//  ViewController.swift
//  TasksToDo
//
//  Created by Evneet kaur on 2020-01-19.
//  Copyright © 2020 Evneet kaur. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    @IBOutlet weak var titletxt: UITextField!
    @IBOutlet weak var daystxt: UITextField!
    @IBOutlet weak var descfeild: UITextView!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func addTasks(_ sender: UIButton) {
        
        let title = titletxt.text
        let daysneeded = Int(daystxt.text ?? "0") ?? 0
        let desc = descfeild.text
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        
        
        
        let taskentity = NSEntityDescription.insertNewObject(forEntityName: "TasksEntity", into: context)
        
        taskentity.setValue(title, forKey: "title")
        taskentity.setValue(daysneeded, forKey: "daysNeeded")
        taskentity.setValue(0, forKey: "daysAdded")
        taskentity.setValue(desc, forKey: "taskDescription")
        
        do{
            try context.save()
        }catch{
            print(error)
        }
        titletxt.text = ""
        daystxt.text = ""
        descfeild.text = ""
         
        
        
        
        
    }
    
   
    
}

