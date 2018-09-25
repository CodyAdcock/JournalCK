//
//  EntryController.swift
//  JournalCK
//
//  Created by Cody on 9/24/18.
//  Copyright © 2018 Cody Adcock. All rights reserved.
//

import Foundation
import CloudKit

class EntryController{
    
    //singleton
    static let shared = EntryController()
    
    //Source of Truth
    var entries: [Entry] = []{
        didSet{
            NotificationCenter.default.post(name: entriesWereUpdatedNotification, object: nil)
        }
    }
    
    //Create Notification
    let entriesWereUpdatedNotification = Notification.Name("EntriesWereUpdated")
    
    //CRUD
    func createEntry(title: String, body: String){
        let entry = Entry(title: title, body: body)
        saveEntryToCK(entry: entry)
    }
    
    func saveEntryToCK(entry: Entry){

        guard let entryRecord = CKRecord(entry: entry) else {return}
        CKContainer.default().privateCloudDatabase.save(entryRecord) { (record, error) in
            if let error = error{
                print("🤬 🤮 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 🤬")
                return
            }
            if let record = record {
                guard let entry = Entry(record: record) else {return}
                self.entries.append(entry)
            }
        }
    }

    //Fetch from Cloud Kit
    func fetchAllEntriesFromCloudKit(){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Entry.TypeKey, predicate: predicate)
        CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error{
                print("🤬 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 🤬")
                return
            }
            guard let records = records else {return}
            let entries = records.compactMap{Entry(record: $0)}
            self.entries = entries
        }
    }
    
    //Update
    func updateCK(entry:Entry, title:String, body:String, completion: @escaping (Bool) -> Void){
        entry.title = title
        entry.body = body
        
        CKContainer.default().privateCloudDatabase.fetch(withRecordID: entry.ckRecordID) { (record, error) in
            if let error = error{
                print("🤬 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 🤬")
                completion(false)
                return
            }
            guard let record = record else {completion(false); return}
            record[Entry.TitleKey] = title
            record[Entry.BodyKey] = body
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = {(records, recordIDS, error) in
                completion(true)
            }
            CKContainer.default().privateCloudDatabase.add(operation)
        }
        
    }
    
    //Delete
    func deleteEntry(entry: Entry){
        
        guard let index = EntryController.shared.entries.index(of: entry) else {return}
        EntryController.shared.entries.remove(at: index)
        
        CKContainer.default().privateCloudDatabase.delete(withRecordID: entry.ckRecordID) { (_, error) in
            if let error = error{
                print("🤬 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 🤬")
                return
            }else{
                print("Record Deleted from CloudKit")
            }
        }
        
    }
    
    
}
