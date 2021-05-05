//
//  CabinOverview.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 05/03/2021.
//
import SwiftUI
import CloudKit

var selectedRecordId: CKRecord.ID?

struct CabinOverview: View {
    
    @State private var cabins = [Cabin]()
    @State private var indexSetDelete = IndexSet()
    @State private var message: String = ""
    @State private var hudMessage: String = ""
    @State private var title: String = ""
    @State private var choise: String = ""
    @State private var alertIdentifier: AlertID?
    
    @ObservedObject var sheet = SettingsSheet()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    /// Rutine for å friske opp bruker oversikten
                    refreshCabins()
                }, label: {
                    Text(NSLocalizedString("Refresh", comment: "CabinOverview"))
                        .font(Font.headline.weight(.light))
                })
            }
            .padding(.top, 20)
            .padding(.leading, 15)
            .padding(.trailing, 15)
            .padding(.bottom, -10)
            List {
                ForEach(cabins) {
                    cabin in
                    VStack (alignment: .leading) {
                        Text(cabin.name)
                            .font(Font.title.weight(.ultraLight))
                            .foregroundColor(Color("YoungPassionLight"))
                        HStack {
                            Text("\(IntToDateString(int: cabin.fromDate))")
                            Spacer()
                            Text("\(IntToDateString(int: cabin.toDate))")
                        }
//                        .background(Color.red.opacity(0.50))
                        .background(LinearGradient(gradient: Gradient(colors: [Color("YoungPassionLight"),
                                                                               Color("YoungPassionLight")]),
                                                   startPoint: .leading,
                                                   endPoint: .trailing))
                        
//                        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 251/255,
//                                                                                     green: 128/255,
//                                                                                     blue: 128/255),
//                                                                               Color(red: 251/255,
//                                                                                     green: 128/255,
//                                                                                     blue: 128/255)]),
//                                                   startPoint: .leading,
//                                                   endPoint: .trailing))
                        
                        .cornerRadius(5)
                        .padding(.horizontal)
                    }
                }
                /// onDelete finne bare i iOS
                .onDelete(perform: { indexSet in
                    indexSetDelete = indexSet
                    selectedRecordId = cabins[indexSet.first!].recordID
                    title = NSLocalizedString("Delete Reservarion?", comment: "CabinOverview")
                    message = ""
                    choise = NSLocalizedString("Delete this reservation", comment: "CabinOverview")
                    alertIdentifier = AlertID(id: .delete)
                })

            }
        }
        .sheet(isPresented: $sheet.isShowing, content: sheetContent)
        .onAppear{
            refreshCabins()
        }
        .alert(item: $alertIdentifier) { alert in
            switch alert.id {
            case .first:
                return Alert(title: Text(message))
            case .second:
                return Alert(title: Text(message))
            case .third:
                return Alert(title: Text(message))
            case .delete:
                return Alert(title: Text(title),
                             message: Text(message),
                             primaryButton: .destructive(Text(choise),
                                                         action: {
                                                            CloudKitCabin.deleteCabin(recordID: selectedRecordId!) { (result) in
                                                                switch result {
                                                                case .success :
                                                                    message =  NSLocalizedString("Successfully deleted a reservation", comment: "CabinOverview")
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
                                                            /// Sletter den valgte raden i iOS
                                                            cabins.remove(atOffsets: indexSetDelete)
                                                            
                                                         }),
                             secondaryButton: .default(Text(NSLocalizedString("Cancel", comment: "CabinOverview"))))
            }
        }

    }
    
    /// Rutine for å friske opp bildet
    func refreshCabins() {
        /// Sletter alt tidligere innhold i hytte
        cabins.removeAll()
        let predicate = NSPredicate(value: true)
        CloudKitCabin.fetchCabin(predicate: predicate)  { (result) in
            switch result {
            case .success(let cabin):
                cabins.append(cabin)
                cabins.sort(by: {$0.fromDate > $1.fromDate})
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    } /// rrefreshCabins
    
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
