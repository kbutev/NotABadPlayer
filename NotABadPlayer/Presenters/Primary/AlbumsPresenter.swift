//
//  AlbumsPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 30.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class AlbumsPresenter: BasePresenter
{
    public weak var delegate: AlbumsViewDelegate?
    
    private let audioInfo: AudioInfo
    private var albums: [AudioAlbum] = []
    
    private var collectionDataSource: AlbumsViewDataSource?
    private var collectionActionDelegate: AlbumsViewActionDelegate?
    
    required init(view: AlbumsViewDelegate?=nil, audioInfo: AudioInfo) {
        self.delegate = view
        self.audioInfo = audioInfo
    }
    
    func start() {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: AlbumsPresenter.self))")
        }
        
        self.albums = audioInfo.getAlbums()
        
        let dataSource = AlbumsViewDataSource(audioInfo: audioInfo, albums: albums)
        self.collectionDataSource = dataSource
        
        let actionDelegate = AlbumsViewActionDelegate(view: delegate)
        self.collectionActionDelegate = actionDelegate
        
        var albumTitles: [String] = []
        
        for album in self.albums
        {
            albumTitles.append(album.albumTitle)
        }
        
        delegate.onMediaAlbumsLoad(dataSource: dataSource, actionDelegate: actionDelegate, albumTitles: albumTitles)
    }
    
    func onAlbumClick(index: UInt) {
        let item = self.albums[Int(index)]
        
        Logging.log(AlbumsPresenter.self, "Open playlist screen for album '\(item.albumTitle)'")
        
        self.delegate?.openPlaylistScreen(audioInfo: audioInfo, album: item)
    }
    
    func onPlaylistItemClick(index: UInt) {
        
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
        
        // Album playlist? Open album from here
        if playlist.isAlbumPlaylist()
        {
            for e in 0..<albums.count
            {
                let album = albums[e]
                
                if album.albumTitle == playlist.name
                {
                    self.onAlbumClick(index: UInt(e))
                    return
                }
            }
        }
    }
    
    func onSearchResultClick(index: UInt) {
        
    }
    
    func onSearchQuery(searchValue: String) {
        
    }
    
    func onAppSettingsReset() {
        
    }
    
    func onAppThemeChange(themeValue: AppTheme) {
        
    }
    
    func onAppSortingChange(albumSorting: AlbumSorting, trackSorting: TrackSorting) {
        
    }
    
    func onAppAppearanceChange(showStars: ShowStars, showVolumeBar: ShowVolumeBar) {
        
    }
    
    func onKeybindChange(action: ApplicationAction, input: ApplicationInput) {
        
    }
}
