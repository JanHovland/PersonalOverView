//
//  SignInView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 22/09/2020.
//

/// Dokumentasjon på hvordan en kan ha mange sheets
/// joemasilotti/Multiple sheets in SwiftUI.md
/// https://gist.github.com/joemasilotti/b90d89cc8e78440bf21c25ce512a72b1

import SwiftUI
import Network

struct SignInView: View {
    
    @EnvironmentObject var user: User
    @ObservedObject var sheet = SettingsSheet()
    @ObservedObject var settingsStore: SettingsStore = SettingsStore()
    
    @State private var showOptionMenu = false
    @State private var showSignUpView = false
    @State private var message: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var device = ""
    @State private var indicatorShowing = false
    @State private var hasConnectionPath = false
    
    let optionMenu = NSLocalizedString("Options Menu", comment: "SignInView")
    let internetMonitor = NWPathMonitor()
    let internetQueue = DispatchQueue(label: "InternetMonitor")
    
    var body: some View {
        
        let menuItems = ContextMenu {
            
            /// Legger inn de forskjellige menypunktene
            Button(
                action: { setting_View() },
                label: {
                    HStack {
                        Text(NSLocalizedString("Settings", comment: "SignInView"))
                        Image(systemName: "gear")
                    }
                }
            )
            
            Button(
                action: { to_Do_View() },
                label: {
                    HStack {
                        Text(NSLocalizedString("To do", comment: "SignInView"))
                        Image(systemName: "square.and.pencil")
                    }
                }
            )
            
            Button(
                action: { persons_Over_View_Indexed() },
                label: {
                    HStack {
                        Text(NSLocalizedString("Qwerty_PersonsOverview", comment: "SignInView"))
                        Image(systemName: "person.2")
                    }
                }
            )
            
            Button(
                action: { person_Birthday_View() },
                label: {
                    HStack {
                        Text(NSLocalizedString("PersonBirthday", comment: "SignInView"))
                        Image(systemName: "gift")
                    }
                }
            )
            
            Button(
                action: { user_Over_View_Indexed() },
                label: {
                    HStack {
                        Text(NSLocalizedString("Account overview", comment: "SignInView"))
                        Image(systemName: "rectangle.stack.person.crop")
                    }
                }
            )
            
        }
        VStack {
            HeadingView(heading: "Sign in CloudKit")
            PersonImageView(image: $user.image)
            /// Legger inn menu Items i .contextMenu (iOS 14)
            LazyHStack {
                Text(showOptionMenu ? optionMenu: "")
            }
            .padding()
            .foregroundColor(.accentColor)
            .contextMenu(showOptionMenu ? menuItems : nil)
            InputView(description: NSLocalizedString("Name",     comment: "InputView"), secure: false, showPassword: false, value: $user.name)
            InputView(description: NSLocalizedString("Email",    comment: "InputView"), secure: false, showPassword: false, value: $user.email)
            InputView(description: NSLocalizedString("Password", comment: "InputView"), secure: true,  showPassword: UserDefaults.standard.bool(forKey: "showPassword"), value: $user.password)
            Button(action: {
                /// Sjekker om det er forbindelse til Internett
                if hasInternet() == false {
                    if UIDevice.current.localizedModel == "iPhone" {
                        device = "iPhone"
                    } else if UIDevice.current.localizedModel == "iPad" {
                        device = "iPad"
                    }
                    let message1 = NSLocalizedString("No Internet connection for this ", comment: "SignInView")
                    message = message1 + device + "."
                    alertIdentifier = AlertID(id: .first)
                }
                else {
                    if user.email.count > 0, user.password.count > 0 {
                        /// Starter ActivityIndicator
                        indicatorShowing = true
                        /// Skjuler OptionMenu
                        showOptionMenu = false
                        let email = user.email
                        /// Check different predicates at :   https://nspredicate.xyz
                        /// %@ : an object (eg: String, date etc), whereas %i will be substituted with an integer.
                        let predicate = NSPredicate(format: "email == %@", email)
                        CloudKitUser.doesUserExist(email: user.email, password: user.password) { (result) in
                            if result != "OK" {
                                message = result
                                alertIdentifier = AlertID(id: .first)
                            } else {
                                CloudKitUser.fetchUser(predicate: predicate) { (result) in
                                    switch result {
                                    case .success(let userItem):
                                        user.email = userItem.email
                                        user.password = userItem.password
                                        user.name = userItem.name
                                        /// Avslutter x ActivityIndicator
                                        indicatorShowing = false
                                        if userItem.image != nil {
                                            user.image = userItem.image!
                                        } else {
                                            user.image = nil
                                        }
                                        user.recordID = userItem.recordID
                                        /// Viser OptionMenu
                                        showOptionMenu = true
                                        /// Kaller opp PersonsOverViewIndexed()
                                        /// persons_Over_View_Indexed()
                                        /// Kaller opp SettingView() som har retur til Innlogging
                                        setting_View()
                                    case .failure(let err):
                                        message = err.localizedDescription
                                        alertIdentifier = AlertID(id: .first)
                                    }
                                }
                            }
                        }
                    }
                    else {
                        message = NSLocalizedString("Both email and Password must have a value", comment: "SignInView")
                        alertIdentifier = AlertID(id: .first)
                    }
                    
                }
            })
            {
                Text(NSLocalizedString("Sign Up", comment: "SignInView"))
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .frame(minWidth: 300, maxWidth: 300)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(red: 251/255, green: 128/255, blue: 128/255), Color(red: 253/255, green: 193/255, blue: 104/255)]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
            }
            HStack (alignment: .center, spacing: 60) {
                Text(NSLocalizedString("Create a new account?", comment: "SignInView"))
                    .foregroundColor(.purple)
                Button(action: { sign_Up_View() },
                       label: {
                        HStack {
                            Text(NSLocalizedString("New user", comment: "SignInView"))
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.blue)
                       })
            }
            .padding(.top, 30)
            .padding(.bottom, 50)
        }
        .alert(item: $alertIdentifier) { alert in
            switch alert.id {
            case .first:
                return Alert(title: Text(message))
            case .second:
                return Alert(title: Text(message))
            case .third:
                return Alert(title: Text(message))
            case  .delete:
                return Alert(title: Text(message))
            }
        }
        .onAppear {
            startInternetTracking()
        }
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
        /// Ta bort tastaturet når en klikker utenfor feltet
        .modifier(DismissingKeyboard())
        //        /// Flytte opp feltene slik at keyboard ikke skjuler aktuelt felt
        //        .modifier(AdaptsToSoftwareKeyboard())
    }
    
    func startInternetTracking() {
        // Only fires once
        guard internetMonitor.pathUpdateHandler == nil else {
            return
        }
        internetMonitor.pathUpdateHandler = { update in
            if update.status == .satisfied {
                self.hasConnectionPath = true
            } else {
                self.hasConnectionPath = false
            }
        }
        internetMonitor.start(queue: internetQueue)
    }
    
    /// Will tell you if the device has an Internet connection
    /// - Returns: true if there is some kind of connection
    func hasInternet() -> Bool {
        return hasConnectionPath
    }
    
    /// Her legges det inn knytning til aktuelle view
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state == .settings {
            // SettingView()
            PersonTabView()
        } else if sheet.state == .toDo {
            ToDoView()
        } else if sheet.state == .personsOverviewIndexed {
            PersonsOverViewIndexed()
        } else if sheet.state == .personBirthday {
            PersonBirthdayView()
        } else if sheet.state == .acountOverviewIndexed{
            UserOverViewIndexed()
        } else if sheet.state == .signUp {
            SignUpView(returnSignIn: true)
        } else {
            EmptyView()
        }
    }
    
    /// Her legges det inn aktuelle sheet.state
    func setting_View() {
        sheet.state = .settings
    }
    
    func to_Do_View() {
        sheet.state = .toDo
    }
    
    func persons_Over_View_Indexed() {
        sheet.state = .personsOverviewIndexed
    }
    
    func person_Birthday_View() {
        sheet.state = .personBirthday
    }
    
    func user_Over_View_Indexed() {
        sheet.state = .acountOverviewIndexed
    }
    
    /// Må legge inn en ny sheet.state for å kalle "SignUpView"
    func sign_Up_View() {
        sheet.state = .signUp
    }
    
}

struct HeadingView: View {
    var heading: String
    var body: some View {
        VStack {
            Text(NSLocalizedString(heading, comment: "HeadingView"))
                .font(.headline)
                .foregroundColor(.accentColor)
                .padding()
        }
        .padding(.bottom, 30)
    }
}

struct HeaderView: View {
    var header: String
    
    var body: some View {
        VStack (alignment: .center) {
            Text(header)
                .font(Font.caption.weight(.semibold))
                .foregroundColor(.accentColor)
        }
        
    }
}

struct PersonImageView: View {
    @Binding var image: UIImage?
    var body: some View {
        VStack {
            ZStack {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 80, height: 80, alignment: .center)
                    .font(Font.title.weight(.ultraLight))
                if image != nil {
                    Image(uiImage: image!)
                        .resizable()
                        .frame(width: 80, height: 80, alignment: .center)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                }
            }
        }
        .padding(.bottom, 20)
    }
}

struct InputView: View {
    var description: String
    var secure: Bool
    var showPassword: Bool
    @Binding var value: String
    var body: some View {
        VStack {
            Text(description)
                .font(.body)
                .foregroundColor(.accentColor)
            if secure {
                if showPassword {
                    TextField(description, text: $value)
                        .multilineTextAlignment(TextAlignment.center)
                        .padding(.top, -10)
                        .padding(.bottom, 20)
                } else {
                    SecureField(description, text: $value)
                        .multilineTextAlignment(TextAlignment.center)
                        .padding(.top, -10)
                        .padding(.bottom, 20)
                }
            } else {
                TextField(description, text: $value)
                    .multilineTextAlignment(TextAlignment.center)
                    .padding(.top, -10)
                    .padding(.bottom, 20)
            }
        }
    }
}

