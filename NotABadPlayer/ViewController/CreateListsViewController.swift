//
//  CreateListsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 2.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class CreateListsViewController: UIViewController {
    private var baseView: CreateListView?
    
    private let audioInfo: AudioInfo?
    private var audioInfoAlbums: [AudioAlbum] = []
    private var addedTracks: [AudioTrack] = []
    
    private var addedTracksDataSource: CreateListViewAddedTracksDataSource?
    private var albumsDataSource: CreateListViewAlbumsDataSource?
    
    init(audioInfo: AudioInfo) {
        self.audioInfo = audioInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.audioInfo = nil
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.baseView = CreateListView.create(owner: self)
        self.view = self.baseView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        baseView?.onCancelButtonClickedCallback = {[weak self] () in
            self?.goBack()
        }
        
        baseView?.onDoneButtonClickedCallback = {[weak self] () in
            self?.goBack()
        }
        
        baseView?.onAddedTrackClickedCallback = {[weak self] (index) in
            self?.removeTrackAt(index)
        }
        
        baseView?.onAlbumClickedCallback = {[weak self] (index) in
            self?.openAlbumAt(index)
        }
        
        updateAlbumsView()
    }
    
    private func goBack() {
        NavigationHelpers.dismissPresentedVC(self)
    }
    
    private func removeTrackAt(_ index: UInt)
    {
        guard index < addedTracks.count else {
            return
        }
        
        addedTracks.remove(at: Int(index))
        
        updateAddedTracksView()
    }
    
    private func openAlbumAt(_ index: UInt)
    {
        guard let audioInfo = self.audioInfo else {
            return
        }
        
        let selectedAlbum = audioInfoAlbums[Int(index)]
        
        baseView?.openAlbumAt(index: index, albumTracks: audioInfo.getAlbumTracks(album: selectedAlbum))
    }
    
    private func addTrackFromOpenedAlbum(index: UInt)
    {
        NSLog("adding track at \(index)")
    }
    
    func updateAddedTracksView() {
        guard let audioInfo = self.audioInfo else {
            return
        }
        
        self.addedTracksDataSource = CreateListViewAddedTracksDataSource(audioInfo: audioInfo, tracks: addedTracks)
        
        baseView?.addedTracksCollectionDataSource = self.addedTracksDataSource
        
        baseView?.reloadData()
    }
    
    func updateAlbumsView() {
        guard let audioInfo = self.audioInfo else {
            return
        }
        
        let onTrackClickedCallback = {[weak self] (index: UInt) -> Void in
            self?.addTrackFromOpenedAlbum(index: index)
        }
        
        self.audioInfoAlbums = audioInfo.getAlbums()
        
        self.albumsDataSource = CreateListViewAlbumsDataSource(albums: self.audioInfoAlbums,
                                                               onTrackClickedCallback: onTrackClickedCallback)
        
        baseView?.albumsCollectionDataSource = self.albumsDataSource
        
        baseView?.reloadData()
    }
}
