//
//  AlbumsPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 30.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol AlbumsPresenterProtocol: BasePresenter {
    var delegate: AlbumsViewControllerProtocol? { get }
    
    func fetchData()
    
    func onAlbumClick(index: UInt)
    
    func onOpenPlayer(playlist: AudioPlaylistProtocol)
    
    func onPlayerButtonClick(input: ApplicationInput)
    func onPlayOrderButtonClick()
    
    func onQuickOpenPlaylistButtonClick()
}

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

class AlbumsPresenter: AlbumsPresenterProtocol {
    weak var delegate: AlbumsViewControllerProtocol?
    
    private let audioInfo: AudioInfo
    private var albums: [AudioAlbum] = []
    
    private var collectionDataSource: AlbumsViewDataSource?
    
    private var fetchOnlyOnce: Counter = Counter(identifier: String(describing: AlbumsPresenter.self))
    
    required init(audioInfo: AudioInfo) {
        self.audioInfo = audioInfo
    }
    
    deinit {
         self.audioInfo.unregisterLibraryChangesListener(self)
    }
    
    // AlbumsPresenterProtocol
    
    func start() {
        guard self.delegate != nil else {
            fatalError("Delegate is not set for \(String(describing: AlbumsPresenter.self))")
        }
        
        self.audioInfo.registerLibraryChangesListener(self)
        
        fetchData()
    }
    
    func fetchData() {
        // Prevent simultaneous fetch actions
        if !fetchOnlyOnce.isZero() {
            return
        }
        
        let _ = fetchOnlyOnce.increment()
        
        Logging.log(AlbumsPresenter.self, "Retrieving albums...")
        
        // Perform work on background thread
        DispatchQueue.global().async {
            let audioInfo = self.audioInfo
            
            let albums = audioInfo.getAlbums()
            
            let dataSource = CollectionAlbumsViewDataSource(audioInfo: audioInfo, albums: albums)
            
            var albumTitles: [String] = []
            
            for album in albums
            {
                albumTitles.append(album.albumTitle)
            }
            
            // Then, update on main thread
            DispatchQueue.main.async {
                Logging.log(AlbumsPresenter.self, "Retrieved \(albums.count) albums, updating view")
                
                self.albums = albums
                self.collectionDataSource = dataSource
                self.delegate?.onMediaAlbumsLoad(dataSource: dataSource, albumTitles: albumTitles)
                
                let _ = self.fetchOnlyOnce.decrement()
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
            self.delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist, options: OpenPlaylistOptions.buildDefault())
        } catch {
            Logging.log(AlbumsPresenter.self, "Error: failed to playlist screen for album '\(album.albumTitle)'")
        }
    }
    
    func onOpenPlayer(playlist: AudioPlaylistProtocol) {
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
    
    func onQuickOpenPlaylistButtonClick() {
        guard let playlist = AudioPlayerService.shared.playlist else {
            return
        }
        
        Logging.log(AlbumsPresenter.self, "Open playlist screen for playlist '\(playlist.name)'")
        
        delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist, options: OpenPlaylistOptions.buildDefault())
    }
}

// # AudioLibraryChangesListener
extension AlbumsPresenter: AudioLibraryChangesListener {
    func onMediaLibraryChanged() {
        Logging.log(AlbumsPresenter.self, "Audio library changed in the background")
        
        DispatchQueue.main.async {
            self.delegate?.onAudioLibraryChanged()
        }
        
        fetchData()
    }
}
