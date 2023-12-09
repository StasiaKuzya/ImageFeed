//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Анастасия on 23.11.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let primaryButton: AlertButton
    let additionalButtons: [AlertButton]?
}

struct AlertButton {
    let buttonText: String
    let completion: (() -> Void)?
}
