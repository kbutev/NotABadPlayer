//
//  MainViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 25.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit
import MediaPlayer

class MainViewController : UIViewController {
    public static let DEFAULT_SELECTED_TAB: TabID = .Albums
    public static let TAB_SIZE = CGSize(width: 0, height: 60.0)
    public static let SELECTED_MENU_BUTTON_COLOR: UIColor = UIColor(displayP3Red: 0.37, green: 0.59, blue: 0.94, alpha: 1)
    
    private var baseView: MainView?
    
    private var audioStorage: AudioStorage = AudioStorage()
    
    private var selectedTab: UIViewController?
    
    private var selectedTabID: TabID = .None
    
    override func loadView() {
        self.baseView = MainView.create(owner: self)
        self.view = self.baseView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GeneralStorage.shared.initialize()
        AudioPlayer.shared.initialize(audioInfo: audioStorage)
        QuickPlayerService.shared.initialize(audioPlayer: AudioPlayer.shared)
        GeneralStorage.shared.restorePlayerState()
        
        setup()
    }
    
    private func setup() {
        // Select default tab
        onTabItemSelected(MainViewController.DEFAULT_SELECTED_TAB)
        
        // Button interaction
        var gesture = UITapGestureRecognizer(target: self, action: #selector(actionAlbumsMenuButtonTap(sender:)))
        gesture.numberOfTapsRequired = 1
        self.baseView?.albumsButton.addGestureRecognizer(gesture)
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(actionListsMenuButtonTap(sender:)))
        gesture.numberOfTapsRequired = 1
        self.baseView?.listsButton.addGestureRecognizer(gesture)
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(actionSearchMenuButtonTap(sender:)))
        gesture.numberOfTapsRequired = 1
        self.baseView?.searchButton.addGestureRecognizer(gesture)
        
        gesture = UITapGestureRecognizer(target: self, action: #selector(actionSettingsMenuButtonTap(sender:)))
        gesture.numberOfTapsRequired = 1
        self.baseView?.settingsButton.addGestureRecognizer(gesture)
    }
    
    private func onTabItemSelected(_ tabID: TabID) {
        if self.selectedTabID == tabID
        {
            return
        }
        
        deselectAllTabs()
        
        self.selectedTabID = tabID
        
        switch tabID {
        case .Albums:
            selectAlbumsTab()
            self.baseView?.albumsButton.tintColor = MainViewController.SELECTED_MENU_BUTTON_COLOR
            break
        case .Lists:
            selectListsTab()
            self.baseView?.listsButton.tintColor = MainViewController.SELECTED_MENU_BUTTON_COLOR
            break
        case .Search:
            selectSearchTab()
            self.baseView?.searchButton.tintColor = MainViewController.SELECTED_MENU_BUTTON_COLOR
            break
        case .Settings:
            selectSettingsTab()
            self.baseView?.settingsButton.tintColor = MainViewController.SELECTED_MENU_BUTTON_COLOR
            break
        default:
            fatalError("Cannot select tab \(tabID.rawValue)")
            break
        }
    }
    
    private func deselectAllTabs() {
        self.selectedTab?.view.removeFromSuperview()
        self.selectedTab = nil
        self.selectedTabID = .None
        self.baseView?.albumsButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
        self.baseView?.listsButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
        self.baseView?.searchButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
        self.baseView?.settingsButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
    }
    
    private func selectAlbumsTab() {
        Logging.log(MainViewController.self, "Selecting tab 'Albums'")
        
        let vc = AlbumsViewController()
        self.selectedTab = vc
        vc.presenter = AlbumsPresenter(view: vc, audioInfo: audioStorage)
        NavigationHelpers.addVCChild(parent: self, child: vc)
        self.baseView?.embedViewIntoPrimaryArea(vc.view)
    }
    
    private func selectListsTab() {
        Logging.log(MainViewController.self, "Selecting tab 'Lists'")
        
    }
    
    private func selectSearchTab() {
        Logging.log(MainViewController.self, "Selecting tab 'Search'")
        
    }
    
    private func selectSettingsTab() {
        Logging.log(MainViewController.self, "Selecting tab 'Settings'")
        
        let vc = SettingsViewController()
        self.selectedTab = vc
        NavigationHelpers.addVCChild(parent: self, child: vc)
        self.baseView?.embedViewIntoPrimaryArea(vc.view)
    }
}

extension MainViewController {
    @objc func actionAlbumsMenuButtonTap(sender: Any) {
        onTabItemSelected(.Albums)
    }
    
    @objc func actionListsMenuButtonTap(sender: Any) {
        onTabItemSelected(.Lists)
    }
    
    @objc func actionSearchMenuButtonTap(sender: Any) {
        onTabItemSelected(.Search)
    }
    
    @objc func actionSettingsMenuButtonTap(sender: Any) {
        onTabItemSelected(.Settings)
    }
}
