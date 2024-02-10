//
//  UIView.swift
//  FlowerApp
//
//  Created by mahmoud on 09/02/2024.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable var cornerRadius : CGFloat {
        get { return self.cornerRadius }
        set { self.layer.cornerRadius = newValue }
    }
}
