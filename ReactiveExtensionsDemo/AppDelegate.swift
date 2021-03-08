//
//  AppDelegate.swift
//  ReactiveExtensionsDemo
//
//  Created by Kyle Kurz on 3/5/21.
//

import UIKit
import RxDataSources
import RxSwift

struct Contact {
    
    // Required fields
    let id: String
    let number: Int
    let firstName: String
    let lastName: String
    let email: String
    
    // Optional fields
    let picture: String?
}

extension Contact {
    init?(from dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let number = dictionary["number"] as? Int,
              let firstName = dictionary["firstName"] as? String,
              let lastName = dictionary["lastName"] as? String,
              let email = dictionary["email"] as? String else {
            return nil
        }
        
        let picture = dictionary["picture"] as? String
        self.init(id: id, number: number, firstName: firstName, lastName: lastName, email: email, picture: picture)
    }
}

enum ContactSortOrder {
    case number
    case firstName
    case lastName
    case email
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    // Simple JSON payload for displaying a list of contacts
    // NOTE:
    let contactJsonStr = """
    [
        {"id": "qjvn", "number": 100, "firstName": "Zachary", "lastName": "Apple", "email": "zapple@home.com", "picture": "https://firebasestorage.googleapis.com/v0/b/you-belong-1503433655652.appspot.com/o/shared%2Fclock.png?alt=media&token=8069e710-dad9-451c-8409-2ccbbe970e5f"},
        {"id": "alsdkfj", "number": 101, "firstName": "Yvette", "lastName":"Banana", "email":"bbanana@home.com"},
        {"id": "oiavj", "number": 102, "firstName": "Xavier", "lastName": "Coconut", "email": "ccoconut@home.com"},
        {"id": "1", "number": 972, "firstName": "Wesley", "lastName": "Date", "email": "wdate@home.com"},
        {"id": "biojw", "number": 23456, "firstName": "Vincent", "lastName": "Eggplant", "email": "veggplant@home.com", "picture": "https://firebasestorage.googleapis.com/v0/b/you-belong-1503433655652.appspot.com/o/shared%2Fsocial.png?alt=media&token=deed1b8b-22d7-4a38-adfc-9cdd4818b62a"},
        {"id": "b34bdv", "number": 725, "firstName": "Ursula", "lastName": "Fig", "email": "ufig@home.com"},
        {"id": "abq35f", "number": 2345, "firstName": "Tammy", "lastName": "Grape", "email": "tgrape@home.com"},
        {"id": "23hbad", "number": 2783, "firstName": "Sophia", "lastName": "Honeydew", "email": "shoneydew@home.com"},
        {"id": "qefbqe", "number": 465, "firstName": "Raymond", "lastName": "Imbe", "email": "rimbe@home.com"},
        {"id": "3bwetfbad", "number": "0892734", "firstName": "Quincy", "lastName": "Juniper", "email": "qjuniper@home.com", "picture": "https://firebasestorage.googleapis.com/v0/b/you-belong-1503433655652.appspot.com/o/shared%2Fnotes.png?alt=media&token=39cf5622-73ac-4b9c-b4d1-a6d636950e19"},
        {"id": "qbne", "number": 7651, "firstName": "Paul", "lastName": "Kungdong", "email": "pkungdong@home.com"},
        {"id": "sa", "number": 10349, "firstName": "Oscar", "lastName": "Limeberry", "email": "olimeberry@home.com"},
        {"id": "25ywnhwg", "number": 102, "firstName": "Natalie", "lastName": "Muscadine", "email": "nmuscadine@home.com", "picture": ""},
        {"id": "ng34nb", "number": 145, "firstName": "Madaline", "lastName": "Nectarine", "email": "mnectarine@home.com", "picture": "https://firebasestorage.googleapis.com/v0/b/you-belong-1503433655652.appspot.com/o/shared%2Fgiving.png?alt=media&token=12b73603-edd5-449b-9969-9e87f3b8005e"},
        {"id": "whm357j", "number": 925, "firstName": "Leila", "lastName": "Orange", "email": "lorange@home.com"},
        {"id": "36jthn", "number": 1234, "firstName": "Kevin", "lastName": "Papaya", "email": "kpapaya@home.com"},
        {"id": "34wnwrg", "number": 896, "firstName": "Jason", "lastName": "Quince", "email": "jquince@home.com", "picture": "https://firebasestorage.googleapis.com/v0/b/you-belong-1503433655652.appspot.com/o/shared%2Fconnection.png?alt=media&token=ef05d21e-70b7-47de-8773-fdcf82152c8e"},
        {"id": "kdeghjd", "number": 9345, "firstName": "Imogene", "lastName": "Rambutan", "email": "irambutan@home.com"},
        {"id": "dfghjmd", "number": 256, "firstName": "Herbert", "lastName": "Strawberry", "email": "hstrawberry@home.com"},
        {"id": "cvnme", "number": 257264, "firstName": "Gina", "lastName": "Tamarind", "email": "gtamarind@home.com"},
        {"id": "35ym", "number": 3467, "firstName": "Famke", "lastName": "Ugli", "email": "fugli@home.com", "picture": 32},
        {"id": "7", "number": 34, "firstName": "Eduardo", "lastName": "Vanilla", "email": "evanilla@home.com"},
        {"id": "emthm4u", "number": 36, "firstName": "Diane", "lastName": "Walnut", "email": "dwalnut@home.com"},
        {"id": "etjem", "number": 2, "firstName": "Charles", "lastName": "Ximenia", "email": "cximenia@home.com"},
        {"id": "246nwfb", "number": 6579, "firstName": "Brian", "lastName": "Yam", "email": "byam@home.com"},
        {"id": "24nwrg", "firstName": "Alfred", "lastName": "Zucchini", "email": "azucchini@home.com"}
    ]
    """
    
    // Public observables for various other parts of the codebase
    public let contactDictionary = BehaviorSubject<[String: Contact]>(value: [:])
    public let contactList = BehaviorSubject<[Contact]>(value: [])
    public let sortOrder = BehaviorSubject<ContactSortOrder>(value: .firstName)
    
    // Private internal variables
    let disposeBag = DisposeBag()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Watch the contact dictionary and fire off the contactList Observable
        Observable.combineLatest(contactDictionary, sortOrder)
            .map { (dictionary, order) in
                return dictionary.values.sorted { (lhs, rhs) -> Bool in
                    switch order {
                    case .email:
                        return lhs.email < rhs.email
                    case .firstName:
                        return lhs.firstName < rhs.firstName
                    case .lastName:
                        return lhs.lastName < rhs.lastName
                    case .number:
                        return lhs.number < rhs.number
                    }
                }
            }.bind { self.contactList.onNext($0) }
            .disposed(by: disposeBag)
        
        // Parse the contact list into JSON and fire the Observable
        if let data = contactJsonStr.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] {
            let contacts = json.compactMap { Contact(from: $0) }
                .reduce(into: [String: Contact]()) { (result, contact) in
                    result[contact.id] = contact
                }
            contactDictionary.onNext(contacts)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

