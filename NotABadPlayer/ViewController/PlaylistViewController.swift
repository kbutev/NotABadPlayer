//
//  AlbumsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol PlaylistViewControllerProtocol: BaseView {
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylistProtocol, options: OpenPlaylistOptions)
    
    func onPlaylistSongsLoad(name: String, dataSource: BasePlaylistViewDataSource?, playingTrackIndex: UInt?)
    
    func openPlayerScreen(playlist: AudioPlaylistProtocol)
    func updatePlayerScreen(playlist: AudioPlaylistProtocol)
    
    func onFetchDataErrorEncountered(_ error: Error)
    func onPlayerErrorEncountered(_ error: Error)
}

class PlaylistViewController: UIViewController, PlaylistViewControllerProtocol {
    var baseView: PlaylistView? {
        return self.view as? PlaylistView
    }
    
    private let presenter: PlaylistPresenterProtocol?
    private let rootView: BaseView?
    
    private var favoritesChecker: BasePlaylistFavoritesChecker?
    
    init(presenter: PlaylistPresenterProtocol, rootView: BaseView) {
        self.presenter = presenter
        self.rootView = rootView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented decode()")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        presenter?.start()
    }
    
    private func setup() {
        baseView?.onTrackClickedCallback = {[weak self] (index) in
            self?.presenter?.onPlaylistItemClick(index: index)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        baseView?.reloadData()
        
        QuickPlayerService.shared.attach(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        QuickPlayerService.shared.detach(observer: self)
    }
    
    // PlaylistViewControllerProtocol
    
    func goBack() {
        // This is called by the parent when we call their goBack()
        NavigationHelpers.removeVCChild(self)
    }
    
    func goBackReal() {
        // Call this to tell the parent to go back, which will cause this instance's goBack() to be called
        rootView?.goBack()
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylistProtocol, options: OpenPlaylistOptions) {
        // Forward request to delegate
        let playlistView = rootView as? BasePlayingView
        playlistView?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist, options: options)
    }
    
    func onPlaylistSongsLoad(name: String, dataSource: BasePlaylistViewDataSource?, playingTrackIndex: UInt?) {
        self.baseView?.collectionDataSource = dataSource
        self.baseView?.highlightedChecker = self
        self.baseView?.favoritesChecker = self
        self.baseView?.updateOverlayTitle(title: name)
        
        if let scrollToIndex = playingTrackIndex
        {
            self.baseView?.scrollDownToSelectedTrack(index: scrollToIndex)
        }
        
        self.baseView?.reloadData()
    }
    
    func openPlayerScreen(playlist: AudioPlaylistProtocol) {
        let presenter = PlayerPresenter(playlist: playlist)
        let vc = PlayerViewController(presenter: presenter)
        
        presenter.delegate = vc
        
        NavigationHelpers.presentVC(current: self, vc: vc)
    }
    
    func updatePlayerScreen(playlist: AudioPlaylistProtocol) {
        
    }
    
    func onFetchDataErrorEncountered(_ error: Error) {
        
    }
    
    func onPlayerErrorEncountered(_ error: Error) {
        AlertWindows.shared.show(sourceVC: self,
                                 withTitle: "Error",
                                 withDescription: error.localizedDescription,
                                 actionText: "Ok",
                                 action: nil)
    }
}

extension PlaylistViewController : QuickPlayerObserver {
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

extension PlaylistViewController : BasePlaylistHighlighedChecker, BasePlaylistFavoritesChecker {
    func shouldBeHighlighed(item: AudioTrackProtocol) -> Bool {
        if let playlist = AudioPlayerService.shared.playlist {
            return playlist.playingTrack == item
        }
        
        return false
    }
    
    func isMarkedFavorite(item: AudioTrackProtocol) -> Bool {
        return GeneralStorage.shared.favorites.isMarkedFavorite(item)
    }
}
