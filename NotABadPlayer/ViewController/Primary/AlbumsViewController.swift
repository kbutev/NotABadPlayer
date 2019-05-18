//
//  AlbumsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol AlbumsViewDelegate : NSObject {
    func onMediaAlbumsLoad(dataSource: AlbumsViewDataSource, actionDelegate: AlbumsViewActionDelegate)
    func onAlbumClick(index: UInt)
    
    func openPlaylistScreen(audioInfo: AudioInfo, album: AudioAlbum)
}

class AlbumsViewController: UIViewController, BaseViewController {
    private var baseView: AlbumsView?
    
    public var presenter: BasePresenter?
    
    private var subViewController: PlaylistViewController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.baseView = AlbumsView.create(owner: self)
        self.view = self.baseView!
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
        self.subViewController?.goBack()
        self.subViewController = nil
    }
    
    func onSwipeUp() {
        if let playlist = AudioPlayer.shared.playlist
        {
            openPlayerScreen(playlist: playlist)
        }
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
    
    func openPlayerScreen(playlist: AudioPlaylist) {
        let presenter = PlayerPresenter(playlist: playlist)
        let vc = PlayerViewController(withPresenter: presenter)
        presenter.delegate = vc
        
        NavigationHelpers.showVC(current: self, vc: vc)
    }
}

extension AlbumsViewController : AlbumsViewDelegate {
    func onMediaAlbumsLoad(dataSource: AlbumsViewDataSource, actionDelegate: AlbumsViewActionDelegate) {
        self.baseView?.collectionDataSource = dataSource
        self.baseView?.collectionDelegate = actionDelegate
        self.baseView?.reloadData()
    }
    
    func onAlbumClick(index: UInt) {
        self.presenter?.onAlbumClick(index: index)
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, album: AudioAlbum) {
        if self.subViewController != nil
        {
            fatalError("Logic error in \(String(describing: AlbumsViewController.self)), cannot open playlist, its already open")
        }
        
        let tracks = audioInfo.getAlbumTracks(album: album)
        let playlist = AudioPlaylist(name: album.albumTitle, tracks: tracks, startWithTrack: tracks.first)
        
        let presenter = PlaylistPresenter(audioInfo: audioInfo, playlist: playlist)
        
        let vc = PlaylistViewController(withPresenter: presenter)
        
        self.subViewController = vc
        
        presenter.delegate = vc
        
        PlaylistViewControllerHelpers.addVCChild(parent: self, child: vc)
    }
}

extension AlbumsViewController : QuickPlayerObserver {
    func updateTime(currentTime: Double, totalDuration: Double) {
        baseView?.updateTime(currentTime: currentTime, totalDuration: totalDuration)
    }
    
    func updateMediaInfo(track: AudioTrack) {
        baseView?.updateMediaInfo(track: track)
    }
    
    func updateButtonsStates(isPlaying: Bool) {
        baseView?.updateButtonsStates(playing: isPlaying)
    }
    
    func updatePlayOrderButtonState(playOrder: AudioPlayOrder) {
        baseView?.updatePlayOrderButtonState(playOrder: playOrder)
    }
}
