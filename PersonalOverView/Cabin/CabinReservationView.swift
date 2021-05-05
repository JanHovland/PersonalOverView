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
    
    @ObservedObject var sheet = SettingsSheet()
    
    @State private var message: String = ""
    @State private var hudMessage: String = ""
    
    @State private var alertIdentifier: AlertID?
    @State private var indicatorShowing = false
    @State private var fromDatePicker = Date()
    @State private var toDatePicker = Date()

    @State private var cabin = Cabin(name: "",
                                     fromDate: 0,
                                     toDate: 0)
    
    @State private var cabinReservation = NSLocalizedString("Cabin Reservation", comment: "CabinReservationView")
    
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
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
        .onAppear {
            cabin.name = personInfo.name
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
                        alertIdentifier = AlertID(id: .third)
                    } else {
                        CloudKitCabin.saveCabin(item: cabin) { (result) in
                            switch result {
                            case .success:
                                let message0 = NSLocalizedString("The cabin reservation for ", comment: "CabinReservationView")
                                let person1 = message0 + "'\(cabin.name)'"
                                let message1 =  NSLocalizedString("was saved", comment: "CabinReservationView")
                                message = person1 + " " + message1
                                hudMessage = message
                                ///
                                /// Sett opp .state direkte i stedet for å kalle med en function
                                ///
                                sheet.state = .hudView
                                // alertIdentifier = AlertID(id: .first)
                            case .failure(let err):
                                message = err.localizedDescription
                                alertIdentifier = AlertID(id: .first)
                            }
                        }
                    }
                }
            } else {
                message = NSLocalizedString("Name must contain a value.", comment: "CabinReservationView")
                alertIdentifier = AlertID(id: .first)
            }
        } else {
            message = NSLocalizedString("From date must be earlier than To date.", comment: "CabinReservationView")
            alertIdentifier = AlertID(id: .first)
        }
    }
    
    /// Her legges det inn knytning til aktuelle view
    @ViewBuilder
    private func sheetContent() -> some View {
        if sheet.state == .hudView {
            HudView(hudMessage: hudMessage,
                    backGroundColor: Color.green)
        } else {
            EmptyView()
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
