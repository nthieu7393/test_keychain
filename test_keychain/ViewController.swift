//
//  ViewController.swift
//  test_keychain
//
//  Created by hieu nguyen on 10/09/2022.
//

import UIKit
import Authentication

class ViewController: UIViewController {
    
    
    @IBAction func didTap(_ sender: UIButton) {
        let storyboard: SecondViewController? = UIStoryboard(screen: .SecondViewController).instance()
        present(storyboard!, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        let items = Movie(fileName: "movie file name")
//        let smt = MovieScreen<Movie>()
//        smt.items = [items]
        
//        let form = FormState(
//            name: "my name",
//            surname: "my surname",
//            address: "my address",
//            essay: "my essay",
//            email: "my email")
//        FormStateSaver.save(form, key: "mainform")
//        let result = FormStateSaver.retriveState("mainform")
            
        let authManager = AuthenticationManager()
        authManager.systemSignIn { result in
            switch result {
            case .failure(let error): print(error)
            case .success(let msg): print(msg)
            }
        }
    }
}





//----------------
typealias Memento = NSDictionary

protocol MementoConvertible {
    var memento: Memento { get }
    init?(memento: Memento)
}

struct FormState {
    private enum Keys: String {
        case name = "mainForm.name"
        case surname = "mainForm.surname"
        case email = "mainForm.email"
        case address = "mainForm.address"
        case essay = "mainForm.essay"
        case datesaved = "mainForm.datesaved"
    }
    
    var name: String
    var surname: String
    var address: String
    var essay: String
    var email: String
    var dateSaved: Date = Date()
    
    init(name: String, surname: String, address: String, essay: String, email: String) {
        self.name = name
        self.surname = surname
        self.address = address
        self.essay = essay
        self.email = email
        self.dateSaved = Date()
    }
}

extension FormState: MementoConvertible {
    var memento: Memento {
        return [Keys.name: name,
                Keys.surname: surname,
                Keys.address: address,
                Keys.essay: essay,
                Keys.email: email,
                Keys.datesaved: dateSaved
        ]
    }
    
    init?(memento: Memento) {
        name = memento[Keys.name] as! String
        surname = memento[Keys.surname] as! String
        address = memento[Keys.address] as! String
        essay = memento[Keys.essay] as! String
        email = memento[Keys.email] as! String
        dateSaved = memento[Keys.datesaved] as! Date
    }
}

struct FormStateSaver {
    static func save(_ state: MementoConvertible, key: String) {
        Defaults.mainFormState?.append(state.memento)
    }
    
    static func retriveState(_ key: String) -> [FormState?]? {
        return Defaults.mainFormState?.map { FormState(memento: $0)! }
    }
}

class Defaults {
    static var mainFormState : [Memento]? {
        get {
            let defaults = UserDefaults.standard
            return defaults.array(forKey: "mainForm") as? [Memento]
        }
        
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: "mainForm")
            defaults.synchronize()
        }
    }
}


//----------------


protocol Item {
    init(fileName: String)
}

struct Movie: Item {
    var fileName: String
}

struct Song: Item {
    var fileName: String
}

protocol Screen {
    associatedtype ItemType: Item
    associatedtype ScreenType: Screen where ScreenType.ItemType == ItemType
    var items: [ItemType] { get set }
    var childScreen: [ScreenType] { get set }
}

class MovieScreen<T: Item>: Screen {
    var items = [T]()
    var childScreen = [DetailScreen<T>]()
}

class DetailScreen<T: Item>: Screen {
    var items = [T]()
    var childScreen = [DetailScreen<T>]()
}

extension UIStoryboard {
    
    enum Screen: String {
        case viewController
        case SecondViewController
    }
    
    convenience init(screen: Screen, bundle: Bundle? = nil) {
        self.init(name: "Main", bundle: nil)
    }
    
    func instance<T: ViewControllerIdentify>() -> T? {
        return instantiateViewController(withIdentifier: T.identify) as? T
    }
}

protocol ViewControllerIdentify {
    static var identify: String { get }
}

extension ViewControllerIdentify {
    
    static var identify: String {
        return String(describing: self)
    }
}
