//
//  ErrorThrower.seift
//  Playerly
//
//  Created by Julian Schiavo on 17/12/2018.
//  Copyright © 2018 Julian Schiavo. All rights reserved.
//

import UIKit

/// Allow conforming types to throw errors and show an alert with the error to the user
protocol ErrorThrower { }

extension ErrorThrower where Self: UIViewController {
    /// This shows an alert with the error thrown. Not declared in the protocol to avoid conforming types from having their own method.
    func throwError(_ error: String?, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: completion)
    }
}
