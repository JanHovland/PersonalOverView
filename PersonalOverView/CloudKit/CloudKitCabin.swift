//
//  CloudKitHytte.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 03/05/2021.
//

import CloudKit
import SwiftUI

struct CloudKitCabin {
    struct RecordType {
        static let Cabin = "Cabin"
    }
    /// MARK: - errors
    enum CloudKitHelperError: Error {
        case recordFailure
        case recordIDFailure
        case castFailure
        case cursorFailure
    }
    
    // MARK: - check if the cabin record exists
    static func doesCabinExist(name: String,
                               fromDate: Int,
                               toDate: Int,
                               completion: @escaping (String) -> ()) {
        var result = "OK"
        
        ///
        /// https://nspredicate.xyz
        ///
        
        let predicate = NSPredicate(format: "name == %@ AND fromDate == %i AND toDate == %i", name, fromDate, toDate)
        let query = CKQuery(recordType: RecordType.Cabin, predicate: predicate)
        DispatchQueue.main.async {
            /// inZoneWith: nil : Specify nil to search the default zone of the database.
            CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil, completionHandler: { (results, er) in
                DispatchQueue.main.async {
                    let description = "\(String(describing: er))"
                    if description != "nil" {
                        if description.contains("authentication token") {
                            result = NSLocalizedString("Couldn't get an authentication token", comment: "CloudKitCabin")
                        } else if description.contains("authenticated account") {
                            result = NSLocalizedString("This request requires an authenticated account", comment: "CloudKitCabin")
                        }
                        completion(result)
                    } else {
                        if results?.count == 0 {
                            result = NSLocalizedString("This name, fromDate and toDate doesn't belong to a registered cabin", comment: "CloudKitCabin")
                        } else {
                            result = "OK"
                        }
                        completion(result)
                    }
                }
            })
        }
    }

    // MARK: - fetching from CloudKit
    /// Legg merke til følgende:
    ///     Cabin defineres slik:     Identifiable
    static func fetchCabin(predicate:  NSPredicate, completion: @escaping (Result<Cabin, Error>) -> ()) {
        
        let sort = NSSortDescriptor(key: "name", ascending: true)
        let query = CKQuery(recordType: RecordType.Cabin, predicate: predicate)
        query.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["name", "fromDate", "toDate"]
        operation.resultsLimit = 500
        operation.recordFetchedBlock = { record in
            DispatchQueue.main.async {
                let recordID = record.recordID
                /// Dersom en oppretter poster i Cabin tabellen i CloudKit Dashboard og det ikke legges inn verdier,
                /// vil feltene  fra Cabin tabellen være tomme dvs. nil
                if record["name"] == nil { record["name"] = "" }
                if record["fromDate"] == nil { record["fromDate"] = 0 }
                if record["toDate"] == nil { record["toDate"] = 0 }

                guard let name  = record["name"] as? String else { return }
                guard let fromDate  = record["fromDate"] as? Int else { return }
                guard let toDate  = record["toDate"] as? Int else { return }
                let cabin = Cabin(recordID: recordID,
                                  name: name,
                                  fromDate: fromDate,
                                  toDate: toDate)
                completion(.success(cabin))
                
            }
        }
        operation.queryCompletionBlock = { ( _, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
            }
        }
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    /// MARK: - saving to CloudKit
    static func saveCabin(item: Cabin, completion: @escaping (Result<Cabin, Error>) -> ()) {
        let cabin = CKRecord(recordType: RecordType.Cabin)
        cabin["name"] = item.name as CKRecordValue
        cabin["fromDate"] = item.fromDate as CKRecordValue
        cabin["toDate"] = item.toDate as CKRecordValue
        CKContainer.default().privateCloudDatabase.save(cabin) { (record, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
                guard let record = record else {
                    completion(.failure(CloudKitHelperError.recordFailure))
                    return
                }
                let recordID = record.recordID
                guard let name = record["name"] as? String else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let fromDate = record["fromDate"] as? Int else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                guard let toDate = record["toDate"] as? Int else {
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                
                let cabin  = Cabin(recordID: recordID,
                                   name: name,
                                   fromDate: fromDate,
                                   toDate: toDate)
                
                completion(.success(cabin))
            }
        }
    }

    // MARK: - delete cabin from CloudKit
    static func deleteCabin(recordID: CKRecord.ID, completion: @escaping (Result<CKRecord.ID, Error>) -> ()) {
        CKContainer.default().privateCloudDatabase.delete(withRecordID: recordID) { (recordID, err) in
            DispatchQueue.main.async {
                if let err = err {
                    completion(.failure(err))
                    return
                }
                guard let recordID = recordID else {
                    completion(.failure(CloudKitHelperError.recordIDFailure))
                    return
                }
                completion(.success(recordID))
            }
        }
    }
    
    // MARK: - modify in CloudKit
    static func modifyCabin(item: Cabin, completion: @escaping (Result<Cabin, Error>) -> ()) {
        guard let recordID = item.recordID else { return }
        CKContainer.default().privateCloudDatabase.fetch(withRecordID: recordID) { record, err in
            if let err = err {
                DispatchQueue.main.async {
                    completion(.failure(err))
                }
                return
            }
            guard let record = record else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitHelperError.recordFailure))
                }
                return
            }
            record["name"] = item.name as CKRecordValue
            record["fromDate"] = item.fromDate as CKRecordValue
            record["toDate"] = item.toDate as CKRecordValue
            
            CKContainer.default().privateCloudDatabase.save(record) { (record, err) in
                DispatchQueue.main.async {
                    if let err = err {
                        completion(.failure(err))
                        return
                    }
                    guard let record = record else {
                        completion(.failure(CloudKitHelperError.recordFailure))
                        return
                    }
                    let recordID = record.recordID
                    guard let name = record["name"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let fromDate = record["fromDate"] as? Int else {
                        
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let toDate = record["toDate"] as? Int else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    
                    let cabin = Cabin(recordID: recordID,
                                      name: name,
                                      fromDate: fromDate,
                                      toDate: toDate)
                    
                    completion(.success(cabin))
                }
            }
        }
    }
    
    // MARK: - delete all cabins from CloudKit
    static func deleteAllCabins() {
        let privateDb =  CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "Cabin", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        var counter = 0
        privateDb.perform(query, inZoneWith: nil) { (records, error) in
            if error == nil {
                for record in records! {
                    privateDb.delete(withRecordID: record.recordID, completionHandler: { (recordId, error) in
                        if error == nil {
                            _ = 0
                        }
                    })
                    counter += 1
                }
                let message1 = NSLocalizedString("Records deleted:", comment: "CloudKitCabin")
                let _ = message1 + " " + "\(counter)"
            } else {
                let _ = error!.localizedDescription
            }
        }
    }

}
