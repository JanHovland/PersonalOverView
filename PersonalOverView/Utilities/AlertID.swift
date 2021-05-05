//
//  AlertID.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 22/09/2020.
//

import SwiftUI

struct AlertID: Identifiable {
    enum Choice {
        case first, second, third, delete
    }

    var id: Choice
}
