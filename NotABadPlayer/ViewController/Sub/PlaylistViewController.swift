//
//  AlbumsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol PlaylistViewDelegate : class {
    func onAlbumSongsLoad(dataSource: PlaylistViewDataSource, actionDelegate: PlaylistViewActionDelegate, scrollToIndex: UInt?)
    func onTrackClicked(index: UInt)
    func openPlayerScreen(playlist: AudioPlaylist)
    
    func onSwipeRight()
}

class PlaylistViewController: UIViewController, BaseViewController {
    private var baseView: PlaylistView?
    
    public var presenter: BasePresenter?
    
    init(withPresenter presenter: BasePresenter) {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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
    func onAlbumSongsLoad(dataSource: PlaylistViewDataSource, actionDelegate: PlaylistViewActionDelegate, scrollToIndex: UInt?) {
        self.baseView?.collectionDataSource = dataSource
        self.baseView?.collectionDelegate = actionDelegate
        self.baseView?.reloadData()
        
        if let scrollIndex = scrollToIndex
        {
            self.baseView?.scrollDownToSelectedTrack(index: scrollIndex)
        }
    }
    
    func onTrackClicked(index: UInt) {
        self.presenter?.onPlaylistItemClick(index: index)
    }
    
    func openPlayerScreen(playlist: AudioPlaylist) {
        let presenter = PlayerPresenter(playlist: playlist)
        let vc = PlayerViewController(withPresenter: presenter)
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

class PlaylistViewControllerHelpers {
    static func addVCChild(parent: UIViewController, child: PlaylistViewController) {
        let width = parent.view.bounds.width
        let height = parent.view.bounds.height
        let size = CGSize(width: width, height: height)
        
        NavigationHelpers.addVCChild(parent: parent, child: child, size: size, anchor: .bottom)
    }
}
