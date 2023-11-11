//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Анастасия on 10.11.2023.
//

import Foundation
import UIKit

class SplashViewController: UIViewController {
    
    let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreenSegueIdentifier"
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = OAuth2TokenStorage().token {
            
        } else {
            performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }

}
