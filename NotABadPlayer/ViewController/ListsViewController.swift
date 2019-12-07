//
//  ListsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class ListsViewController: UIViewController, BaseViewDelegate {
    private var baseView: ListsView?
    
    private let presenter: BasePresenter?
    
    private var playlistsDataSource: BaseListsViewDataSource?
    
    private var subViewController: PlaylistViewController?
    private var subViewControllerPlaylistName: String = ""
    
    private var audioInfo: AudioInfo?
    
    private var isEditingLists: Bool = false
    
    init(presenter: BasePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.presenter = nil
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.baseView = ListsView.create(owner: self)
        self.view = self.baseView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        presenter?.start()
    }
    
    private func setup() {
        baseView?.onCreateButtonClickedCallback = { [weak self] () in
            self?.openCreateListsScreen()
        }
        
        baseView?.onDeleteButtonClickedCallback = { [weak self] () in
            self?.startOrEndEditing()
        }
        
        baseView?.onPlaylistClickedCallback = { [weak self] (index) in
            self?.presenter?.onPlaylistItemClick(index: index)
        }
        
        baseView?.onPrepareDeletePlaylistCallback = { [weak self] (index: UInt) -> Bool in
            if let dataSource = self?.playlistsDataSource {
                if index >= 0 && index < dataSource.count {
                    return !dataSource.data(at: index).isTemporary
                }
            }
            
            return false
        }
        
        baseView?.onDidDeletePlaylistCallback = { [weak self] (index: UInt) -> Void in
            self?.presenter?.onPlaylistItemDelete(index: index)
        }
        
        baseView?.onQuickPlayerPlaylistButtonClickCallback = { [weak self] () in
            self?.presenter?.onOpenPlaylistButtonClick()
        }
        
        baseView?.onQuickPlayerButtonClickCallback = { [weak self] (input) in
            self?.presenter?.onPlayerButtonClick(input: input)
        }
        
        baseView?.onQuickPlayerPlayOrderButtonClickCallback = { [weak self] () in
            self?.presenter?.onPlayOrderButtonClick()
        }
        
        baseView?.onQuickPlayerSwipeUpCallback = { [weak self] () in
            if let currentlyPlaying = AudioPlayer.shared.playlist
            {
                self?.presenter?.onOpenPlayer(playlist: currentlyPlaying)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter?.fetchData()
        
        // Make sure we are not in deletion mode, when resuming
        baseView?.endDeletingLists()
        
        // Attach quick player
        QuickPlayerService.shared.attach(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        QuickPlayerService.shared.detach(observer: self)
    }
    
    func goBack() {
        self.subViewController?.goBack()
        self.subViewController = nil
        self.subViewControllerPlaylistName = ""
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: BaseAudioPlaylist) {
        if self.subViewController != nil
        {
            // Correct playlist is already open? Do nothing
            if playlist.name == self.subViewControllerPlaylistName
            {
                Logging.log(ListsViewController.self, "No need to open playlist screen, its already open for the correct playlist")
                return
            }
            
            Logging.log(ListsViewController.self, "Close current playlist screen, and reopen it for the correct playlist")
            goBack()
        }
        
        let presenter = PlaylistPresenter(audioInfo: audioInfo, playlist: playlist)
        let vc = PlaylistViewController(presenter: presenter, rootView: self)
        
        presenter.setView(vc)
        self.subViewController = vc
        self.subViewControllerPlaylistName = playlist.name
        
        NavigationHelpers.addVCChild(parent: self, child: vc)
    }
    
    func onMediaAlbumsLoad(dataSource: BaseAlbumsViewDataSource?, albumTitles: [String]) {
        
    }
    
    func onPlaylistSongsLoad(name: String, dataSource: BasePlaylistViewDataSource?, playingTrackIndex: UInt?) {
        
    }
    
    func onUserPlaylistsLoad(audioInfo: AudioInfo, dataSource: BaseListsViewDataSource?) {
        self.audioInfo = audioInfo
        self.playlistsDataSource = dataSource
        
        self.baseView?.tableDataSource = dataSource
        self.baseView?.reloadData()
    }
    
    func openPlayerScreen(playlist: BaseAudioPlaylist) {
        let presenter = PlayerPresenter(playlist: playlist)
        let vc = PlayerViewController(presenter: presenter)
        
        presenter.setView(vc)
        
        NavigationHelpers.presentVC(current: self, vc: vc)
    }
    
    func updatePlayerScreen(playlist: BaseAudioPlaylist) {
        
    }
    
    func updateSearchQueryResults(query: String, filterIndex: Int, dataSource: BaseSearchViewDataSource?, resultsCount: UInt, searchTip: String?) {
        
    }
    
    func onResetSettingsDefaults() {
        
    }
    
    func onThemeSelect(_ value: AppThemeValue) {
        
    }
    
    func onTrackSortingSelect(_ value: TrackSorting) {
        
    }
    
    func onShowVolumeBarSelect(_ value: ShowVolumeBar) {
        
    }
    
    func onAudioLibraryChanged() {
        
    }
    
    func onFetchDataErrorEncountered(_ error: Error) {
        // Fetch data again until successful
        presenter?.fetchData()
    }
    
    func onPlayerErrorEncountered(_ error: Error) {
        AlertWindows.shared.show(sourceVC: self,
                                 withTitle: "Error",
                                 withDescription: error.localizedDescription,
                                 actionText: "Ok",
                                 action: nil)
    }
    
    private func openCreateListsScreen() {
        guard let audioInfo = self.audioInfo else {
            return
        }
        
        let vc = CreateListsViewController(audioInfo: audioInfo)
        
        NavigationHelpers.presentVC(current: self, vc: vc)
    }
    
    public func startOrEndEditing() {
        if !isEditingLists
        {
            baseView?.startDeletingLists()
        }
        else
        {
            baseView?.endDeletingLists()
        }
        
        isEditingLists = !isEditingLists
    }
}

extension ListsViewController : QuickPlayerObserver {
    func updateTime(currentTime: Double, totalDuration: Double) {
        baseView?.updateTime(currentTime: currentTime, totalDuration: totalDuration)
    }
    
    func updateMediaInfo(track: AudioTrack) {
        baseView?.updateMediaInfo(track: track)
    }
    
    func updatePlayButtonState(isPlaying: Bool) {
        baseView?.updatePlayButtonState(playing: isPlaying)
    }
    
    func updatePlayOrderButtonState(order: AudioPlayOrder) {
        baseView?.updatePlayOrderButtonState(order: order)
    }
}
