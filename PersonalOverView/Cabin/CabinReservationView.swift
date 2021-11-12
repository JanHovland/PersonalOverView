//
//  CabinReservationView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 05/03/2021.
//

import SwiftUI

struct CabinReservationView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var personInfo: PersonInfo
    
    @State private var title: String = ""
    @State private var message: String = ""
    @State private var hudMessage: String = ""
    @State private var indicatorShowing = false
    @State private var fromDatePicker = Date()
    @State private var toDatePicker = Date()

    @State private var cabin = Cabin(name: "",
                                     fromDate: 0,
                                     toDate: 0)
    
    @State private var cabinReservation = NSLocalizedString("Cabin Reservation", comment: "CabinReservationView")
    
    @State private var isAlertActive = false
    @State private var isAlertActive2 = false

    @State private var sheetContent: SheetContent = .first
    @State private var showSheet = false

    enum SheetContent {
        case first
    }
    
    var body: some View {
        HStack {
            Button(action: {
                /// Rutine for å returnere til personoversikten
                presentationMode.wrappedValue.dismiss()
            }, label: {
                ReturnFromMenuView(text: NSLocalizedString("Person overview", comment: "CabinReservationView"))
            })
            Spacer()
            Text(cabinReservation)
            Spacer()
            Button(action: {
                /// Rutine for å lagre reservasjonen
                cabin.fromDate =  DateToInt(date: fromDatePicker)
                cabin.toDate =  DateToInt(date: toDatePicker)
                SaveCabinReservation(cabin: cabin)
            }, label: {
                Text(NSLocalizedString("Store", comment: "CabinReservationView"))
                    .font(Font.headline.weight(.light))
            })
        }
        .padding()
        VStack {
            Form {
                Text(cabin.name)
                    .font(Font.title.weight(.light))
                DatePicker(
                    NSLocalizedString("From date", comment: "CabinReservationView"),
                    selection: $fromDatePicker,
                    displayedComponents: [.date]
                )
                .datePickerStyle(CompactDatePickerStyle())
                .padding(.top, 20)
                
                DatePicker(
                    NSLocalizedString("To date", comment: "CabinReservationView"),
                    selection: $toDatePicker,
                    displayedComponents: [.date]
                )
                .datePickerStyle(CompactDatePickerStyle())
                .padding(.top, 20)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showSheet, content: {
            switch sheetContent {
            case .first: HudView(hudMessage: hudMessage, backGroundColor: Color.green)
            }
        })

        .onAppear {
            cabin.name = personInfo.name
        }

        .alert(title, isPresented: $isAlertActive) {
            Button("OK", action: {})
        } message: {
            Text(message)
        }
        
    }
    
    func SaveCabinReservation(cabin: Cabin) {
        let from = cabin.fromDate
        let to = cabin.toDate
        if from <= to {
            if cabin.name.count > 0 {
                CloudKitCabin.doesCabinExist(name: cabin.name,
                                              fromDate: cabin.fromDate,
                                              toDate: cabin.toDate) { (result) in
                    if result == "OK" {
                        message = NSLocalizedString("This record was saved earlier", comment: "CabinReservationView")
                        title = NSLocalizedString("Cabin reservation", comment: "CabinReservationView")
                        isAlertActive.toggle()
                    } else {
                        CloudKitCabin.saveCabin(item: cabin) { (result) in
                            switch result {
                            case .success:
                                let message0 = NSLocalizedString("The cabin reservation for ", comment: "CabinReservationView")
                                let person1 = message0 + "'\(cabin.name)'"
                                let message1 =  NSLocalizedString("was saved", comment: "CabinReservationView")
                                title = NSLocalizedString("Cabin save in CloudKit", comment: "CabinReservationView")
                                message = person1 + " " + message1
                                hudMessage = message
                                sheetContent = .first
                                showSheet.toggle()
                            case .failure(let err):
                                title = NSLocalizedString("Error from Cabin save in CloudKit", comment: "CabinReservationView")
                                message = err.localizedDescription
                                sheetContent = .first
                                isAlertActive.toggle()
                            }
                        }
                    }
                }
            } else {
                title = NSLocalizedString("Cabin reservation", comment: "CabinReservationView")
                message = NSLocalizedString("Name must contain a value.", comment: "CabinReservationView")
                sheetContent = .first
                isAlertActive.toggle()
            }
        } else {
            title = NSLocalizedString("From date / To date", comment: "CabinReservationView")
            message = NSLocalizedString("From date must be earlier than To date.", comment: "CabinReservationView")
            sheetContent = .first
            isAlertActive.toggle()
        }
    }
    
}

///
/// Usage:  let fromDate = Date()
/// let a = DateToInt(date: fromDate)
///

func DateToInt (date: Date) -> Int {
    // Create Date Formatter
    let dateFormatter = DateFormatter()
    // Set Date Format
    dateFormatter.dateFormat = "YYYYMMdd"
    return Int(dateFormatter.string(from: date)) ?? 0
}

func IntToDateString (int: Int) -> String {
    let str = String(int)
    let index3 = str.index(str.startIndex, offsetBy: 3)
    let index4 = str.index(str.startIndex, offsetBy: 4)
    let index5 = str.index(str.startIndex, offsetBy: 5)
    let index6 = str.index(str.startIndex, offsetBy: 6)
    let month = Int(str[index4...index5]) ?? 0
    let monthName : [String] = [NSLocalizedString("jan", comment: "PersonBirthdayView"),
                                NSLocalizedString("feb", comment: "PersonBirthdayView"),
                                NSLocalizedString("mar", comment: "PersonBirthdayView"),
                                NSLocalizedString("apr", comment: "PersonBirthdayView"),
                                NSLocalizedString("may", comment: "PersonBirthdayView"),
                                NSLocalizedString("jun", comment: "PersonBirthdayView"),
                                NSLocalizedString("jul", comment: "PersonBirthdayView"),
                                NSLocalizedString("aug", comment: "PersonBirthdayView"),
                                NSLocalizedString("sep", comment: "PersonBirthdayView"),
                                NSLocalizedString("oct", comment: "PersonBirthdayView"),
                                NSLocalizedString("nov", comment: "PersonBirthdayView"),
                                NSLocalizedString("dec", comment: "PersonBirthdayView")]
   return str[index6...]  + ". " + monthName[month - 1] + " " + str[...index3]
}
