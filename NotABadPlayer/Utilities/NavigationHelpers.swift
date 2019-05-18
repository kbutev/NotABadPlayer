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
    class func showVC(current: UIViewController, vc: UIViewController) {
        current.present(vc, animated: true, completion: nil)
    }
    
    class func removeVC(_ vc: UIViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
    
    class func addVCChild(parent: UIViewController,
                          child: UIViewController,
                          size: CGSize,
                          anchor: NavigationHelpersAttachAnchor=NavigationHelpersAttachAnchor.bottom) {
        parent.addChild(child)
        
        child.view.bounds.size = size
        
        parent.view.addSubview(child.view)
        
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        child.view.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        
        switch anchor {
        case .top:
            child.view.topAnchor.constraint(equalTo: parent.view.topAnchor).isActive = true
            child.view.centerXAnchor.constraint(equalTo: parent.view.centerXAnchor).isActive = true
            break
        case .topRight:
            child.view.topAnchor.constraint(equalTo: parent.view.topAnchor).isActive = true
            child.view.rightAnchor.constraint(equalTo: parent.view.rightAnchor).isActive = true
            break
        case .topLeft:
            child.view.topAnchor.constraint(equalTo: parent.view.topAnchor).isActive = true
            child.view.leftAnchor.constraint(equalTo: parent.view.leftAnchor).isActive = true
            break
        case .bottom:
            child.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor).isActive = true
            child.view.centerXAnchor.constraint(equalTo: parent.view.centerXAnchor).isActive = true
            break
        case .bottomRight:
            child.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor).isActive = true
            child.view.rightAnchor.constraint(equalTo: parent.view.rightAnchor).isActive = true
            break
        case .bottomLeft:
            child.view.bottomAnchor.constraint(equalTo: parent.view.bottomAnchor).isActive = true
            child.view.leftAnchor.constraint(equalTo: parent.view.leftAnchor).isActive = true
            break
        }
        
        child.didMove(toParent: parent)
    }
    
    class func removeVCChild(_ child: UIViewController) {
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
