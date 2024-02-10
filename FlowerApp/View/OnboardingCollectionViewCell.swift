//
//  OnboardingCollectionCollectionViewCell.swift
//  FlowerApp
//
//  Created by MahmoudAlaa on 09/02/2024.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    static let dentifier = String(describing: OnboardingCollectionViewCell.self)
    @IBOutlet weak var slideImageView: UIImageView!
    
    @IBOutlet weak var slideTiltleLabel: UILabel!
    
    @IBOutlet weak var slideDescripionLabel: UILabel!
    
    func setup (_ slide: OnboardingSlide){
        slideImageView.image = slide.image
        slideTiltleLabel.text = slide.title
        slideDescripionLabel.text = slide.description
    }
    
}
