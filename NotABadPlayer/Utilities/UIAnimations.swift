//
//  ViewAnimation.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 11.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class UIAnimations {
    public static let ANIMATION_DURATION: Double = 0.5
    public static let UPDATE_COUNT: Double = 5
    
    static func stopAnimations(_ view: UIView) {
        view.layer.removeAllAnimations()
        
        CATransaction.begin()
        view.layer.removeAllAnimations()
        CATransaction.commit()
    }
    
    static func animateViewFadeIn(_ view: UIView) {
        stopAnimations(view)
        
        view.alpha = 0
        
        UIView.animate(withDuration: ANIMATION_DURATION,
                       delay: ANIMATION_DURATION / UPDATE_COUNT,
                       options: [],
                       animations: {view.alpha = 1},
                       completion: nil)
    }
    
    static func animateViewFadeOut(_ view: UIView) {
        stopAnimations(view)
        
        view.alpha = 1
        
        UIView.animate(withDuration: ANIMATION_DURATION,
                       delay: ANIMATION_DURATION / UPDATE_COUNT,
                       options: [],
                       animations: {view.alpha = 0},
                       completion: nil)
    }
    
    static func animateListItemClicked(_ view: UIView) {
        stopAnimations(view)
        
        let currentColor = view.backgroundColor
        
        view.backgroundColor = AppTheme.shared.colorFor(.ANIMATION_CLICK_EFFECT)
        
        UIView.animate(withDuration: ANIMATION_DURATION,
                       delay: ANIMATION_DURATION / UPDATE_COUNT,
                       options: [.allowUserInteraction],
                       animations: {view.backgroundColor = currentColor},
                       completion: nil)
    }
    
    static func animateImageClicked(_ image: UIImageView) {
        stopAnimations(image)
        
        let currentColor = image.tintColor
        
        image.tintColor = AppTheme.shared.colorFor(.ANIMATION_CLICK_EFFECT)
        
        UIView.animate(withDuration: ANIMATION_DURATION,
                       delay: ANIMATION_DURATION / UPDATE_COUNT,
                       options: [.allowUserInteraction],
                       animations: {image.tintColor = currentColor},
                       completion: nil)
    }
    
    static func animateViewScaleUp(_ view: UIView) {
        stopAnimations(view)
        
        view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        UIView.animate(withDuration: ANIMATION_DURATION,
                       delay: ANIMATION_DURATION / UPDATE_COUNT,
                       options: [.allowUserInteraction],
                       animations: {view.transform = CGAffineTransform(scaleX: 1, y: 1)},
                       completion: nil)
    }
    
    static func animateViewScaleDown(_ view: UIView) {
        stopAnimations(view)
        
        view.transform = CGAffineTransform(scaleX: 1, y: 1)
        
        UIView.animate(withDuration: ANIMATION_DURATION,
                       delay: ANIMATION_DURATION / UPDATE_COUNT,
                       options: [.allowUserInteraction],
                       animations: {view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)},
                       completion: nil)
    }
}
