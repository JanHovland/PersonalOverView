//
//  PersonsOverViewIndexed.swift
//  Shared
//
//  Created by Jan Hovland on 01/12/2020.
//

// Original article here: https://www.fivestars.blog/code/section-title-index-swiftui.html

import SwiftUI
import CloudKit
import MapKit

struct PersonsOverViewIndexed: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var personInfo: PersonInfo
    
    @ObservedObject var sheet = SettingsSheet()
    @ObservedObject private var searchViewModel = SearchViewModel()
    
    @State private var persons = [Person]()
    @State private var sectionHeader = [String]()
    @State private var indexSetDelete = IndexSet()
    @State private var recordID: CKRecord.ID?
    @State private var message: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var result: String = ""
    @State private var alertIdentifier: AlertID?
    @State private var cityNumber: String = ""
    @State private var city: String = ""
    @State private var municipalityNumber: String = ""
    @State private var municipality: String = ""
    @State private var indicatorShowing = false

    var body: some View {
        ScrollViewReader { proxy in
            HStack {
                Button(action: {
                    /// Rutine for å friske opp personoversikten
                    refreshPersonsIndexed()
                }, label: {
                    Text("Refresh")
                        .font(Font.headline.weight(.light))
                })
                Spacer()
                Button(action: {
                    /// Rutine for å legge til en person
                    person_New_View()
                }, label: {
                    Text("Add")
                        .font(Font.headline.weight(.light))
                        .padding(.trailing, 10)
                })
            }
            .padding(.leading, 10)
            .padding(.trailing,10)
            .padding(.top, 10)
            .padding(.bottom, 5)
            SearchBar(text: $searchViewModel.searchText,
                      persons: $persons,
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
                                /// Her er kopligen mellom letter pg person
                                ForEach(persons.filter( {
                                    (person) -> Bool in
                                    person.firstName.prefix(1) == letter
                                })
                                )
                                { person in
                                    if searchViewModel.searchText.isEmpty || person.firstName.uppercased().contains(searchViewModel.searchText.uppercased()) {
                                        NavigationLink(destination: PersonView(person: person)) {
                                            VStack (alignment: .leading) {
                                                HStack (alignment: .center, spacing: 10) {
                                                    if person.image != nil {
                                                        Image(uiImage: person.image!)
                                                            .resizable()
                                                            .frame(width: 50, height: 50, alignment: .center)
                                                            .clipShape(Circle())
                                                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                                                    } else {
                                                        Image(systemName: "person.circle")
                                                            .resizable()
                                                            .font(.system(size: 16, weight: .ultraLight, design: .serif))
                                                            .frame(width: 50, height: 50, alignment: .center)
                                                    }
                                                    VStack (alignment: .leading, spacing: 5) {
                                                        Text(person.firstName)
                                                            .font(Font.title.weight(.ultraLight))
                                                        Text(person.lastName)
                                                            .font(Font.body.weight(.ultraLight))
                                                        Text("\(person.dateOfBirth, formatter: ShowPerson.taskDateFormat)")
                                                            .font(.custom("system", size: 17))
                                                        HStack {
                                                            Text(person.address)
                                                                .font(.custom("system", size: 17))
                                                        }
                                                        HStack {
                                                            Text(person.cityNumber)
                                                            Text(person.city)
                                                        }
                                                        .font(.custom("system", size: 17))
                                                    }
                                                } /// HStack
                                                HStack (alignment: .center, spacing: 10) {
                                                    Image(systemName: "person.crop.circle.badge.xmark")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                        .font(Font.title.weight(.ultraLight))
                                                        .foregroundColor(.red)
                                                        .padding(.trailing, 10)
                                                        .gesture(
                                                            TapGesture()
                                                                .onEnded({_ in
                                                                    /// Rutine for å slette en bruker
                                                                    recordID = person.recordID
                                                                    title = NSLocalizedString("Delete Person?", comment: "UserOverView")
                                                                    message = NSLocalizedString("If you delete this Person, if not available anymore.", comment: "UserOverView")
                                                                    choise = NSLocalizedString("Delete this Person", comment: "UserOverView")
                                                                    result = NSLocalizedString("Successfully deleted this Person", comment: "UserOverView")
                                                                    alertIdentifier = AlertID(id: .third)
                                                                })
                                                        )
                                                    Image("map")
                                                        .resizable()
                                                        .frame(width: 36, height: 36, alignment: .center)
                                                        .gesture(
                                                            TapGesture()
                                                                .onEnded({_ in
                                                                    //                                                                    https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html#//apple_ref/doc/uid/TP40007899-CH5-SW1
                                                                    mapAddress(address: person.address,
                                                                               cityNumber: person.cityNumber,
                                                                               city: person.city)
                                                                })
                                                        )
                                                    Image("phone")
                                                        /// Formatet er : tel:<phone>
                                                        .resizable()
                                                        .frame(width: 30, height: 30, alignment: .center)
                                                        .gesture(
                                                            TapGesture()
                                                                .onEnded({_ in
                                                                    if person.phoneNumber.count >= 8 {
                                                                        /// 1: Eventuelle blanke tegn må fjernes
                                                                        /// 2: Det ringes ved å kalle UIApplication.shared.open(url)
                                                                        let prefix = "tel:"
                                                                        let phoneNumber1 = prefix + person.phoneNumber
                                                                        let phoneNumber = phoneNumber1.replacingOccurrences(of: " ", with: "")
                                                                        guard let url = URL(string: phoneNumber) else { return }
                                                                        UIApplication.shared.open(url)
                                                                    } else {
                                                                        message = NSLocalizedString("Missing phonenumber", comment: "ShowPersons")
                                                                        alertIdentifier = AlertID(id: .first)
                                                                    }
                                                                })
                                                        )
                                                    Image("message")
                                                        /// Formatet er : tel:<phone><&body>
                                                        .resizable()
                                                        .frame(width: 30, height: 30, alignment: .center)
                                                        .gesture(
                                                            TapGesture()
                                                                .onEnded({ _ in
                                                                    if person.phoneNumber.count >= 8 {
                                                                        personSendSMS(person: person)
                                                                    } else {
                                                                        message = NSLocalizedString("Missing phonenumber", comment: "ShowPersons")
                                                                        alertIdentifier = AlertID(id: .first)
                                                                    }
                                                                })
                                                        )
                                                    Image("mail")
                                                        .resizable()
                                                        .frame(width: 36, height: 36, alignment: .center)
                                                        .gesture(
                                                            TapGesture()
                                                                .onEnded({ _ in
                                                                    if person.personEmail.count > 5 {
                                                                        /// Lagrer personens navn og e-post adresse i @EnvironmentObject personInfo
                                                                        personInfo.email = person.personEmail
                                                                        personInfo.name = person.firstName
                                                                        person_Send_Email_View()
                                                                    } else {
                                                                        message = NSLocalizedString("Missing personal email", comment: "ShowPersons")
                                                                        alertIdentifier = AlertID(id: .first)
                                                                    }
                                                                })
                                                        )
                                                    Image("Cabin")
                                                        .resizable()
                                                        .frame(width: 32, height: 32, alignment: .center)
                                                        .cornerRadius(4)
                                                        .gesture(
                                                            TapGesture()
                                                                .onEnded({ _ in
                                                                    if person.firstName.count > 1 {
                                                                    personInfo.name = person.firstName + " " + person.lastName
                                                                    cabin_Reservation()
                                                                    } else {
                                                                        message = NSLocalizedString("No name selected", comment: "ShowPersons")
                                                                        alertIdentifier = AlertID(id: .first)
                                                                    }
                                                                })
                                                        )
                                                }
                                                .padding(.leading, 60)
                                            }
                                        }
                                    }
                                }
                            }
                            .foregroundColor(.primary)
                            .font(Font.system(.body).bold())
                            .padding(.top,2)
                            .padding(.leading,5.0)
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
                                                                    CloudKitPerson.deletePerson(recordID: recordID!) { (result) in
                                                                        switch result {
                                                                        case .success :
                                                                            message = NSLocalizedString("Successfully deleted a  Person", comment: "UserOverView")
                                                                            alertIdentifier = AlertID(id: .first)
                                                                        case .failure(let err):
                                                                            message = err.localizedDescription
                                                                            alertIdentifier = AlertID(id: .first)
                                                                        }
                                                                    }
                                                                    /// Sletter den valgte raden
                                                                    persons.remove(atOffsets: indexSetDelete)
                                                                    refreshPersonsIndexed()
                                                                    
                                                                 }),
                                     secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "UserOverView"))))
                    case  .delete:
                        return Alert(title: Text(message))
                    }
                }
            } /// ScrollView
            .overlay(sectionIndexTitles(proxy: proxy,
                                        titles: sectionHeader))
        } /// ScrollViewReader
        .padding(.leading, 5)
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
        .onAppear{
            indicatorShowing = true
            refreshPersonsIndexed()
            indicatorShowing = false
        }
    } /// Body
    
    /// Her legges det inn knytning til aktuelle view
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state == .cabinReservation {
            CabinReservationView()
        } else if sheet.state == .newPerson {
            PersonNewView()
        } else if sheet.state == .email {
            PersonSendEmailView()
        } else {
            EmptyView()
        }
    }
    
    func person_New_View() {
        sheet.state = .newPerson
    }
    
    func person_Send_Email_View() {
        sheet.state = .email
    }
    
    func cabin_Reservation() {
        sheet.state = .cabinReservation
    }
    
    /// Rutine for å friske opp bildet
    func refreshPersonsIndexed() {
        var char = ""
        /// Sletter alt tidligere innhold i person
        persons.removeAll()
        /// slette alt innhold i sectionHeader[]
        sectionHeader.removeAll()
        /// Fetch all persons from CloudKit
        /// let predicate = NSPredicate(value: true)
        let predicate = NSPredicate(value: true)
        CloudKitPerson.fetchPerson(predicate: predicate)  { (result) in
            switch result {
            case .success(let person):
                /// Finner første bokstaven i name
                char = String(person.firstName.prefix(1))
                /// Oppdatere sectionHeader[]
                if searchViewModel.searchText.isEmpty ||
                    person.firstName.localizedCaseInsensitiveContains(searchViewModel.searchText) {
                    /// finner første bokstaven i name
                    char = String(person.firstName.prefix(1))
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
                    persons.append(person)
                    persons.sort(by: {$0.firstName < $1.firstName})
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
        
    } /// refreshPersonsIndexed
    
    /// SearchBar er ikke er ikke en del av SWIFTUI
    struct SearchBar: View {
        @Binding var text: String
        @Binding var persons:  [Person]
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
                    persons.removeAll()
                    sectionHeader.removeAll()
                    /// https://nspredicate.xyz
                    /// Fetch person.firstName who starts witn the 'text' from search
                    let predicate = NSPredicate(format:"firstName BEGINSWITH %@", value.capitalizingFirstLetter())
                    CloudKitPerson.fetchPerson(predicate: predicate)  { (result) in
                        switch result {
                        case .success(let person):
                            /// finner første bokstaven i firstName
                            char = String(person.firstName.prefix(1))
                            /// Oppdatere sectionHeader[]
                            /// Pass på at char bare legges inn en gang !!!
                            if sectionHeader.contains(char) == false {
                                sectionHeader.append(char)
                                /// Dette må gjøre for å få sectionHeader riktig sortert
                                /// Standard sortering gir ikke norsk sortering Å kommer foran A
                                let region = NSLocale.current.regionCode?.lowercased() // Returns the local region
                                let language = Locale(identifier: region!)
                                let sectionHeader1 = sectionHeader.sorted {
                                    $0.compare($1, locale: language) == .orderedAscending
                                }
                                sectionHeader = sectionHeader1
                            }
                            var exist: Bool = false
                            let number = persons.count
                            for i in 0..<number {
                                if persons[i].firstName == person.firstName {
                                    exist = true
                                }
                            }
                            if !exist {
                                persons.append(person)
                            }
                            persons.sort(by: {$0.firstName < $1.firstName})
                            indicatorShowing = false
                        case .failure(let err):
                            print(err.localizedDescription)
                        }
                    }
                }
            })
        }
    }
    
}
