//
//  ListsView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 29.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class ListsView : UIView
{
    static let HORIZONTAL_MARGIN: CGFloat = 8
    static let HEADER_HEIGHT: CGFloat = 48
    static let FAVORITES_IMAGE: String = "shiny_star_small"
    
    private var initialized: Bool = false
    
    public var tableActionDelegate : BaseListsViewDelegate?
    
    private var tableDataSourceReal : BaseListsViewDataSource?
    
    public var tableDataSource : BaseListsViewDataSource? {
        get {
            return self.tableDataSourceReal
        }
        set {
            self.tableDataSourceReal = newValue
        }
    }
    
    public var onCreateButtonClickedCallback: ()->Void = {() in }
    public var onEditButtonClickedCallback: ()->Void = {() in }
    public var onPlaylistClickedCallback: (UInt)->Void = {(index) in }
    public var onPlaylistEditClickedCallback: (UInt)->Void = {(index) in }
    public var onPlaylistDeleteCallback: (UInt)->Void = {(index) in }
    public var canDeletePlaylistCondition: (UInt)->Bool = {(index) in true }
    
    public var onQuickPlayerPlaylistButtonClickCallback: ()->Void {
        get { return quickPlayerView.onPlaylistButtonClickCallback }
        set { quickPlayerView.onPlaylistButtonClickCallback = newValue }
    }
    
    public var onQuickPlayerButtonClickCallback: (ApplicationInput)->() {
        get { return quickPlayerView.onPlayerButtonClickCallback }
        set { quickPlayerView.onPlayerButtonClickCallback = newValue }
    }
    
    public var onQuickPlayerPlayOrderButtonClickCallback: ()->Void {
        get { return quickPlayerView.onPlayOrderButtonClickCallback }
        set { quickPlayerView.onPlayOrderButtonClickCallback = newValue }
    }
    
    public var onQuickPlayerSwipeUpCallback: ()->Void {
        get { return quickPlayerView.onSwipeUpCallback }
        set { quickPlayerView.onSwipeUpCallback = newValue }
    }
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var playlistsTable: UITableView!
    var quickPlayerView: QuickPlayerView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        self.quickPlayerView = QuickPlayerView.createAndAttach(to: self)
        self.tableActionDelegate = ListsViewDelegate(view: self)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if !initialized
        {
            initialized = true
            setup()
        }
    }
    
    private func setup() {
        let guide = self
        
        // App theme setup
        setupAppTheme()
        
        // Header setup
        header.translatesAutoresizingMaskIntoConstraints = false
        header.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: ListsView.HORIZONTAL_MARGIN).isActive = true
        header.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -ListsView.HORIZONTAL_MARGIN).isActive = true
        header.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        header.heightAnchor.constraint(equalToConstant: ListsView.HEADER_HEIGHT).isActive = true
        
        // Buttons setup
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        createButton.leftAnchor.constraint(equalTo: header.leftAnchor).isActive = true
        createButton.heightAnchor.constraint(equalToConstant: ListsView.HEADER_HEIGHT).isActive = true
        
        createButton.addTarget(self, action: #selector(actionCreateButtonClick), for: .touchUpInside)
        
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        editButton.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        editButton.heightAnchor.constraint(equalToConstant: ListsView.HEADER_HEIGHT).isActive = true
        
        editButton.addTarget(self, action: #selector(actionDeleteButtonClick), for: .touchUpInside)
        
        // Table setup
        playlistsTable.translatesAutoresizingMaskIntoConstraints = false
        playlistsTable.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: ListsView.HORIZONTAL_MARGIN).isActive = true
        playlistsTable.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -ListsView.HORIZONTAL_MARGIN).isActive = true
        playlistsTable.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 2).isActive = true
        playlistsTable.bottomAnchor.constraint(equalTo: quickPlayerView.topAnchor).isActive = true
        
        playlistsTable.separatorStyle = .none
        
        let nib = UINib(nibName: String(describing: ListsItemCell.self), bundle: nil)
        playlistsTable.register(nib, forCellReuseIdentifier: ListsItemCell.CELL_IDENTIFIER)
        
        playlistsTable.delegate = tableActionDelegate
        playlistsTable.dataSource = self
        playlistsTable.allowsSelectionDuringEditing = true
    }
    
    public func setupAppTheme() {
        self.backgroundColor = AppTheme.shared.colorFor(.STANDART_BACKGROUND)
        
        header.backgroundColor = .clear
        playlistsTable.backgroundColor = .clear
        
        createButton.tintColor = AppTheme.shared.colorFor(.STANDART_BUTTON)
        editButton.tintColor = AppTheme.shared.colorFor(.STANDART_BUTTON)
        
        playlistsTable.indicatorStyle = AppTheme.shared.scrollBarColor()
    }
    
    public func reloadData() {
        playlistsTable.reloadData()
    }
    
    public func startEditingLists() {
        if !playlistsTable.isEditing
        {
            playlistsTable.setEditing(true, animated: true)
            
            editButton.setTitle(Text.value(.ListsDoneButtonName), for: .normal)
        }
    }
    
    public func endEditingLists() {
        if playlistsTable.isEditing
        {
            playlistsTable.setEditing(false, animated: true)
            
            editButton.setTitle(Text.value(.ListsEditButtonName), for: .normal)
        }
    }
}

// QuickPlayerObserver
extension ListsView: QuickPlayerObserver {
    public func updateTime(currentTime: Double, totalDuration: Double) {
        quickPlayerView.updateTime(currentTime: currentTime, totalDuration: totalDuration)
    }
    
    public func updateMediaInfo(track: BaseAudioTrack) {
        quickPlayerView.updateMediaInfo(track: track)
    }
    
    public func updatePlayButtonState(isPlaying: Bool) {
        quickPlayerView.updatePlayButtonState(isPlaying: isPlaying)
    }
    
    public func updatePlayOrderButtonState(order: AudioPlayOrder) {
        quickPlayerView.updatePlayOrderButtonState(order: order)
    }
    
    func onVolumeChanged(volume: Double) {
        
    }
}

// ListsView: Implement the data source
// Forward nearly all requests to the actual, real data source - ListsViewDataSource
// When receiving a delete event, perform a callback
extension ListsView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataSource = tableDataSourceReal
        {
            return dataSource.tableView(tableView, numberOfRowsInSection: section)
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let dataSource = tableDataSourceReal
        {
            return dataSource.tableView(tableView, cellForRowAt: indexPath)
        }
        
        return tableView.dequeueReusableCell(withIdentifier: ListsItemCell.CELL_IDENTIFIER, for: indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.onPlaylistDeleteCallback(UInt(indexPath.row))
    }
}

// Actions
extension ListsView {
    @objc func actionCreateButtonClick() {
        self.onCreateButtonClickedCallback()
    }
    
    @objc func actionDeleteButtonClick() {
        self.onEditButtonClickedCallback()
    }
    
    @objc func actionPlaylistClick(index: UInt) {
        self.onPlaylistClickedCallback(index)
    }
    
    @objc func actionPlaylistEditClick(index: UInt) {
        self.onPlaylistEditClickedCallback(index)
    }
}

// Builder
extension ListsView {
    class func create(owner: Any) -> ListsView? {
        let bundle = Bundle.main
        let nibName = String(describing: ListsView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? ListsView
    }
}

// Table data source
class ListsViewDataSource : NSObject, BaseListsViewDataSource
{
    let audioInfo: AudioInfo
    var playlists: [BaseAudioPlaylist]
    
    public var count: Int {
        get {
            return playlists.count
        }
    }
    
    init(audioInfo: AudioInfo, playlists: [BaseAudioPlaylist]) {
        self.audioInfo = audioInfo
        self.playlists = playlists
    }
    
    func data(at index: UInt) -> BaseAudioPlaylist {
        return playlists[Int(index)]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: ListsItemCell.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? ListsItemCell else {
            return reusableCell
        }
        
        let item = playlists[indexPath.row]
        let firstTrack = item.firstTrack
        
        // Temporary playlists may have a "fixed" image cover, try to use that
        if let fixedArtCover = fixedArtCover(for: item) {
            cell.artCoverImage.image = fixedArtCover
            cell.artCoverImage.contentMode = .center
        } else {
            cell.artCoverImage.image = firstTrack.albumCoverImage
            cell.artCoverImage.contentMode = .scaleToFill
        }
        
        cell.titleLabel.text = item.name
        cell.descriptionLabel.text = getPlaylistDescription(playlist: item)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func getPlaylistDescription(playlist: BaseAudioPlaylist) -> String {
        return Text.value(.PlaylistCellDescription, "\(playlist.tracks.count)")
    }
    
    func fixedArtCover(for playlist: BaseAudioPlaylist) -> UIImage? {
        if !playlist.isTemporary {
            return nil
        }
        
        // Favorites playlist has a specific image cover
        let favoritesName = Text.value(.PlaylistFavorites)
        
        if playlist.name == favoritesName {
            return UIImage(named: ListsView.FAVORITES_IMAGE)
        }
        
        return nil
    }
}

// Table delegate
class ListsViewDelegate : NSObject, BaseListsViewDelegate
{
    private weak var view: ListsView?
    
    init(view: ListsView) {
        self.view = view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = UInt(indexPath.row)
        
        if !tableView.isEditing {
            self.view?.actionPlaylistClick(index: index)
        } else {
            self.view?.actionPlaylistEditClick(index: index)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ListsItemCell.HEIGHT
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            // Show delete symbol only for those for which the callback returns true
            if view?.canDeletePlaylistCondition(UInt(indexPath.row)) ?? false
            {
                return .delete
            }
        }
        
        return .none
    }
}
