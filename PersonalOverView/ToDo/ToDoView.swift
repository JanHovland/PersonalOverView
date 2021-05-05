//
//  ToDoView.swift
//  PersonalOverView
//
//  Created by Jan Hovland on 24/09/2020.
//

import SwiftUI

var toDo_1 =
    """

    i O S :

    1. 🛑 x


    m a c O S :

    1. 🛑 Hjelp under macOS
    2. 🛑 Oppdatere menyer

"""

var toDo_2 =
    """
F e r d i g
 
"""

var toDo_3 =
    """

  1. 🟢 "Ny bruker" ikke aktiv. Må bruke den den nye måten å kalle .sheet på
  2. 🟢 Gå gjennom SignUpView()
  3. 🟢 UserMaintenanceView()
        a) Lagt inn ImagePicker.
  4. 🟢 ImagePicker.shared.imageFileURL
        a) SignInView()
        b) SignUpView()
        c) UserMaintenanceView()
        d) CloudKitUser()
  5. 🟢 Gå gjennom UserDeleteUser()
  6. 🟢 SettingsView()
        a) Etter å ha valgt en opsjon vises ikke denne korrekt.
           Men programmet reagerer korrekt!
           FEILEN kommer når en velger .pickerStyle(DefaultPickerStyle())
           OK når det byttes til .pickerStyle(SegmentedPickerStyle())
        b) Sjekk postnummer
           . ParseCSV virker dersom delimiter settes til "    " = 4 mellomrom
           . sletting
           . oppdatering
  7. 🟢 Gå gjennom PersonView()
  8. 🟢 Gå gjennom PersonsOverView()
  9. 🟢 Fikk problemer med tabellen PostalCode etter å ha slettet den.
        Opprettet derfor e ny tabell PostNummer og endret i kildekoden.
 10. 🟢 Postnummerregister-ansi.txt
        a) Tas nå direkte fra https://www.bring.no/tjenester/adressetjenester/postnummer
        b) Erstatt disse tegnene med:
          ∆ mrd  Æ
          ÿ med  Ø
          ≈ med  Å
          ¡ med  O  fra:  9716    BÿRSELV    5436    PORSANGER PORS¡NGU PORSANKI    G
 11. 🟢 Funksjonen "parseCSV" i SettingView linje 231: CloudKit's PostNummer har feil    verdier på "ÆØÅ"
        a. Dette skyldes valg på enkoding.
           Encoding er nå fjernet!
 12. 🟢 Gå gjennom PersonView()
        a) Vurdere om en trenger "Refresh" knappen etter å ha valgt postnummer.
           Konklusjon: Tatt bort knappen og lagt inn @Binding i FindPostNummer()
 13.🟢  Gå gjennom PersonsOverView()
        a) Tekster kuttes, fødselsdato,adresse.
           Konklusjon: Trykk refresh
 14. 🟢 Gå gjennom NewPersonView()
        a) Velg postnmmer og fjern alle globale verdier
 15. 🟢 Tilpasse ImagePicker() slik at det kan velges et utsnitt av bildet.
 16. 🟢 Kan ikke starte "Ny person"
        a) For å kalle NewPersonView() må gamle måten for .sheet brukes.
           Kan dette være en feil i Xcode?
 17. 🟢 Postnummerkategorier:
        a) Postnummerkategoriene forteller hva postnummeret blir benyttet til (f.eks. gateadresser og/eller postboksadresser).
          B = Både gateadresser og postbokser
          F = Flere bruksområder (felles)
          G = Gateadresser (og stedsadresser), dvs. “grønne postkasser”
          P = Postbokser
          S = Servicepostnummer (disse postnumrene er ikke i bruk til postadresser)
        b) zoomPostNummer():
           Her settes postNummer.category != "S"
 18. 🟢 Gå gjennom PersonBirthdayView()
 19. 🟢 Teksten "Ny Melding" ligger i systemet når en sender en ny e-post
 20. 🟢 Firebase Json
        a) Lese inn data fra Json og lagre i CloudKit, men bare engang!
 21. 🟢 Sletting i Personer er nå OK
 22. 🟢 Det kommer nå en feilmelding hvis det ikke er en Internet forbindelse
 23. 🟢 Laget backup av Person til Json fil
 24. 🟢 Image på CloudKit er nå kraftig redusert (bruker nå: image.jpegData(compressionQuality: 0.01) )
 25. 🟢 Gjennomgang av hele SettingView() og spesielt SwiftJsonBackup() er ferdig
 26. 🟢 SettingsView: Legge inn user default slik at en må endre user default for å lage til CloudKit
 27. 🟢 Lage et ekstra alternativ for å lagre Person i CloudKit
 28. 🟢 Lese fra Person sin json fil (bortsett fra image)
 29. 🟢 Kunne slette alle personene i CloudKit
 30. 🟢 Oppdatere Person fra Person sin json fil (bortsett fra image)
 31. 🟢 Sjekket alignment icons på SettingsView()
 32. 🟢 Implementert ActivityIndicator i SwiftActivityIndicator.swift
 33. 🟢 Innføre .overlay med presentationMode.wrappedValue.dismiss() på:
        a) SettingView() Mangler helt
        b) PersonOverView() kun mindre justering
        c) PersonBirthdayView() kun mindre justering
 34. 🟢 Lage nytt view "UserOverview()"
        a)  Innføre .overlay med presentationMode.wrappedValue.dismiss()
 35. 🟢 Erstatte .overlay med button
 36. 🟢 Backup av Brukerne
        a) Section: Brukere og CloudKit
           1) 🟢 CloudKit Bruker alternativ
           2) 🟢 CloudKit Bruker slette all brukerne
           3) 🟢 CloudKit lagre brukerne
 37. 🟢 Section USER BACKUP TO JSON FILE
          a) User backup to Json file
 38. 🟢 Når en oppretter en ny Person i Dashboard CloudKit, vil
        blanke felter som definert som String, ha verdien nil.
        Ser ut som om det er knyttet til dateOfBirth: Date().
 39. 🟢 Tilpasse SwiftJsonPersonBackup() til base en bruker i CloudKit
 40. 🟢 Kan nå slette en Bruker. Ref. PersonsOverView linje 49.
 41. 🟢 Lagre personer i CloudKit på nytt, men bare dersom Person tabellen er    tom.
 42. 🟢 Lagre alle brukere i CloudKit på nytt, men bare dersom User tabellen     er tom.
 43. 🟢 Bruke ActionSheet ref. UserMaintenanceView() i:
          a) 🟢 Slette alle personene
          b) 🟢 Slette alle brukerne
 44. 🟢 Ny bruker
          a) 🟢 Endre tekst "Logg på" til "Lagre"
          b) 🟢 Slette bilde og info etter lagring
          c) 🟢 Slette bilde ved oppstart
 45. 🟢 Endre fra ActionSheet til Alert + Activity Indicator
          a) 🟢 SignInView()
          b) 🟢 SignUpView()
          c) 🟢 UserMaintenanseView()
          d) 🟢 PersonsOverView()
          e) 🟢 SwiftDeleteAllPersons()
          f) 🟢 SwiftDeleteAllUsers()
          g) 🟢 SwiftReadCloudKitSaveCloudKitPerson()
          h) 🟢 SwiftReadCloudKitSaveCloudKitUser()
          i) 🟢 UserDeleteView()
          j) 🟢 UserOverView()
 46. 🟢 Bruker UserMaintenanceView()
          a) 🟢 Legge inn 1 lagre knapp
 47. 🟢 Ved å importere PersonBackup.json blir fødselsdagene satt til dagens dato
 48. 🟢 Oppdatering fra Firebase json virker ikke
          a) 🟢 Sjekk aktivering "Firebase personer alternativ"
 49. 🟢 Feilmelding dersom det mangler på:
          a) 🟢 PersonBirthdayView()
                1) 🟢 Telefonnummer
          b) 🟢 PersonsOverView()
                1) 🟢 Telefonnummer
                2) 🟢 epostadresse
 50. 🟢 Fjerne en tom linje på toppen av UserOverView()
 51. 🟢 Ny Searchbar i PersonsOverView() finn versjon for SwiftUI
       a) 🟢 x virker nå
 52. 🟢 PersonsOverView():
       a) 🟢 Ekstra "tom linje" under Searchbar
             Den skyldes ActivityIndicator
 53. 🟢 Legge inn ny SearchBar i PersonBirthdatView()
 54. 🟢 Legge inn ny SearchBar i UserOverView()
 55. 🟢 Mangler navigationViewTitle på deltaljene til den enkelte brukeren
 56. Kunne lagre kun en gang, men oppdatere flere ganger:
       a) 🟢 Person
       b) 🟢 User
 57. 🟢 CloudKit oppdaere personer SwiftReadCloudKitSaveCloudKitPerson() :
        lagrer i stedet for å oppdatere.
        Skyldes at tempFirstname ikke ble erstattet av .firstName
 58. 🟢 Dersom det brukes NavigationView og det kan kalles opp mer enn et NavigationView
        må .navigationViewStyle(StackNavigationViewStyle()) legges inn slutten av
        det opprinnelige NavigationView.
        Hvis ikke blir det problem på iPad (Tilsynelatende OK på iPhone)
 59. 🟢 Legge inn .navigationViewStyle(StackNavigationViewStyle()) i aktuelle NavigationView
 60. 🟢 Innføre "Indexed view"
        a) 🟢 Personer
        b) 🟢 Brukere
 61. 🟢 Legg inn < Innlogging på Oppgaver
 62. 🟢 Slette person : legg inn foregroundColor PersonDeleteView
 63. 🟢 Slette bruker : legg inn foregroundColor UserDeleteView
 64. 🟢 PersonBirthdayView: bytte om på menyen
 65. 🟢 Hente flere detaljer fra PersonMapView()
 66. 🟢 Må kun kunne oppdatere pålogget bruker
 67. 🟢 Må kun vise navn for de andrebrukerne
 68. 🟢 Personer: PersonsOverViewIndexed()
        a) Sletting er nå i orden.
 69. 🟢 Brukere: UserOverViewIndexed() Problemer med søking fra SearchBar
        a) Virker ved hjelp av Combine
 70. 🟢 Personer: Problemer med søking fra SearchBar
        a) a) Virker ved hjelp av Combine
 71. 🟢 Articles
          a) iCloud.com.janhovland.MacOS-SwiftUI-Articles
          b) Tabell: article fields:
                     introduction Learn how to manage a SwiftUI view when keyboard appears.
                     mainType     iPhone
                     subType      SwiftUI
                     subType1     Move field upwards
                     title        Keyboard Avoidance For SwiftUI Views
                     url          https://www.vadimbulavin.com/how-to
 72. 🟢 Resette feltene når en ny artikkel blir lagret.
 73. 🟢 PersonsOverViewIndexed() :
          🟢 a) dersom det ikke finnes en person som f.eks begynner på C,
             så sectionHeader.removeAll() ???
          🟢 b) Legg "Frisk opp" og "Ny person" over searchBaren.
          🟢 c) Samme avstand mellom elementene som i UserOverViewIndexed()
 74. 🟢 UserOverViewIndexed() :
          🟢 a) dersom det ikke finnes en bruker som f.eks begynner på C,
             så sectionHeader.removeAll() ???
          🟢 b) Legg "Frisk opp" rover searchBaren.
          🟢 c) Samme avstand mellom elementene som i PersonsOverViewIndexed()
 
 
"""
var toDo_4 =
    """
S e n e r e

"""
var toDo_5 =
    """
  1. 🔴 PersonBirthdayView() og PersonsOverView() Utsettes inntil videre
        a) Få med æ,ø og å i melding
  2. 🔴 Sjekke omkring sending av meldinger og da spesielt SendMessageView()
  3. 🔴 Vise antall personer som ble slettet er vanskelig og er derfor utsatt
  4. 🔴 Home Screen Quick Action in iOS app
        a) https://www.warmodroid.xyz/tutorial/ios/home-screen-quick-action-ios/


"""
var toDo_6 =
    """
    K j e n t e   f e i l

    """

var toDo_7 =
    """

      1. 🔴 UserDeleteView() : Secure password setter ikke passordet til blank,
                            men beholder antall ". (punkter)"

    """

var toDo_8 =
    """

    P R A K T I S K E   T I P S

    """

var toDo_9 =
    """
      1. DispatchQueue.global().sync {
             writeJsonPersonBackup()
             /// sleep() takes seconds
             /// sleep(4)
             /// usleep() takes millionths of a second
             usleep(4000000)
          }

      2. DispatchQueue.global().async {
            /// Starte ActivityIndicator
            indicatorShowing = true
            CloudKitPerson.deleteAllPersons()
            /// Stoppe ActivityIndicator
            indicatorShowing = false
        }
        message = result
        alertIdentifier = AlertID(id: .first)

    """

struct ToDoView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView (.vertical, showsIndicators: false) {
                VStack {
                    Text(toDo_1)
                        .font(.custom("Andale Mono Normal", size: 17))
                        .multilineTextAlignment(.leading)
                    Text(toDo_2)
                        .font(.custom("Andale Mono Normal", size: 20)).bold()
                        .foregroundColor(.accentColor)
                    Text(toDo_3)
                        .font(.custom("Andale Mono Normal", size: 17))
                        .multilineTextAlignment(.leading)
                    Text(toDo_4)
                        .font(.custom("Andale Mono Normal", size: 20)).bold()
                        .foregroundColor(.accentColor)
                    Text(toDo_5)
                        .font(.custom("Andale Mono Normal", size: 17))
                        .multilineTextAlignment(.leading)
                    Text(toDo_6)
                        .font(.custom("Andale Mono Normal", size: 20)).bold()
                        .foregroundColor(.red)
                    Text(toDo_7)
                        .font(.custom("Andale Mono Normal", size: 17))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.red)
                    Text(toDo_8)
                        .font(.custom("Andale Mono Normal", size: 17))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.green)
                    Text(toDo_9)
                        .font(.custom("Andale Mono Normal", size: 17))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.green)
                    
                }
            }
            .padding()
            .navigationBarTitle(Text(NSLocalizedString("toDo", comment: "toDo")), displayMode: .inline)
            .navigationBarItems(leading:
                                    Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                    }, label: {
                                        ReturnFromMenuView(text: NSLocalizedString("SignInView", comment: "ToDoView"))
                                    }
                                ))
        }
    }
}

