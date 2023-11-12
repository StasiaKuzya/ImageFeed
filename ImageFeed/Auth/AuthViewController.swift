//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Анастасия on 06.11.2023.
//

import Foundation
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

class AuthViewController: UIViewController {
    
    // MARK: -  Properties & Constants
    
    let ShowWebViewIdentifier = "ShowWebView"
    let webViewViewController = WebViewViewController()
    let oAuth2Service = OAuth2Service()
    let tokenStorage = OAuth2TokenStorage()
    
    weak var delegate: AuthViewControllerDelegate?

    // MARK: - IBOutlet
    
    @IBOutlet private weak var entranceButton: UIButton!
    
    // MARK: - Override Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewIdentifier,
           let webViewViewController = segue.destination as? WebViewViewController
        { webViewViewController.delegate = self
        }
    }
}

    // MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {

    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true, completion: nil)
    }
}
