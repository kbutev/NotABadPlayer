//
//  PlaylistPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class PlaylistPresenter: BasePresenter
{
    public weak var delegate: PlaylistViewDelegate?
    
    private let audioInfo: AudioInfo
    private let playlist: AudioPlaylist
    
    private var collectionDataSource: PlaylistViewDataSource?
    private var collectionActionDelegate: PlaylistViewActionDelegate?
    
    required init(view: PlaylistViewDelegate?=nil, audioInfo: AudioInfo, playlist: AudioPlaylist) {
        self.delegate = view
        self.audioInfo = audioInfo
        self.playlist = playlist
    }
    
    func start() {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: PlaylistPresenter.self))")
        }
        
        let dataSource = PlaylistViewDataSource(audioInfo: audioInfo, playlist: playlist)
        self.collectionDataSource = dataSource
        
        let actionDelegate = PlaylistViewActionDelegate(view: delegate)
        self.collectionActionDelegate = actionDelegate
        
        let audioPlayer = AudioPlayer.shared
        var scrollToIndex: UInt? = nil
        
        if let playlist = audioPlayer.playlist
        {
            for e in 0..<playlist.tracks.count
            {
                if playlist.tracks[e] == playlist.playingTrack && self.playlist.name == playlist.name
                {
                    scrollToIndex = UInt(e)
                    break
                }
            }
        }
        
        delegate.onAlbumSongsLoad(dataSource: dataSource, actionDelegate: actionDelegate, scrollToIndex: scrollToIndex)
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func onPlaylistItemClick(index: UInt) {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: PlaylistPresenter.self))")
        }
        
        let playlistName = playlist.name
        
        let clickedTrack = playlist.tracks[Int(index)]
        
        let newPlaylist = AudioPlaylist(name: playlistName, tracks: playlist.tracks, startWithTrack: clickedTrack)
        
        delegate.openPlayerScreen(playlist: newPlaylist)
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        let action = Keybinds.shared.getActionFor(input: input)
        
        Logging.log(PlaylistPresenter.self, "Perform KeyBinds action '\(action.rawValue)' for input '\(input.rawValue)'")
        
        let _ = Keybinds.shared.performAction(action: action)
    }
    
    func onPlayOrderButtonClick() {
        Logging.log(PlaylistPresenter.self, "Action - change play order")
        
        let _ = Keybinds.shared.performAction(action: .CHANGE_PLAY_ORDER)
    }
    
    func onOpenPlaylistButtonClick() {
        
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
