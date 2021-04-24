//
//  ListsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol ListsViewControllerProtocol: BaseView {
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylistProtocol, options: OpenPlaylistOptions)
    
    func onUserPlaylistsLoad(audioInfo: AudioInfo, dataSource: BaseListsViewDataSource?)
    
    func openPlayerScreen(playlist: AudioPlaylistProtocol)
    
    func openCreateListsScreen(with editPlaylist: AudioPlaylistProtocol?)
    
    func onFetchDataErrorEncountered(_ error: Error)
    func onPlayerErrorEncountered(_ error: Error)
}

class ListsViewController: UIViewController, ListsViewControllerProtocol {
    private var baseView: ListsView?
    
    private let presenter: ListsPresenterProtocol?
    
    private var playlistsDataSource: BaseListsViewDataSource?
    
    private var subViewController: PlaylistViewController?
    private var subViewControllerPlaylistName: String = ""
    
    private var audioInfo: AudioInfo?
    
    private var isEditingLists: Bool = false
    
    init(presenter: ListsPresenterProtocol) {
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
            self?.openCreateListsScreen(with: nil)
        }
        
        baseView?.onEditButtonClickedCallback = { [weak self] () in
            self?.startOrEndEditing()
        }
        
        baseView?.onPlaylistClickedCallback = { [weak self] (index) in
            self?.presenter?.onPlaylistItemClick(index: index)
        }
        
        baseView?.onPlaylistEditClickedCallback = { [weak self] (index: UInt) -> Void in
            self?.presenter?.onPlaylistItemEdit(index: index)
        }
        
        baseView?.onPlaylistDeleteCallback = { [weak self] (index: UInt) -> Void in
            self?.presenter?.onPlaylistItemDelete(index: index)
        }
        
        baseView?.onQuickPlayerPlaylistButtonClickCallback = { [weak self] () in
            self?.presenter?.onQuickOpenPlaylistButtonClick()
        }
        
        baseView?.onQuickPlayerButtonClickCallback = { [weak self] (input) in
            self?.presenter?.onPlayerButtonClick(input: input)
        }
        
        baseView?.onQuickPlayerPlayOrderButtonClickCallback = { [weak self] () in
            self?.presenter?.onPlayOrderButtonClick()
        }
        
        baseView?.onQuickPlayerSwipeUpCallback = { [weak self] () in
            if let currentlyPlaying = AudioPlayerService.shared.playlist
            {
                self?.presenter?.onOpenPlayer(playlist: currentlyPlaying)
            }
        }
        
        baseView?.canDeletePlaylistCondition = { [weak self] (index: UInt) -> Bool in
            if let dataSource = self?.playlistsDataSource {
                if index >= 0 && index < dataSource.count {
                    return !dataSource.data(at: index).isTemporary
                }
            }
            
            return false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter?.fetchData()
        
        // Make sure we are not in deletion mode, when resuming
        endEditing()
        
        // Attach quick player
        QuickPlayerService.shared.attach(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        QuickPlayerService.shared.detach(observer: self)
    }
    
    // ListsViewControllerProtocol
    
    func goBack() {
        self.subViewController?.goBack()
        self.subViewController = nil
        self.subViewControllerPlaylistName = ""
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylistProtocol, options: OpenPlaylistOptions) {
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
        
        let presenter = PlaylistPresenter(audioInfo: audioInfo, playlist: playlist, options: options)
        let vc = PlaylistViewController(presenter: presenter, rootView: self)
        
        presenter.delegate = vc
        self.subViewController = vc
        self.subViewControllerPlaylistName = playlist.name
        
        NavigationHelpers.addVCChild(parent: self, child: vc)
    }
    
    func onUserPlaylistsLoad(audioInfo: AudioInfo, dataSource: BaseListsViewDataSource?) {
        self.audioInfo = audioInfo
        self.playlistsDataSource = dataSource
        
        self.baseView?.tableDataSource = dataSource
        self.baseView?.reloadData()
    }
    
    func openPlayerScreen(playlist: AudioPlaylistProtocol) {
        let presenter = PlayerPresenter(playlist: playlist)
        let vc = PlayerViewController(presenter: presenter)
        
        presenter.delegate = vc
        
        NavigationHelpers.presentVC(current: self, vc: vc)
    }
    
    func openCreateListsScreen(with editPlaylist: AudioPlaylistProtocol?) {
        guard let audioInfo = self.audioInfo else {
            return
        }
        
        let vc = CreateListsViewController(audioInfo: audioInfo, editPlaylist: editPlaylist)
        
        NavigationHelpers.presentVC(current: self, vc: vc)
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
    
    public func startOrEndEditing() {
        if !isEditingLists
        {
            baseView?.startEditingLists()
        }
        else
        {
            baseView?.endEditingLists()
        }
        
        isEditingLists = !isEditingLists
    }
    
    public func endEditing() {
        if !isEditingLists {
            return
        }
        
        isEditingLists = false
        baseView?.endEditingLists()
    }
}

extension ListsViewController : QuickPlayerObserver {
    func updateTime(currentTime: Double, totalDuration: Double) {
        baseView?.updateTime(currentTime: currentTime, totalDuration: totalDuration)
    }
    
    func updateMediaInfo(track: AudioTrackProtocol) {
        baseView?.updateMediaInfo(track: track)
    }
    
    func updatePlayButtonState(isPlaying: Bool) {
        baseView?.updatePlayButtonState(isPlaying: isPlaying)
    }
    
    func updatePlayOrderButtonState(order: AudioPlayOrder) {
        baseView?.updatePlayOrderButtonState(order: order)
    }
    
    func onVolumeChanged(volume: Double) {
        
    }
}
