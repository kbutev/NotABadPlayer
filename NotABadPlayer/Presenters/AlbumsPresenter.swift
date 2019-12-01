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
        guard self.delegate != nil else {
            fatalError("Delegate is not set for \(String(describing: AlbumsPresenter.self))")
        }
        
        fetchData()
    }
    
    func fetchData() {
        Logging.log(AlbumsPresenter.self, "Retrieving albums...")
        
        // Perform work on background thread
        DispatchQueue.global().async {
            let audioInfo = self.audioInfo
            
            let albums = audioInfo.getAlbums()
            
            let dataSource = AlbumsViewDataSource(audioInfo: audioInfo, albums: albums)
            
            var albumTitles: [String] = []
            
            for album in albums
            {
                albumTitles.append(album.albumTitle)
            }
            
            // Then, update on main thread
            DispatchQueue.main.async {
                Logging.log(AlbumsPresenter.self, "Retrieved albums, updating view")
                
                self.albums = albums
                self.collectionDataSource = dataSource
                self.delegate?.onMediaAlbumsLoad(dataSource: dataSource, albumTitles: albumTitles)
            }
        }
    }
    
    func onAlbumClick(index: UInt) {
        let album = self.albums[Int(index)]
        
        Logging.log(AlbumsPresenter.self, "Open playlist screen for album '\(album.albumTitle)'")
        
        let tracks = audioInfo.getAlbumTracks(album: album)
        
        var node = AudioPlaylistBuilder.start()
        node.name = album.albumTitle
        node.tracks = tracks
        
        do {
            let playlist = try node.build()
            self.delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist)
        } catch {
            Logging.log(AlbumsPresenter.self, "Error: failed to playlist screen for album '\(album.albumTitle)'")
        }
    }
    
    func onPlaylistItemClick(index: UInt) {
        
    }
    
    func onOpenPlayer(playlist: BaseAudioPlaylist) {
        Logging.log(AlbumsPresenter.self, "Open player screen")
        
        self.delegate?.openPlayerScreen(playlist: playlist)
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        let action = Keybinds.shared.getActionFor(input: input)
        
        Logging.log(AlbumsPresenter.self, "Perform KeyBinds action '\(action.rawValue)' for input '\(input.rawValue)'")
        
        if let error = Keybinds.shared.performAction(action: action)
        {
            delegate?.onPlayerErrorEncountered(error)
        }
    }
    
    func onPlayOrderButtonClick() {
        Logging.log(AlbumsPresenter.self, "Change play order")
        
        if let error = Keybinds.shared.performAction(action: .CHANGE_PLAY_ORDER)
        {
            delegate?.onPlayerErrorEncountered(error)
        }
    }
    
    func onOpenPlaylistButtonClick() {
        guard let playlist = AudioPlayer.shared.playlist else {
            return
        }
        
        Logging.log(AlbumsPresenter.self, "Open playlist screen for playlist '\(playlist.name)'")
        
        delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist)
    }
    
    func onPlayerVolumeSet(value: Double) {
        
    }
    
    func onPlaylistItemDelete(index: UInt) {
        
    }
    
    func onSearchResultClick(index: UInt) {
        
    }
    
    func onSearchQuery(_ query: String) {
        
    }
    
    func onAppSettingsReset() {
        
    }
    
    func onAppThemeChange(_ themeValue: AppThemeValue) {
        
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
