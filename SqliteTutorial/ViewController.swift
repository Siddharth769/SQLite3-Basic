//
//  ViewController.swift
//  SqliteTutorial
//
//  Created by siddharth on 18/01/19.
//  Copyright © 2019 clarionTechnologies. All rights reserved.
//

import UIKit
import SQLite3

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var ratingField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var animeList = [Anime]()
    var db: OpaquePointer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("Database.sqlite")
        
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Anime (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, powerrank INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        readValues()
    }
    

    @IBAction func Save(_ sender: Any) {

        let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let powerRanking = ratingField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if(name?.isEmpty)!{
            nameField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        if(powerRanking?.isEmpty)!{
            ratingField.layer.borderColor = UIColor.red.cgColor
            return
        }
        
        var stmt: OpaquePointer?
        
        let queryString = "INSERT INTO Anime (name, powerrank) VALUES (?,?)"
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
       
        if sqlite3_bind_text(stmt, 1, name, -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 2, (powerRanking! as NSString).intValue) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding rating: \(errmsg)")
            return
        }
        
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting anime: \(errmsg)")
            return
        }
        
        nameField.text=""
        ratingField.text=""
        
        readValues()
        
        print("ANime saved successfully")
        
    }
    
  

    
    func readValues(){
        animeList.removeAll()
        
        let queryString = "SELECT * FROM Anime"
        
        var stmt:OpaquePointer?
        
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let powerrank = sqlite3_column_int(stmt, 2)
            
            animeList.append(Anime(id: Int(id), name: String(describing: name), ratings: Int(powerrank)))
        }
        
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let anime: Anime
        anime = animeList[indexPath.row]
        cell.textLabel?.text = anime.name
        cell.detailTextLabel?.text = String(anime.ratings)
        return cell
    }
}




