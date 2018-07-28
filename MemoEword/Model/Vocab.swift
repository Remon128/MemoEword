//
//  User.swift
//  MemoEword
//
//  Created by Admin on 7/22/18.
//  Copyright © 2018 Admin. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Vocab{
    let key:String
    let content:String
    let addedByUser:String!
    let itemRef:DatabaseReference?
    
    init(content:String, addedByUser:String, key:String = ""){
        self.key = key
        self.content = content
        self.addedByUser = addedByUser
        self.itemRef = nil
    }
    
    init(snapshot:DataSnapshot){
        key = snapshot.key
        itemRef = snapshot.ref
        let vocabObject = snapshot.value as? [String: AnyObject]
        
        if let vocabContent = vocabObject?["content"] as? String{
            content = vocabContent
            print(content , " xxxxxxx ")
        }else {
            content = ""
        }
        
        if let vocabUser = vocabObject?["addedByUser"] as? String{
            addedByUser = vocabUser
        }else {
            addedByUser = ""
        }
    }
    
    func toAnyObject()->AnyObject{
        return ["content":content, "addedByUser":addedByUser] as NSDictionary
    }
    
}
