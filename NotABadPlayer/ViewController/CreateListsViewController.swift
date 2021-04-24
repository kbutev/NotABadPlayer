//
//  CreateListsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 2.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol CreateListsViewControllerProtocol: BaseView {
    var searchView: SearchViewControllerProtocol { get }
}

class CreateListsViewController: UIViewController, CreateListsViewControllerProtocol, SearchViewControllerProtocol, CreateListsPresenterDelegate {
    public static let PLAYLIST_NAME_LENGTH_LIMIT = 16
    
    var baseView: CreateListView? {
        return self.view as? CreateListView
    }
    
    var searchView: SearchViewControllerProtocol {
        return self
    }
    
    private let presenter: CreateListsPresenter
    
    private let isEditingPlaylist: Bool
    private let editingPlaylistName: String
    
    var onOpenedAlbumTrackSelectionCallback: (UInt)->Void = {(index) in }
    var onOpenedAlbumTrackDeselectionCallback: (UInt)->Void = {(index) in }
    
    init(audioInfo: AudioInfo, editPlaylist: AudioPlaylistProtocol?) {
        self.isEditingPlaylist = editPlaylist != nil
        self.editingPlaylistName = editPlaylist?.name ?? ""
        self.presenter = CreateListsPresenter(audioInfo: audioInfo, editPlaylist: editPlaylist)
        super.init(nibName: nil, bundle: nil)
        self.presenter.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented decode()")
    }
    
    override func loadView() {
        self.view = CreateListView.create(owner: self)
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
        
        // Disable and update name field if editing
        if self.isEditingPlaylist {
            baseView?.playlistNameField.text = self.editingPlaylistName
            baseView?.playlistNameField.isEnabled = false
            
            baseView?.doneButton.setTitle(Text.value(.CreateListDoneForUpdateButton), for: .normal)
        }
        
        presenter.updateAlbumsView()
    }
    
    // CreateListsPresenterDelegate
    
    func updateAddedTracksDataSource(_ dataSource: BaseCreateListAddedTracksTableDataSource?) {
        baseView?.addedTracksTableDataSource = dataSource
        baseView?.reloadAddedTracksData()
    }
    
    func updateAlbumsDataSource(_ dataSource: BaseCreateListViewAlbumsDataSource?) {
        baseView?.albumsTableDataSource = dataSource
        baseView?.reloadAlbumsData()
    }
    
    func updateSearchTracksDataSource(_ dataSource: SearchViewDataSource?) {
        dataSource?.highlightedChecker = self
        dataSource?.favoritesChecker = self
        dataSource?.animateHighlightedCells = false
        
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
        dataSource?.animateHighlightedCells = false
        
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
    
    // CreateListsViewControllerProtocol
    
    func goBack() {
        NavigationHelpers.dismissPresentedVC(self)
    }
    
    // SearchViewControllerProtocol
    
    func openPlayerScreen(playlist: AudioPlaylistProtocol) {
        
    }
    
    func updatePlayerScreen(playlist: AudioPlaylistProtocol) {
        
    }
    
    func onFetchDataErrorEncountered(_ error: Error) {
        
    }
    
    func onPlayerErrorEncountered(_ error: Error) {
        
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylistProtocol, options: OpenPlaylistOptions) {
        
    }
    
    func onSearchQueryBegin() {
        updateSearchTracksDataSource(nil)
        baseView?.showLoadingIndicator(true)
    }
    
    func updateSearchQueryResults(query: String, filterIndex: Int, dataSource: SearchViewDataSource?, resultsCount: UInt) {
        updateSearchTracksDataSource(dataSource)
        baseView?.showLoadingIndicator(false)
    }
}

extension CreateListsViewController : SearchHighlighedChecker, SearchFavoritesChecker {
    func shouldBeHighlighed(item: AudioTrackProtocol) -> Bool {
        return presenter.isTrackAdded(item)
    }
    
    func isMarkedFavorite(item: AudioTrackProtocol) -> Bool {
        return GeneralStorage.shared.favorites.isMarkedFavorite(item)
    }
}
