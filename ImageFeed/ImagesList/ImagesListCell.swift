//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Артем Шепелев on 1.03.2026.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    private let gradientLayer = CAGradientLayer()
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupGradient()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            gradientLayer.frame = gradientView.bounds
        }
        
        private func setupGradient() {
            let topColor = UIColor(
                hue: 233.0/360.0,
                saturation: 0.24,
                brightness: 0.13,
                alpha: 0.0
            )
            let bottomColor = UIColor(
                hue: 233.0/360.0,
                saturation: 0.24,
                brightness: 0.13,
                alpha: 1.0
            )
            
            gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.opacity    = 0.2
            gradientView.layer.insertSublayer(gradientLayer, at: 0)
        }
}
