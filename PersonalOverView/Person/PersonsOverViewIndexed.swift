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
    @State private var isAlertActive = false
    @State private var isAlertActive1 = false

    @State private var queryString: String = ""
    
    enum SheetContent {
        case first
    }
    
    @State private var sheetContent: SheetContent = .first
    @State private var showSheet = false
    
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
                    sheetContent = .first
                    showSheet = true
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
                                                PersonDetailView(person: person)
                                                HStack {
                                                    Image(systemName: "person.crop.circle.badge.xmark")
                                                        .resizable()
                                                        .frame(width: 40, height: 33)
                                                        .font(Font.title.weight(.ultraLight))
                                                        .foregroundColor(.red)
                                                        .padding(.trailing, 0)
                                                        .gesture(
                                                            TapGesture()
                                                                .onEnded({_ in
                                                                    message = NSLocalizedString("If you delete this Person, if not available anymore.", comment: "UserOverView")
                                                                    isAlertActive.toggle()
                                                                    recordID = person.recordID
                                                                    title = NSLocalizedString("Delete Person?", comment: "UserOverView")
                                                                })
                                                        )
                                                    PersonDetailMapView(person: person)
                                                    PersonDetailPhoneView(person: person)
                                                    PersonDetailMessageView(person: person)
                                                    PersonDetailMailView(person: person)
                                                    PersonDetailCabinView(person: person)
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
                
                ///
                /// .alert for å slette en person i CloudKit
                ///
                
                .alert(title, isPresented: $isAlertActive) {
                    Button("Delete", role: .destructive, action: {
                        CloudKitPerson.deletePerson(recordID: recordID!) { (result) in
                            switch result {
                            case .success :
                                message = NSLocalizedString("Successfully deleted a Person", comment: "UserOverView")
                                isAlertActive1.toggle()
                            case .failure(let err):
                                message = err.localizedDescription
                                isAlertActive1.toggle()
                            }
                        }
                        /// Sletter den valgte raden
                        persons.remove(atOffsets: indexSetDelete)
                        refreshPersonsIndexed()

                    })
                } message: {
                    Text(message)
                }
                
                ///
                /// .alert for status fra  sletting internt i CloudKit
                ///
                
                .alert(Text("Status from CloudKit"), isPresented: $isAlertActive1) {
                    Button("OK", action: {})
                } message: {
                    Text(message)
                }
                
            } /// ScrollView
            .overlay(sectionIndexTitles(proxy: proxy, titles: sectionHeader))
        } /// ScrollViewReader
        .padding(.leading, 5)
        .sheet(isPresented: $showSheet, content: {
            switch sheetContent {
            case .first: PersonNewView()
            }
        })
        .onAppear{
            indicatorShowing = true
            refreshPersonsIndexed()
            indicatorShowing = false
        }
        
    } /// Body
    
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
    
    /// SearchBar er ikke er ikke en del av SWIFTUI i iOS 13 kom med i iOS 14
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
//                    .animation(.default)
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
