//
//  AlbumsPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 30.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

public enum AlbumsPresenterError: Error {
    case AlbumDoesNotExist
}

extension AlbumsPresenterError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .AlbumDoesNotExist:
            return Text.value(.ErrorAlbumDoesNotExist)
        }
    }
}

class AlbumsPresenter: BasePresenter
{
    private weak var delegate: BaseViewDelegate?
    
    private let audioInfo: AudioInfo
    private var albums: [AudioAlbum] = []
    
    private var collectionDataSource: AlbumsViewDataSource?
    
    required init(audioInfo: AudioInfo) {
        self.audioInfo = audioInfo
    }
    
    func setView(_ delegate: BaseViewDelegate) {
        self.delegate = delegate
    }
    
    func start() {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: AlbumsPresenter.self))")
        }
        
        self.albums = audioInfo.getAlbums()
        
        let dataSource = AlbumsViewDataSource(audioInfo: audioInfo, albums: albums)
        self.collectionDataSource = dataSource
        
        var albumTitles: [String] = []
        
        for album in self.albums
        {
            albumTitles.append(album.albumTitle)
        }
        
        delegate.onMediaAlbumsLoad(dataSource: dataSource, albumTitles: albumTitles)
    }
    
    func onAppStateChange(state: AppState) {
        
    }
    
    func onAlbumClick(index: UInt) {
        let album = self.albums[Int(index)]
        
        Logging.log(AlbumsPresenter.self, "Open playlist screen for album '\(album.albumTitle)'")
        
        let tracks = audioInfo.getAlbumTracks(album: album)
        let playlist = AudioPlaylist(name: album.albumTitle, tracks: tracks)
        
        self.delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist)
    }
    
    func onPlaylistItemClick(index: UInt) {
        
    }
    
    func onOpenPlayer(playlist: AudioPlaylist) {
        Logging.log(AlbumsPresenter.self, "Open player screen")
        
        self.delegate?.openPlayerScreen(playlist: playlist)
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        let action = Keybinds.shared.getActionFor(input: input)
        
        Logging.log(AlbumsPresenter.self, "Perform KeyBinds action '\(action.rawValue)' for input '\(input.rawValue)'")
        
        let _ = Keybinds.shared.performAction(action: action)
    }
    
    func onPlayOrderButtonClick() {
        Logging.log(AlbumsPresenter.self, "Change play order")
        
        let _ = Keybinds.shared.performAction(action: .CHANGE_PLAY_ORDER)
    }
    
    func onOpenPlaylistButtonClick() {
        guard let playlist = AudioPlayer.shared.playlist else {
            return
        }
        
        Logging.log(AlbumsPresenter.self, "Open playlist screen for playlist '\(playlist.name)'")
        
        delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist)
    }
    
    func onPlaylistItemDelete(index: UInt) {
        
    }
    
    func onSearchResultClick(index: UInt) {
        
    }
    
    func onSearchQuery(_ query: String) {
        
    }
    
    func onAppSettingsReset() {
        
    }
    
    func onAppThemeChange(_ themeValue: AppTheme) {
        
    }
    
    func onTrackSortingSettingChange(_ trackSorting: TrackSorting) {
        
    }
    
    func onShowVolumeBarSettingChange(_ value: ShowVolumeBar) {
        
    }
    
    func onOpenPlayerOnPlaySettingChange(_ value: OpenPlayerOnPlay) {
        
    }
    
    func onKeybindChange(input: ApplicationInput, action: ApplicationAction) {
        
    }
}
