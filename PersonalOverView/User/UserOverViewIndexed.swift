//
//  UserOverViewIndexed.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 13/12/2020.
//

import SwiftUI
import CloudKit

struct UserOverViewIndexed: View {
    
    @EnvironmentObject var user: User
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject private var searchViewModel = SearchViewModel()
    
    /// Skjuler scroll indicators.
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    @State private var UserOverView = NSLocalizedString("UserOverView", comment: "UserOverViewIndexed")
    @State private var users = [UserRecord]()
    @State private var message: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var result: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var indexSetDelete = IndexSet()
    @State private var recordID: CKRecord.ID?
    @State private var sectionHeader = [String]()
    @State private var indicatorShowing = false

    var body: some View {
        ScrollViewReader { proxy in
            HStack {
                Button(action: {
                    /// Rutine for å friske opp bruker oversikten
                    refreshUsersIndexed()
                }, label: {
                    Text(NSLocalizedString("Refresh", comment: "UserOverViewIndexed"))
                        .font(Font.headline.weight(.light))
                })
                Spacer()
            }
            .padding(.leading, 10)
            .padding(.trailing,10)
            .padding(.top, 10)
            .padding(.bottom, 5)
            SearchBar(text: $searchViewModel.searchText,
                      users: $users,
                      sectionHeader: $sectionHeader,
                      indicatorShowing: $indicatorShowing)
                .keyboardType(.asciiCapable)
                .padding(.trailing, 10)
                .padding(.bottom, 10)
            ScrollView {
                VStack (alignment: .center) {
                    /// ActivityIndicator setter opp en ekstra tom linje for seg selv
                    ActivityIndicator(isAnimating: $indicatorShowing, style: .medium, color: .gray)
                }
                LazyVStack (alignment: .leading) {
                    ForEach(sectionHeader, id: \.self) { letter in
                        ///
                        /// Skal bare gå videre dersom personSearchViewModel.isSearchValid == true
                        /// Dette medfører at sectionHeader har riktig verdi ut fra searchText
                        ///
                        if searchViewModel.isSearchValid {
                            Section(header: SectionHeader(letter: letter)) {
                                ForEach(users.filter( {
                                    (user1) -> Bool in
                                    user1.name.prefix(1) == letter
                                })) {
                                    user1 in
                                    /// Viser aktuelle brukere
                                    if searchViewModel.searchText.isEmpty || user1.name.uppercased().contains(searchViewModel.searchText.uppercased()) {
                                        NavigationLink(destination: UserView(user1: user1)) {
                                            VStack (alignment: .leading) {
                                                HStack (alignment: .center, spacing: 10) {
                                                    Image(systemName: "person.crop.circle.badge.xmark")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                        .font(Font.title.weight(.ultraLight))
                                                        .foregroundColor(.red)
                                                        .gesture(
                                                            TapGesture()
                                                                .onEnded({_ in
                                                                    /// Rutine for å slette en bruker
                                                                    recordID = user1.recordID
                                                                    title = NSLocalizedString("Delete User?", comment: "UserOverViewIndexed")
                                                                    message = NSLocalizedString("If you delete this user, if not available anymore.", comment: "UserOverViewIndexed")
                                                                    choise = NSLocalizedString("Delete this user", comment: "UserOverViewIndexed")
                                                                    result = NSLocalizedString("Successfully deleted this user", comment: "UserOverViewIndexed")
                                                                    alertIdentifier = AlertID(id: .third)
                                                                })
                                                        )
                                                        .padding(.trailing, 10)
                                                    if user1.image != nil {
                                                        Image(uiImage: user1.image!)
                                                            .resizable()
                                                            .frame(width: 50, height: 50, alignment: .center)
                                                            .clipShape(Circle())
                                                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                                    } else {
                                                        Image(systemName: "person.circle")
                                                            .resizable()
                                                            .font(.system(size: 16, weight: .ultraLight))
                                                            .frame(width: 50, height: 50, alignment: .center)
                                                    }
                                                    /// Skal kun fremheve  navn og e-post for pålogget bruker
                                                    VStack (alignment: .leading, spacing: 5) {
                                                        Text(user1.name)
                                                            .font(Font.title.weight(.ultraLight))
                                                        Text(user1.email)
                                                            .font(Font.body.weight(.ultraLight))
                                                    }
                                                    Spacer()
                                                } /// HStack
                                                .padding(5)
                                            } /// VStack
                                        }
                                        
                                    } /// NavigationLInk
                                }
                            } /// Section
                            .foregroundColor(.primary)
                            .font(Font.system(.body).bold())
                            .padding(.top,2)
                            .padding(.leading,5)
                            .padding(.bottom,2)
                        }  /// if searchViewModel.isSearchValid
                    }
                }
                .alert(item: $alertIdentifier) { alert in
                    switch alert.id {
                    case .first:
                        return Alert(title: Text(message))
                    case .second:
                        return Alert(title: Text(message))
                    case .third:
                        return Alert(title: Text(title),
                                     message: Text(message),
                                     primaryButton: .destructive(Text(choise),
                                                                 action: {
                                                                    CloudKitUser.deleteUser(recordID: recordID!) { (result) in
                                                                        switch result {
                                                                        case .success :
                                                                            message = NSLocalizedString("Successfully deleted an user", comment: "UserOverViewIndexed")
                                                                            alertIdentifier = AlertID(id: .first)
                                                                        case .failure(let err):
                                                                            message = err.localizedDescription
                                                                            alertIdentifier = AlertID(id: .first)
                                                                        }
                                                                    }
                                                                    /// Sletter den valgte raden
                                                                    users.remove(atOffsets: indexSetDelete)
                                                                    refreshUsersIndexed()
                                                                    
                                                                 }),
                                     secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "UserOverViewIndexed"))))
                    case  .delete:
                        return Alert(title: Text(message))
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .navigationBarTitle(UserOverView, displayMode: .inline)
            } /// ScrollView
            .overlay(sectionIndexTitles(proxy: proxy,
                                        titles: sectionHeader))
        } // ScrollViewReader
        .padding(.leading, 5)
        .onAppear(perform: {
            indicatorShowing = true
            refreshUsersIndexed()
            indicatorShowing = false
        })
    } /// Body
    
    /// Rutine for å friske opp bildet
    func refreshUsersIndexed() {
        var char = ""
        /// Sletter alt tidligere innhold i users
        users.removeAll()
        sectionHeader.removeAll()
        /// Fetch all users from CloudKit
        /// let predicate = NSPredicate(value: true)
        let predicate = NSPredicate(value: true)
        CloudKitUser.fetchUser(predicate: predicate)  { (result) in
            switch result {
            case .success(let user):
                /// Finner første bokstaven i name
                char = String(user.name.prefix(1))
                /// Oppdatere sectionHeader[]
                if searchViewModel.searchText.isEmpty ||
                    user.name.localizedCaseInsensitiveContains(searchViewModel.searchText) {
                    /// finner første bokstaven i name
                    char = String(user.name.prefix(1))
                    /// Oppdatere sectionHeader[]
                    if sectionHeader.contains(char) == false {
                        sectionHeader.append(char)
                        /// Dette må gjøre for å få sectionHeader riktig sortert
                        /// Standard sortering gir ikke norsk sortering
                        let region = NSLocale.current.regionCode?.lowercased() // Returns the local region
                        let language = Locale(identifier: region!)
                        let sectionHeader1 = sectionHeader.sorted {
                            $0.compare($1, locale: language) == .orderedAscending
                        }
                        sectionHeader = sectionHeader1
                    }
                    users.append(user)
                    users.sort(by: {$0.name < $1.name})
                }
            case .failure(let err):
                message = err.localizedDescription
                alertIdentifier = AlertID(id: .first)
            }
        }
    } /// func refreshUsersIndexed
    
    /// SearchBar er ikke er ikke en del av SWIFTUI
    struct SearchBar: View {
        @Binding var text: String
        @Binding var users:  [UserRecord]
        @Binding var sectionHeader: [String]
        @Binding var indicatorShowing: Bool
        
        @State private var isEditing = false
        
        var body: some View {
            HStack {
                TextField(NSLocalizedString("Search...", comment: "SearchBar"), text: $text)
                    .padding(7)
                    .padding(.horizontal, 25)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, alignment: .leading)
                                .padding(.leading, 8)
                            
                            if isEditing {
                                Button(action: {
                                    text = ""
                                }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                    )
                    .padding(.horizontal, 10)
                    .onTapGesture {
                        isEditing = true
                    }
                
                if isEditing {
                    Button(action: {
                        isEditing = false
                        text = ""
                    }) {
                        Text(NSLocalizedString("Cancel", comment: "SearchBar"))
                    }
                    .padding(.trailing, 10)
                    .transition(.move(edge: .trailing))
                    .animation(.default)
                }
            }
            .onChange(of: text, perform: { value in
                if value.count > 0 || value.isEmpty {
                    var char = ""
                    indicatorShowing = true
                    /// Sletter alt tidligere innhold i users
                    users.removeAll()
                    sectionHeader.removeAll()
                    /// https://nspredicate.xyz
                    /// Fetch person.firstName who starts witn the 'text' from search
                    let predicate = NSPredicate(format:"name BEGINSWITH %@", value.capitalizingFirstLetter())
                    CloudKitUser.fetchUser(predicate: predicate)  { (result) in
                        switch result {
                        case .success(let user):
                            /// finner første bokstaven i name
                            char = String(user.name.prefix(1))
                            /// Oppdatere sectionHeader[]
                            /// Pass på at char bare legges inn en gang !!!
                            if sectionHeader.contains(char) == false {
                                sectionHeader.append(char)
                                /// Dette må gjøre for å få sectionHeader riktig sortert
                                /// Standard sortering gir ikke norsk sortering
                                let region = NSLocale.current.regionCode?.lowercased() // Returns the local region
                                let language = Locale(identifier: region!)
                                let sectionHeader1 = sectionHeader.sorted {
                                    $0.compare($1, locale: language) == .orderedAscending
                                }
                                sectionHeader = sectionHeader1
                            }
                            var exist: Bool = false
                            let number = users.count
                            for i in 0..<number {
                                if users[i].name == user.name {
                                    exist = true
                                }
                            }
                            if !exist {
                                users.append(user)
                            }
                            users.sort(by: {$0.name < $1.name})
                            indicatorShowing = false
                        case .failure(let err):
                            print(err.localizedDescription)
                        }
                    }
                } else {
                    users.removeAll()
                    sectionHeader.removeAll()
                }
            })
        }
    }
    
} /// struct UserOverViewIndexed
