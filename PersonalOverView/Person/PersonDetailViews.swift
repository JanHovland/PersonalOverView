//
//  PersonDetailViews.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 18/10/2021.
//

/// https://serialcoder.dev/?s=sheet

import SwiftUI
import CloudKit

struct PersonDetailPersonView: View {
    var person: Person
    var body: some View {
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
        }
    }
}

struct PersonDetailMapView: View {
    var person: Person
    var body: some View {
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
    }
}

struct PersonDetailPhoneView: View {
    var person: Person
    @State private var message: String = ""
    @State private var isAlertActive = false
    
    var body: some View {
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
                            isAlertActive.toggle()
                        }
                    })
            )
//            .alert(Text("Phonenumber"), isPresented: $isAlertActive) {
//                Button("OK", action: {})
//            } message: {
//                Text(message)
//            }
    }
}

struct PersonDetailMessageView: View {
    var person: Person
    @State private var message: String = ""
    @State private var isAlertActive = false
    
    var body: some View {
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
                            message = NSLocalizedString("Missing phonenumber", comment: "ExtractedMessageView")
                            isAlertActive.toggle()
                        }
                    })
            )
//            .alert(Text("Phonenumber"), isPresented: $isAlertActive) {
//                Button("OK", action: {})
//            } message: {
//                Text(message)
//            }
    }
}

struct PersonDetailMailView: View {
    var person: Person
    @State private var message: String = ""
    @State private var isAlertActive = false
    @EnvironmentObject var personInfo: PersonInfo
    //    @ObservedObject var sheet = SettingsSheet()  SKRIV OM ALLE STEDER DENNE FOREKOMMER
    
    enum SheetContent {
        case first
    }
    
    @State private var sheetContent: SheetContent = .first
    @State private var showSheet = false
    
    var body: some View {
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
                            ///  Starter opp PersonSendEmailView()
                            sheetContent = .first
                            showSheet = true
                        } else {
                            message = NSLocalizedString("Missing personal email", comment: "ShowPersons")
                            isAlertActive.toggle()
                        }
                    })
            )
//            .alert(Text("Mail"), isPresented: $isAlertActive) {
//                Button("OK", action: {})
//            } message: {
//                Text(message)
//            }
            .sheet(isPresented: $showSheet, content: {
                switch sheetContent {
                case .first: PersonSendEmailView()
                }
            })
    }
}

struct PersonDetailCabinView: View {
    var person: Person
    @State private var message: String = ""
    @State private var isAlertActive = false
    @EnvironmentObject var personInfo: PersonInfo
    
    enum SheetContent {
        case first
    }
    
    @State private var sheetContent: SheetContent = .first
    @State private var showSheet = false
    
    var body: some View {
        Image("Cabin")
            .resizable()
            .frame(width: 32, height: 32, alignment: .center)
            .cornerRadius(4)
            .gesture(
                TapGesture()
                    .onEnded({ _ in
                        if person.firstName.count > 1 {
                            personInfo.name = person.firstName + " " + person.lastName
                            /// Starter opp CabinReservationView()
                            sheetContent = .first
                            showSheet = true
                        } else {
                            message = NSLocalizedString("No name selected", comment: "ShowPersons")
                            isAlertActive.toggle()
                        }
                    })
            )
//            .alert(Text("Cabin"), isPresented: $isAlertActive) {
//                Button("OK", action: {})
//            } message: {
//                Text(message)
//            }
            .sheet(isPresented: $showSheet, content: {
                switch sheetContent {
                case .first: CabinReservationView()
                }
            })
    }
}

