//
//  VocabTableViewController.swift
//  
//
//  Created by Admin on 7/20/18.
//

import UIKit
import FirebaseDatabase
import UserNotifications
import Darwin

class VocabTableViewController: UITableViewController {
    
    var dbRef:DatabaseReference!
    var vocabs = [Vocab]()
    @IBOutlet weak var remindButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = Database.database().reference().child("vocab-items")
        startObservingDB()
       // print(vocabs.count, "count yala ")
    }
    
    func startObservingDB() ->[Vocab]{
        dbRef.observe(.value, with: { (snapshot:DataSnapshot) in
            var newVocabs = [Vocab]()
            
            for vocab in snapshot.children.allObjects {
                
                print(vocab)
                let  vocabObject = Vocab(snapshot: vocab as! DataSnapshot)
                
                newVocabs.append(vocabObject)
               
            }
            
            self.vocabs = newVocabs
            
            self.tableView.reloadData()
            
            
        }) { (error) in
            print(error.localizedDescription)
 
        }
        return self.vocabs
    }
    
    @IBAction func remindUser(_ sender: UIBarButtonItem) {
        generateNotification()
    }
    
    func checkVocabsForRemind()->Bool{
        if vocabs.count>2{
            remindButton.isEnabled = true
            return true
            
        }
        else{
            remindButton.isEnabled = false
            return false
        }
    }
    
    
    func generateNotification(){
        if checkVocabsForRemind() {
            for i in 1...3{
                let content = UNMutableNotificationContent()
                let randNo = arc4random_uniform(UInt32(self.vocabs.count))
                content.body = self.vocabs[Int(randNo)].content
                content.title = "New Word"
            
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(i*60), repeats: false)
                print(i*5)
                 let request = UNNotificationRequest(identifier: String(i), content: content, trigger: trigger)
                if(request == nil){
                    print(" request error")
                }
                if(content == nil){
                    print(" content error")
                }
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                    if error != nil{
                        print("Notification Failure ")
                    }else{
                        print("Notification Success ")
                    }
                })
            }
        }
    }
    

    @IBAction func addVocab(_ sender: Any) {
        
        let vocabAlert = UIAlertController(title: "New Vocab", message: "Enter your Vocab", preferredStyle: .alert)
        vocabAlert.addTextField { (textField:UITextField) in
            textField.placeholder = "Your Vocab"
        }
        
        vocabAlert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action:UIAlertAction) in
            if let vocabContent = vocabAlert.textFields?.first?.text {
                let vocab = Vocab(content: vocabContent, addedByUser: "user")
                let vocabRef = self.dbRef.child(vocabContent.lowercased())
                
                vocabRef.setValue(vocab.toAnyObject())
            }
        }))
        self.present(vocabAlert, animated: true, completion: nil)
        checkVocabsForRemind()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return vocabs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell_Vocab", for: indexPath)
        cell.textLabel?.text = vocabs[indexPath.row].content
    
        // Configure the cell..
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let vocab = vocabs[indexPath.row]
            vocab.itemRef?.removeValue()
            checkVocabsForRemind()
        }
    }
    


}
