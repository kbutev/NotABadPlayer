//
//  NavigationHelpers.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class NavigationHelpers
{
    class func addVCChild(parent: UIViewController,
                          child: UIViewController,
                          animation: NavigationHelpersAnimation.Animation = .none) {
        parent.addChild(child)
        
        parent.view.addSubview(child.view)
        
        child.didMove(toParent: parent)
        
        NavigationHelpersAnimation.animateView(child.view, animation: animation)
    }
    
    class func removeVCChild(_ child: UIViewController) {
        if child.parent == nil
        {
            fatalError("Cannot remove view controller \(child.description) from its parent because it doesn't have one. Maybe you meant to call dismissPresentedVC() instead?")
        }
        
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    class func presentVC(current: UIViewController, vc: UIViewController) {
        current.present(vc, animated: true, completion: nil)
    }
    
    class func dismissPresentedVC(_ vc: UIViewController) {
        vc.dismiss(animated: true, completion: {() in
            vc.view.removeFromSuperview()
        })
    }
}

class NavigationHelpersAnimation {
    enum Animation {
        case none
        case scaleUp
        case scaleDown
        case turnRight
        case turnLeft
    }
    
    class func animateView(_ view: UIView, animation: Animation) {
        switch animation {
        case .scaleUp:
            UIAnimations.animateViewScaleUp(view)
            break
        case .scaleDown:
            UIAnimations.animateViewScaleDown(view)
            break
        default:
            break
        }
    }
}
