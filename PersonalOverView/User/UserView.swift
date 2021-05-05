//
//  UserView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 13/12/2020.
//

import SwiftUI

struct UserView: View {
    
    @State var user1: UserRecord
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var sheet = SettingsSheet()
    @EnvironmentObject var user: User
    
    @State private var message: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var result: String = ""
    @State private var newRecord = UserRecord(name: "", email: "", password: "", image: nil)
    @State private var alertIdentifier: AlertID?
    @State private var indicatorShowing = false
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    if user1.image == nil {
                        Image(systemName: "person.circle")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .font(Font.title.weight(.ultraLight))
                    } else {
                        Image(uiImage: user1.image!)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    }
                }
                .padding(.bottom)
                Button(
                    action: {
                        Image_Select()
                    },
                    label: {
                        HStack {
                            Text(NSLocalizedString("Choose Profile Image", comment: "UserView"))
                        }
                    }
                )
                ActivityIndicator(isAnimating: $indicatorShowing, style: .medium, color: .gray)
                VStack {
                    InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                   checkPhone: false,
                                   secure: false,
                                   heading: NSLocalizedString("Your name", comment: "UserView"),
                                   placeHolder: NSLocalizedString("Enter your name", comment: "UserView"),
                                   value: $user1.name)
                        .autocapitalization(.words)
                        .padding(.bottom, 15)
                    InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                   checkPhone: false,
                                   secure: false,
                                   heading: NSLocalizedString("eMail address", comment: "UserView"),
                                   placeHolder: NSLocalizedString("Enter your email address", comment: "UserView"),
                                   value: $user1.email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.bottom, 15)
                    InputTextField(showPassword: UserDefaults.standard.bool(forKey: "showPassword"),
                                   checkPhone: false,
                                   secure: true,
                                   heading: NSLocalizedString("Password", comment: "UserView"),
                                   placeHolder: NSLocalizedString("Enter your password", comment: "UserView"),
                                   value: $user1.password)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    Spacer(minLength: 100)
                }
                .padding()
            }
        }
        .navigationBarTitle(NSLocalizedString("User maintenance", comment: "UserView"), displayMode:  .inline)
        .navigationBarItems(trailing:
                                LazyHStack {
                                    Button(action: {
                                        title = NSLocalizedString("Do you want to update this user?", comment: "UserView")
                                        message = NSLocalizedString("If you do that, the user will now contain the new values.", comment: "UserView")
                                        choise = NSLocalizedString("Update this user", comment: "UserView")
                                        result = NSLocalizedString("Successfully modified this user", comment: "UserView")
                                        /// Aktivere alert
                                        alertIdentifier = AlertID(id: .third )
                                    }, label: {
                                        Text(NSLocalizedString("Save", comment: "UserView"))
                                            .font(Font.headline.weight(.light))
                                    })
                                }
        )
        /// For å riktig visning på både iPhone og IPad:
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
        .onReceive(ImagePicker.shared.$image) { image in
            user1.image = image
        }
        .onAppear {
            if user1.name == user.name {
                let email = user1.email
                CloudKitUser.doesUserExist(email: user1.email, password: user1.password) { (result) in
                    if result != "OK" {
                        message = result
                        alertIdentifier = AlertID(id: .first)
                    } else {
                        let predicate = NSPredicate(format: "email == %@", email)
                        CloudKitUser.fetchUser(predicate: predicate) { (result) in
                            switch result {
                            case .success(let userItem):
                                if userItem.image != nil {
                                    user1.image = userItem.image!
                                }
                            case .failure(let err):
                                message = err.localizedDescription
                                alertIdentifier = AlertID(id: .first)
                            }
                        }
                    }
                }
            } else {
                let title1 = NSLocalizedString("Illegal update", comment: "UserView")
                title = title1 + "\n"
                let message1 = NSLocalizedString("You cannot update ", comment: "UserView")
                let message2 = NSLocalizedString(" because ", comment: "UserView")
                let message3 = NSLocalizedString(" is the insigned user.", comment: "UserView")
                message = message1 + user1.name + message2 + user.name + message3
                alertIdentifier = AlertID(id: .second)
                presentationMode.wrappedValue.dismiss()
            }
        }
        .modifier(DismissingKeyboard())
        /// Flytte opp feltene slik at keyboard ikke skjuler aktuelt felt
//        .modifier(AdaptsToSoftwareKeyboard())
        .alert(item: $alertIdentifier) { alert in
            switch alert.id {
            case .first:
                return Alert(title: Text(message))
            case .second:
                return Alert(title: Text(title),
                             message: Text(message))
            case .third:
                return Alert(title: Text(title),
                             message: Text(message),
                             primaryButton: .destructive(Text(choise),
                                                         action: {
                                                            if user1.name.count > 0, user1.email.count > 0, user1.password.count > 0 {
                                                                /// Starte ActivityIndicator
                                                                indicatorShowing = true
                                                                newRecord.name = user1.name
                                                                newRecord.email = user1.email
                                                                newRecord.password = user1.password
                                                                newRecord.recordID = user1.recordID
                                                                if ImagePicker.shared.image != nil {
                                                                    newRecord.image = ImagePicker.shared.image
                                                                }
                                                                /// MARK: - modify in CloudKit
                                                                CloudKitUser.modifyUser(item: newRecord) { (res) in
                                                                    switch res{
                                                                    case .success:
                                                                        /// Stop ActivityIndicator
                                                                        indicatorShowing = false
                                                                        message = result
                                                                        alertIdentifier = AlertID(id: .first)
                                                                    case .failure(let err):
                                                                        message = err.localizedDescription
                                                                        alertIdentifier = AlertID(id: .first)
                                                                    }
                                                                }
                                                            } else {
                                                                message = NSLocalizedString("Missing parameters", comment: "UserView")
                                                                alertIdentifier = AlertID(id: .first)
                                                            }
                                                         }),
                             secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "UserView"))))
            case  .delete:
                return Alert(title: Text(message))
            }
        }
    }
    
    /// Her legges det inn knytning til aktuelle view som er knyttet til et sheet
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state == .imageSelect {
            ImagePicker.shared.view
        } else {
            EmptyView()
        }
    }
    
    /// Her legges det inn aktuelel sheet.state
    func Image_Select() {
        sheet.state = .imageSelect
    }
    
}

