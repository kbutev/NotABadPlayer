//
//  SearchViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol SearchViewControllerProtocol: BasePlayingView {
    func openPlayerScreen(playlist: AudioPlaylistProtocol)
    func updatePlayerScreen(playlist: AudioPlaylistProtocol)
    
    func onSearchQueryBegin()
    func updateSearchQueryResults(query: String, filterIndex: Int, dataSource: SearchViewDataSource?, resultsCount: UInt)
    
    func onFetchDataErrorEncountered(_ error: Error)
    func onPlayerErrorEncountered(_ error: Error)
}

class SearchViewController: UIViewController, SearchViewControllerProtocol {
    private var baseView: SearchView?
    
    private var presenter: SearchPresenterProtocol?
    
    private var subViewController: PlaylistViewController?
    private var subViewControllerPlaylistName: String = ""
    
    private var searchFieldText: String = ""
    private var searchFilterPickedIndex: Int = 0
    
    init(presenter: SearchPresenterProtocol?) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.presenter = nil
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.baseView = SearchView.create(owner: self)
        self.view = self.baseView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        presenter?.start()
    }
    
    private func setup() {
        baseView?.onSearchResultClickedCallback = {[weak self] (index) in
            self?.presenter?.onSearchResultClick(index: index)
        }
        
        baseView?.onSearchFieldTextEnteredCallback = {[weak self] (text) in
            if let strongSelf = self
            {
                strongSelf.searchFieldText = text
                strongSelf.presenter?.onSearchQuery(query: text, filterIndex: strongSelf.searchFilterPickedIndex)
            }
        }
        
        baseView?.onSearchFilterPickedCallback = {[weak self] (index) in
            if let strongSelf = self
            {
                strongSelf.searchFilterPickedIndex = index
                strongSelf.presenter?.onSearchQuery(query: strongSelf.searchFieldText, filterIndex: index)
            }
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
        QuickPlayerService.shared.attach(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        QuickPlayerService.shared.detach(observer: self)
    }
    
    // SearchViewControllerProtocol
    
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
                Logging.log(SearchViewController.self, "No need to open playlist screen, its already open for the correct playlist")
                return
            }
            
            Logging.log(SearchViewController.self, "Close current playlist screen, and reopen it for the correct playlist")
            goBack()
        }
        
        let presenter = PlaylistPresenter(audioInfo: audioInfo, playlist: playlist, options: options)
        let vc = PlaylistViewController(presenter: presenter, rootView: self)
        
        presenter.delegate = vc
        self.subViewController = vc
        self.subViewControllerPlaylistName = playlist.name
        
        NavigationHelpers.addVCChild(parent: self, child: vc)
    }
    
    func openPlayerScreen(playlist: AudioPlaylistProtocol) {
        let presenter = PlayerPresenter(playlist: playlist)
        let vc = PlayerViewController(presenter: presenter)
        
        presenter.delegate = vc
        
        NavigationHelpers.presentVC(current: self, vc: vc)
    }
    
    func updatePlayerScreen(playlist: AudioPlaylistProtocol) {
        
    }
    
    func onSearchQueryBegin() {
        baseView?.collectionDataSource = nil
        baseView?.updateSearchDescriptionToLoading()
        baseView?.reloadData()
        
        baseView?.showLoadingIndicator()
    }
    
    func updateSearchQueryResults(query: String, filterIndex: Int, dataSource: SearchViewDataSource?, resultsCount: UInt) {
        searchFieldText = query
        searchFilterPickedIndex = filterIndex
        
        baseView?.collectionDataSource = dataSource
        baseView?.highlightedChecker = self
        baseView?.favoritesChecker = self
        baseView?.setTextFieldText(query)
        baseView?.setTextFilterIndex(filterIndex)
        baseView?.updateSearchDescription(resultsCount: resultsCount)
        
        baseView?.hideLoadingIndicator()
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

extension SearchViewController : QuickPlayerObserver {
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

extension SearchViewController : SearchHighlighedChecker, SearchFavoritesChecker {
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
