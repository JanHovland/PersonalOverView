//
//  Cabin.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 03/05/2021.
//

import SwiftUI
import CloudKit

struct Cabin: Identifiable {
    var id = UUID()
    var recordID: CKRecord.ID?
    var name: String
    var fromDate: Int
    var toDate: Int
}
