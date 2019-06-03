//
//  NavigationHelpers.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

enum NavigationHelpersAttachAnchor {
    case top
    case topRight
    case topLeft
    case bottom
    case bottomRight
    case bottomLeft
}

class NavigationHelpers
{
    class func addVCChild(parent: UIViewController, child: UIViewController) {
        parent.addChild(child)
        
        parent.view.addSubview(child.view)
        
        child.didMove(toParent: parent)
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
