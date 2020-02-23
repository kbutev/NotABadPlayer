//
//  CreateListsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 2.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class CreateListsViewController: UIViewController {
    public static let PLAYLIST_NAME_LENGTH_LIMIT = 16
    
    private var baseView: CreateListView?
    private let presenter: CreateListsPresenter
    
    var onOpenedAlbumTrackSelectionCallback: (UInt)->Void = {(index) in }
    var onOpenedAlbumTrackDeselectionCallback: (UInt)->Void = {(index) in }
    
    init(audioInfo: AudioInfo) {
        self.presenter = CreateListsPresenter(audioInfo: audioInfo)
        super.init(nibName: nil, bundle: nil)
        self.presenter.setView(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented decode()")
    }
    
    override func loadView() {
        self.baseView = CreateListView.create(owner: self)
        self.view = self.baseView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter.start()
        
        setup()
    }
    
    private func setup() {
        baseView?.onPlaylistNameFieldEditedCallback = {[weak self] (text) in
            self?.presenter.onPlaylistNameChanged(text)
        }
        
        baseView?.onCancelButtonClickedCallback = {[weak self] () in
            self?.goBack()
        }
        
        baseView?.onDoneButtonClickedCallback = {[weak self] () in
            self?.presenter.onSaveUserPlaylist()
        }
        
        baseView?.onAlbumClickedCallback = {[weak self] (index) in
            self?.presenter.openAlbumAt(index: index)
        }
        
        // When clicking an added track:
        // Remove it from current list model
        // Deselect it from opened album (if there is one)
        baseView?.onAddedTrackClickedCallback = {[weak self] (index: UInt) -> Void in
            self?.presenter.onAddedTrackClicked(at: index)
        }
        
        // When selecting an opened album track:
        // Add it to the current list model
        self.onOpenedAlbumTrackSelectionCallback = {[weak self] (index: UInt) -> Void in
            self?.presenter.onAlbumTrackSelect(fromOpenedAlbumIndex: index)
        }
        
        // When deselecting an opened album track:
        // Remove from to the current list model
        self.onOpenedAlbumTrackDeselectionCallback = {[weak self] (index: UInt) -> Void in
            self?.presenter.onAlbumTrackDeselect(withOpenedAlbumIndex: index)
        }
        
        // Search tracks
        baseView?.onSearchItemClickedCallback = {[weak self] (index) in
            self?.presenter.onSearchResultClick(index: index)
        }
        
        baseView?.onSearchQueryCallback = {[weak self] (text) in
            self?.presenter.onSearchQuery(query: text, filterIndex: 0)
        }
        
        // Switch
        baseView?.onSwitchTrackPickerCallback = {[weak self] () in
            self?.baseView?.reloadAlbumsData()
            self?.baseView?.reloadSearchTracksData()
        }
        
        presenter.updateAlbumsView()
    }
    
    func updateAddedTracksDataSource(_ dataSource: BaseCreateListViewAddedTracksTableDataSource?) {
        baseView?.addedTracksTableDataSource = dataSource
        baseView?.reloadAddedTracksData()
    }
    
    func updateAlbumsDataSource(_ dataSource: BaseCreateListViewAlbumsDataSource?) {
        baseView?.albumsTableDataSource = dataSource
        baseView?.reloadAlbumsData()
    }
    
    func updateSearchTracksDataSource(_ dataSource: BaseSearchViewDataSource?) {
        dataSource?.highlightedChecker = self
        dataSource?.favoritesChecker = self
        
        baseView?.searchTracksTableDataSource = dataSource
        baseView?.reloadSearchTracksData()
    }
    
    func openAlbumAt(index: UInt, albumTracks: [CreateListAudioTrack], addedTracks: [CreateListAudioTrack]) {
        baseView?.openAlbumAt(index: index, albumTracks: albumTracks, addedTracks: addedTracks)
    }
    
    func deselectAddedTrack(_ track: CreateListAudioTrack) {
        baseView?.deselectTrackFromOpenedAlbum(track)
        baseView?.reloadSearchTracksData()
    }
    
    func onSearchResultClick(index: UInt) {
        let dataSource = baseView?.searchTracksTableDataSource
        dataSource?.highlightedChecker = self
        dataSource?.favoritesChecker = self
        
        baseView?.reloadSearchTracksData()
    }
    
    func showPlaylistNameEmptyError() {
        AlertWindows.shared.show(sourceVC: self,
                                 withTitle: Text.value(.Error),
                                 withDescription: Text.value(.ErrorPlaylistNameEmpty))
    }
    
    func showPlaylistEmptyError() {
        AlertWindows.shared.show(sourceVC: self,
                                 withTitle: Text.value(.Error),
                                 withDescription: Text.value(.ErrorPlaylistEmpty))
    }
    
    func showPlaylistAlreadyExistsError() {
        AlertWindows.shared.show(sourceVC: self,
                                 withTitle: Text.value(.Error),
                                 withDescription: Text.value(.ErrorPlaylistAlreadyExists))
    }
    
    func showPlaylistUnknownError() {
        AlertWindows.shared.show(sourceVC: self,
                                 withTitle: Text.value(.Error),
                                 withDescription: Text.value(.ErrorUnknown))
    }
}

// BaseCreateListsPresenterDelegate
extension CreateListsViewController: BaseCreateListsPresenterDelegate {
    func goBack() {
        NavigationHelpers.dismissPresentedVC(self)
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: BaseAudioPlaylist, options: OpenPlaylistOptions) {
        
    }
    
    func onMediaAlbumsLoad(dataSource: BaseAlbumsViewDataSource?, albumTitles: [String]) {
        
    }
    
    func onPlaylistSongsLoad(name: String, dataSource: BasePlaylistViewDataSource?, playingTrackIndex: UInt?) {
        
    }
    
    func onUserPlaylistsLoad(audioInfo: AudioInfo, dataSource: BaseListsViewDataSource?) {
        
    }
    
    func openPlayerScreen(playlist: BaseAudioPlaylist) {
        
    }
    
    func updatePlayerScreen(playlist: BaseAudioPlaylist) {
        
    }
    
    func updateSearchQueryResults(query: String, filterIndex: Int, dataSource: BaseSearchViewDataSource?, resultsCount: UInt, searchTip: String?) {
        updateSearchTracksDataSource(dataSource)
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
        
    }
    
    func onPlayerErrorEncountered(_ error: Error) {
        
    }
}

extension CreateListsViewController : BaseSearchHighlighedChecker, BaseSearchFavoritesChecker {
    func shouldBeHighlighed(item: BaseAudioTrack) -> Bool {
        return presenter.isTrackAdded(item)
    }
    
    func isMarkedFavorite(item: BaseAudioTrack) -> Bool {
        return GeneralStorage.shared.favorites.isMarkedFavorite(item)
    }
}
