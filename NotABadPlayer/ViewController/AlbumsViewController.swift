//
//  AlbumsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol AlbumsViewControllerProtocol: BaseView {
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylistProtocol, options: OpenPlaylistOptions)
    
    func onMediaAlbumsLoad(dataSource: AlbumsViewDataSource?, albumTitles: [String])
    
    func openPlayerScreen(playlist: AudioPlaylistProtocol)
    
    func onAudioLibraryChanged()
    
    func onFetchDataErrorEncountered(_ error: Error)
    func onPlayerErrorEncountered(_ error: Error)
}

class AlbumsViewController: UIViewController, AlbumsViewControllerProtocol {
    var baseView: AlbumsView? {
        return self.view as? AlbumsView
    }
    
    private let presenter: AlbumsPresenterProtocol?
    
    private var subViewController: PlaylistViewController?
    private var subViewControllerPlaylistName: String = ""
    
    init(presenter: AlbumsPresenterProtocol) {
        self.presenter = presenter
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
        // User input
        baseView?.onAlbumClickCallback = { [weak self] (index) in
            self?.presenter?.onAlbumClick(index: index)
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
    
    // AlbumsViewControllerProtocol
    
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
                Logging.log(AlbumsViewController.self, "No need to open playlist screen, its already open for the correct playlist")
                return
            }
            
            Logging.log(AlbumsViewController.self, "Close current playlist screen, and reopen it for the correct playlist")
            goBack()
        }
        
        let presenter = PlaylistPresenter(audioInfo: audioInfo, playlist: playlist, options: options)
        let vc = PlaylistViewController(presenter: presenter, rootView: self)
        
        presenter.delegate = vc
        self.subViewController = vc
        self.subViewControllerPlaylistName = playlist.name
        
        NavigationHelpers.addVCChild(parent: self, child: vc, animation: .scaleUp)
    }
    
    func onMediaAlbumsLoad(dataSource: AlbumsViewDataSource?, albumTitles: [String]) {
        self.baseView?.collectionDataSource = dataSource
        self.baseView?.updateIndexerAlphabet(albumTitles: albumTitles)
        self.baseView?.reloadData()
    }
    
    func openPlayerScreen(playlist: AudioPlaylistProtocol) {
        let presenter = PlayerPresenter(playlist: playlist)
        let vc = PlayerViewController(presenter: presenter)
        
        presenter.delegate = vc
        
        NavigationHelpers.presentVC(current: self, vc: vc)
    }
    
    func onAudioLibraryChanged() {
        Toast.show(message: Text.value(.AlbumsLibraryChanged), controller: self)
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
}

extension AlbumsViewController : QuickPlayerObserver {
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
