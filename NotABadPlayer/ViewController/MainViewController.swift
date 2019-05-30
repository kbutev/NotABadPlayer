//
//  MainViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 25.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit
import MediaPlayer

class MainViewController : UIViewController, BaseView {
    public static let DEFAULT_SELECTED_TAB: TabID = .Albums
    public static let TAB_SIZE = CGSize(width: 0, height: 60.0)
    public static let SELECTED_MENU_BUTTON_COLOR: UIColor = UIColor(displayP3Red: 0.37, green: 0.59, blue: 0.94, alpha: 1)
    
    private var baseView: MainView?
    
    private var audioStorage: AudioStorage = AudioStorage()
    
    private var _selectedTab: UIViewController?
    
    private var selectedTab: BaseView? {
        get {
            return _selectedTab as? BaseView
        }
    }
    
    private var selectedTabID: TabID = .None
    
    private var selectedTabIsFocused: Bool {
        get {
            if let vc = _selectedTab
            {
                return vc.children.count == 0
            }
            
            return false
        }
    }
    
    private var tabsCache: [TabID: BaseView] = [:]
    
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
        
        GeneralStorage.shared.attach(observer: self)
        
        setup()
    }
    
    deinit {
        GeneralStorage.shared.detach(observer: self)
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
            if self.selectedTabIsFocused
            {
                return
            }
            
            navigateBackwards()
            return
        }
        
        cacheCurrentTab()
        
        deselectAllTabs()
        
        self.selectedTabID = tabID
        
        updateTabButtonsColor()
        
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
    
    private func deselectAllTabs() {
        if let selectedTabVC = self._selectedTab
        {
            NavigationHelpers.removeVCChild(selectedTabVC)
            self._selectedTab = nil
        }
        
        self.selectedTabID = .None
        
        resetTabButtonsColor()
    }
    
    private func navigateBackwards() {
        self.selectedTab?.goBack()
    }
    
    private func cacheCurrentTab() {
        let cachingPolicy = GeneralStorage.shared.getCachingPolicy()
        
        switch self.selectedTabID {
        case .Albums:
            if cachingPolicy.canCacheAlbums()
            {
                tabsCache[TabID.Albums] = selectedTab!
            }
            break
        case .Lists:
            if cachingPolicy.canCacheLists()
            {
                tabsCache[TabID.Lists] = selectedTab!
            }
            break
        case .Search:
            if cachingPolicy.canCacheSearch()
            {
                tabsCache[TabID.Search] = selectedTab!
            }
            break
        case .Settings:
            if cachingPolicy.canCacheSettings()
            {
                tabsCache[TabID.Settings] = selectedTab!
            }
            break
        default:
            break
        }
    }
    
    private func selectAlbumsTab() {
        Logging.log(MainViewController.self, "Selecting tab 'Albums'")
        
        let vc = tabsCache[TabID.Albums]
        
        if vc == nil
        {
            let presenter = AlbumsPresenter(audioInfo: audioStorage)
            let albumsVC = AlbumsViewController(presenter: presenter)
            self._selectedTab = albumsVC
            presenter.setView(albumsVC)
        }
        else
        {
            self._selectedTab = vc as? UIViewController
        }
        
        guard let albumsVC = self._selectedTab else {
            fatalError("MainViewController: Could not create an Albums view controller")
        }
        
        NavigationHelpers.addVCChild(parent: self, child: albumsVC)
        self.baseView?.embedViewIntoPrimaryArea(albumsVC.view)
    }
    
    private func selectListsTab() {
        Logging.log(MainViewController.self, "Selecting tab 'Lists'")
        
        let vc = tabsCache[TabID.Lists]
        
        if vc == nil
        {
            let presenter = AlbumsPresenter(audioInfo: audioStorage)
            let albumsVC = AlbumsViewController(presenter: presenter)
            self._selectedTab = albumsVC
            presenter.setView(albumsVC)
        }
        else
        {
            self._selectedTab = vc as? UIViewController
        }
        
        guard let albumsVC = self._selectedTab else {
            fatalError("MainViewController: Could not create an Albums view controller")
        }
        
        NavigationHelpers.addVCChild(parent: self, child: albumsVC)
        self.baseView?.embedViewIntoPrimaryArea(albumsVC.view)
    }
    
    private func selectSearchTab() {
        Logging.log(MainViewController.self, "Selecting tab 'Search'")
        
        let vc = tabsCache[TabID.Search]
        
        if vc == nil
        {
            let presenter = SearchPresenter(audioInfo: audioStorage)
            let searchVC = SearchViewController(presenter: presenter)
            self._selectedTab = searchVC
            presenter.setView(searchVC)
        }
        else
        {
            self._selectedTab = vc as? UIViewController
        }
        
        guard let searchVC = self._selectedTab else {
            fatalError("MainViewController: Could not create an Search view controller")
        }
        
        NavigationHelpers.addVCChild(parent: self, child: searchVC)
        self.baseView?.embedViewIntoPrimaryArea(searchVC.view)
    }
    
    private func selectSettingsTab() {
        Logging.log(MainViewController.self, "Selecting tab 'Settings'")
        
        let vc = tabsCache[TabID.Settings]
        
        if vc == nil
        {
            let presenter = SettingsPresenter()
            let settingsVC = SettingsViewController(presenter: presenter, rootView: self)
            self._selectedTab = settingsVC
            presenter.setView(settingsVC)
        }
        else
        {
            self._selectedTab = vc as? UIViewController
        }
        
        guard let settingsVC = self._selectedTab else {
            fatalError("MainViewController: Could not create an Settings view controller")
        }
        
        NavigationHelpers.addVCChild(parent: self, child: settingsVC)
        self.baseView?.embedViewIntoPrimaryArea(settingsVC.view)
    }
    
    private func clearTabsCache() {
        Logging.log(MainViewController.self, "Clear tabs cache")
        
        tabsCache.removeAll()
    }
    
    func onPlayerSeekChanged(positionInPercentage: Double) {
        
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        
    }
    
    func onPlayOrderButtonClick() {
        
    }
    
    func onPlaylistButtonClick() {
        
    }
    
    func goBack() {
        
    }
    
    func onSwipeUp() {
        
    }
    
    func onSwipeDown() {
        
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylist) {
        
    }
    
    func onMediaAlbumsLoad(dataSource: AlbumsViewDataSource, actionDelegate: AlbumsViewActionDelegate, albumTitles: [String]) {
        
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func searchQueryUpdate(dataSource: SearchViewDataSource, actionDelegate: SearchViewActionDelegate, resultsCount: UInt) {
        
    }
    
    func onSearchResultClick(index: UInt) {
        
    }
    
    func setSearchFieldText(_ text: String) {
        
    }
    
    func onAlbumSongsLoad(name: String,
                          dataSource: PlaylistViewDataSource,
                          actionDelegate: PlaylistViewActionDelegate) {
        
    }
    
    func onPlaylistSongsLoad(name: String,
                             dataSource: PlaylistViewDataSource,
                             actionDelegate: PlaylistViewActionDelegate) {
        
    }
    
    func scrollTo(index: UInt) {
        
    }
    
    func onTrackClicked(index: UInt) {
        
    }
    
    func openPlayerScreen(playlist: AudioPlaylist) {
        
    }
    
    func updatePlayerScreen(playlist: AudioPlaylist) {
        
    }
    
    func onOpenPlaylistButtonClick(audioInfo: AudioInfo) {
        
    }
    
    func onThemeSelect(_ value: AppTheme) {
        
    }
    
    func onTrackSortingSelect(_ value: TrackSorting) {
        
    }
    
    func onShowVolumeBarSelect(_ value: ShowVolumeBar) {
        
    }
    
    func onOpenPlayerOnPlaySelect(_ value: OpenPlayerOnPlay) {
        
    }
    
    func onKeybindSelect(input: ApplicationInput, action: ApplicationAction) {
        
    }
    
    func onResetSettingsDefaults() {
        
    }
    
    func onPlayerErrorEncountered(_ error: Error) {
        
    }
}

extension MainViewController: GeneralStorageObserver {
    func onAppAppearanceChange() {
        clearTabsCache()
    }
    
    func onTabCachingPolicyChange(_ value: TabsCachingPolicy) {
        clearTabsCache()
    }
    
    func onResetDefaultSettings() {
        clearTabsCache()
    }
}

// Actions
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

// Interface operations
extension MainViewController {
    private func resetTabButtonsColor() {
        self.baseView?.albumsButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
        self.baseView?.listsButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
        self.baseView?.searchButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
        self.baseView?.settingsButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
    }
    
    private func updateTabButtonsColor() {
        resetTabButtonsColor()
        
        switch self.selectedTabID {
        case .Albums:
            self.baseView?.albumsButton.tintColor = MainViewController.SELECTED_MENU_BUTTON_COLOR
            break
        case .Lists:
            self.baseView?.listsButton.tintColor = MainViewController.SELECTED_MENU_BUTTON_COLOR
            break
        case .Search:
            self.baseView?.searchButton.tintColor = MainViewController.SELECTED_MENU_BUTTON_COLOR
            break
        case .Settings:
            self.baseView?.settingsButton.tintColor = MainViewController.SELECTED_MENU_BUTTON_COLOR
            break
        default:
            break
        }
    }
}
