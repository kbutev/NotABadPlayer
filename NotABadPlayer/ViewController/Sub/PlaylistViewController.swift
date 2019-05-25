//
//  AlbumsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol PlaylistViewDelegate : class {
    func onAlbumSongsLoad(name: String,
                          dataSource: PlaylistViewDataSource,
                          actionDelegate: PlaylistViewActionDelegate)
    func onPlaylistSongsLoad(name: String,
                             dataSource: PlaylistViewDataSource,
                             actionDelegate: PlaylistViewActionDelegate)
    func scrollTo(index: UInt)
    func onTrackClicked(index: UInt)
    func openPlayerScreen(playlist: AudioPlaylist)
    
    func onScrollDown()
    func onSwipeRight()
}

class PlaylistViewController: UIViewController, BaseViewController {
    private var baseView: PlaylistView?
    
    public var presenter: BasePresenter?
    
    override func loadView() {
        self.baseView = PlaylistView.create(owner: self)
        self.view = self.baseView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.start()
        
        self.baseView?.quickPlayerDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        baseView?.reloadData()
        
        QuickPlayerService.shared.attach(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        QuickPlayerService.shared.detach(observer: self)
    }
    
    func goBack() {
        NavigationHelpers.removeVCChild(self)
    }
    
    func onSwipeUp() {
        if let playlist = AudioPlayer.shared.playlist
        {
            openPlayerScreen(playlist: playlist)
        }
    }
    
    func onScrollDown() {
        baseView?.updateScrollState()
    }
    
    func onSwipeDown() {
        
    }
    
    func onPlayerSeekChanged(positionInPercentage: Double) {
        
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        presenter?.onPlayerButtonClick(input: input)
    }
    
    func onPlayOrderButtonClick() {
        presenter?.onPlayOrderButtonClick()
    }
    
    func onPlaylistButtonClick() {
        presenter?.onOpenPlaylistButtonClick()
    }
}

extension PlaylistViewController : PlaylistViewDelegate {
    func onAlbumSongsLoad(name: String,
                          dataSource: PlaylistViewDataSource,
                          actionDelegate: PlaylistViewActionDelegate) {
        self.baseView?.collectionDataSource = dataSource
        self.baseView?.collectionDelegate = actionDelegate
        self.baseView?.updateOverlayTitle(title: name)
        self.baseView?.reloadData()
    }
    
    func onPlaylistSongsLoad(name: String,
                             dataSource: PlaylistViewDataSource,
                             actionDelegate: PlaylistViewActionDelegate) {
        self.baseView?.collectionDataSource = dataSource
        self.baseView?.collectionDelegate = actionDelegate
        self.baseView?.updateOverlayTitle(title: name)
        self.baseView?.reloadData()
    }
    
    func scrollTo(index: UInt) {
        self.baseView?.scrollDownToSelectedTrack(index: index)
    }
    
    func onTrackClicked(index: UInt) {
        self.presenter?.onPlaylistItemClick(index: index)
    }
    
    func openPlayerScreen(playlist: AudioPlaylist) {
        let presenter = PlayerPresenter(playlist: playlist)
        let vc = PlayerViewController()
        vc.presenter = presenter
        presenter.delegate = vc
        
        NavigationHelpers.showVC(current: self, vc: vc)
    }
    
    func onSwipeRight() {
        NavigationHelpers.removeVCChild(self)
    }
}

extension PlaylistViewController : QuickPlayerObserver {
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
