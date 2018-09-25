//
//  Entry.swift
//  JournalCK
//
//  Created by Cody on 9/24/18.
//  Copyright © 2018 Cody Adcock. All rights reserved.
//

import Foundation
import CloudKit

class Entry: Equatable{
    
    static func == (lhs: Entry, rhs: Entry) -> Bool{
        if lhs.title != rhs.title {return false}
        if lhs.body != rhs.body {return false}
        return true
    }
    
    static let TitleKey = "Title"
    static let BodyKey = "Body"
    static let TypeKey = "Entry"
    
    var title: String
    var body: String
    var ckRecordID: CKRecord.ID
    
    //Mark: - CK
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: Entry.TypeKey)
        record.setValue(title, forKey: Entry.TitleKey)
        record.setValue(body, forKey: Entry.BodyKey)
        return record
    }

    init(title: String, body: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.title = title
        self.body = body
        self.ckRecordID = ckRecordID
    }
    
    convenience init?(record: CKRecord){
        guard let title = record[Entry.TitleKey] as? String,
            let body = record[Entry.BodyKey] as? String else {return nil}
        
        self.init(title: title, body: body, ckRecordID: record.recordID)
    }
    
}

extension CKRecord{
    convenience init?(entry: Entry){
        self.init(recordType: Entry.TypeKey, recordID: entry.ckRecordID)
        
        self.setValue(entry.title, forKey: Entry.TitleKey)
        self.setValue(entry.body, forKey: Entry.BodyKey)
    }
}
