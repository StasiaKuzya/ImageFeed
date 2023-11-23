//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Анастасия on 23.11.2023.
//

import Foundation
import UIKit

class AlertPresenter {
    static func showAlert(alertModel: AlertModel, delegate: UIViewController) {
        let alert = UIAlertController(title: alertModel.title,
                                      message: alertModel.message,
                                      preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = "Alert"
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion?()
        }
        alert.addAction(action)
        delegate.present(alert, animated: true, completion: nil)
    }
}
