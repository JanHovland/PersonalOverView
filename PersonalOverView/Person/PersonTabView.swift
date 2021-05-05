//
//  PersonTabView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 29/01/2021.
//

import SwiftUI

/// SF Symbols 2


/// https://uigradients.com/#ByDesign     #ff5f6d   til #ffc371

struct PersonTabView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var selection = 0
    @State private var heading : [String] = [NSLocalizedString("Persons", comment: "PersonTabView"),
                                             NSLocalizedString("Birthday", comment: "PersonTabView"),
                                             NSLocalizedString("Users", comment: "PersonTabView"),
                                             NSLocalizedString("Settings", comment: "PersonTabView"),
                                             NSLocalizedString("Cabins overview", comment: "PersonTabView")]

    var body: some View {
        
        NavigationView {
            TabView(selection: $selection) {
                PersonsOverViewIndexed()
                    .tabItem {
                        Image(systemName: "person.2.circle")
                        Text(NSLocalizedString("PersonsOverview", comment: "PersonTabView"))
                    }
                    .tag(0)
                
                PersonBirthdayView()
                    .tabItem {
                        Image(systemName: "gift")
                        Text(NSLocalizedString("PersonBirthday", comment: "PersonTabView"))
                    }
                    .tag(1)
                
                UserOverViewIndexed()
                    .tabItem {
                        Image(systemName: "person.2.circle")
                        Text(NSLocalizedString("Users", comment: "PersonTabView"))
                    }
                    .tag(2)
                
                SettingView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text(NSLocalizedString("Settings", comment: "PersonTabView"))
                    }
                    .tag(3)
                CabinOverview()
                    .tabItem {
                        Image(systemName: "house")
                        Text(NSLocalizedString("Cabin overview", comment: "PersonTabView"))
                    }
                    .tag(4)
            }
            .navigationBarTitle(heading[selection], displayMode:  .inline)
            .navigationBarItems(leading:
                                    HStack {
                                        Button(action: {
                                            presentationMode.wrappedValue.dismiss()
                                        }, label: {
                                            ReturnFromMenuView(text: NSLocalizedString("SignInView", comment: "PersonTabView"))
                                        })
                                    }
            )}
    }
}

