//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Анастасия on 11.10.2023.
//

import Foundation
import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Создаем градиентный слой
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = gradientView.bounds
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.20).cgColor]
        gradientLayer.locations = [0.0, 0.5393]
        
        // Устанавливаем угол градиента (180 градусов)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        
        // Добавляем градиентный слой как фон для gradientView
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }
}

