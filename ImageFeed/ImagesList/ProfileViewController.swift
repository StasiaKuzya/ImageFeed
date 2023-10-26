//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Анастасия on 19.10.2023.
//

import Foundation
import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var loginNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    
    // MARK: - IBAction
    
    @IBAction private func didTapLogOutButton() {
        
    }
}
