//
//  TabController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit
import MediaPlayer

class TabController : UITabBarController, UITabBarControllerDelegate {
    static let DEFAULT_SELECTED_TAB: TabID = .Albums
    static let TAB_SIZE = CGSize(width: 0, height: 60.0)
    
    private var audioStorage: AudioStorage = AudioStorage()
    
    private var selectedTab: UIViewController {
        get {
            switch selectedTabID {
            case .Albums:
                return self.viewControllers![0]
            case .Lists:
                return self.viewControllers![1]
            case .Search:
                return self.viewControllers![2]
            case .Settings:
                return self.viewControllers![3]
            default:
                return self.viewControllers![0]
            }
        }
    }
    
    private var selectedTabID: TabID = .None
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralStorage.shared.initialize()
        AudioPlayer.shared.initialize(audioInfo: audioStorage)
        QuickPlayerService.shared.initialize(audioPlayer: AudioPlayer.shared)
        
        setup()
    }
    
    override func viewWillLayoutSubviews() {
        self.tabBar.invalidateIntrinsicContentSize()
        
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = TabController.TAB_SIZE.height
        tabFrame.origin.y = self.view.frame.origin.y + UIApplication.shared.statusBarFrame.height
        
        self.tabBar.frame = tabFrame
        
        super.viewWillLayoutSubviews()
    }
    
    private func setup() {
        self.delegate = self
        
        // Select default tab
        onTabItemSelected(TabController.DEFAULT_SELECTED_TAB)
    }
    
    private func onTabItemSelected(_ tabID: TabID) {
        if self.selectedTabID == tabID
        {
            return
        }
        
        self.selectedTabID = tabID
        
        switch tabID {
        case .Albums:
            selectAlbumsTab()
            break
        case .Lists:
            selectListsTab()
            break
        case .Search:
            selectSearchTab()
            break
        case .Settings:
            selectSettingsTab()
            break
        default:
            fatalError("Cannot select tab \(tabID.rawValue)")
            break
        }
    }
    
    private func selectAlbumsTab() {
        if let vc = selectedTab as? AlbumsViewController
        {
            vc.presenter = AlbumsPresenter(view: vc, audioInfo: audioStorage)
        }
    }
    
    private func selectListsTab() {
        
    }
    
    private func selectSearchTab() {
        
    }
    
    private func selectSettingsTab() {
        
    }
}

// Item selection
extension TabController {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let index = self.tabBar.items?.index(of: tabBarController.tabBar.selectedItem!) else {
            return
        }
        
        switch index {
        case 0:
            // Go back?
            if selectedTabID == .Albums
            {
                (selectedTab as? BaseViewController)?.goBack()
            }
            
            break
        case 1:
            break
        case 2:
            break
        case 3:
            break
        default:
            break
        }
    }
}
