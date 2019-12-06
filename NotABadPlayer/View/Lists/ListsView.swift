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
    
    private var initialized: Bool = false
    
    private var tableActionDelegate : ListsViewDelegate?
    
    private var tableDataSourceReal : ListsViewDataSource?
    
    public var tableDataSource : ListsViewDataSource? {
        get {
            return self.tableDataSourceReal
        }
        set {
            self.tableDataSourceReal = newValue
        }
    }
    
    public var onCreateButtonClickedCallback: ()->Void = {() in }
    public var onDeleteButtonClickedCallback: ()->Void = {() in }
    public var onPlaylistClickedCallback: (UInt)->Void = {(index) in }
    public var onDidDeletePlaylistCallback: (UInt)->Void = {(index) in }
    
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
    @IBOutlet weak var deleteButton: UIButton!
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
        quickPlayerView = QuickPlayerView.create(owner: self)
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
        
        // Quick player setup
        addSubview(quickPlayerView)
        quickPlayerView.translatesAutoresizingMaskIntoConstraints = false
        quickPlayerView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 0).isActive = true
        quickPlayerView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        quickPlayerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        quickPlayerView.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.2).isActive = true
        
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
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: ListsView.HEADER_HEIGHT).isActive = true
        
        deleteButton.addTarget(self, action: #selector(actionDeleteButtonClick), for: .touchUpInside)
        
        // Table setup
        playlistsTable.translatesAutoresizingMaskIntoConstraints = false
        playlistsTable.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: ListsView.HORIZONTAL_MARGIN).isActive = true
        playlistsTable.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -ListsView.HORIZONTAL_MARGIN).isActive = true
        playlistsTable.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 2).isActive = true
        playlistsTable.bottomAnchor.constraint(equalTo: quickPlayerView.topAnchor).isActive = true
        
        playlistsTable.separatorStyle = .none
        
        let nib = UINib(nibName: String(describing: ListsItemCell.self), bundle: nil)
        playlistsTable.register(nib, forCellReuseIdentifier: ListsItemCell.CELL_IDENTIFIER)
        
        self.tableActionDelegate = ListsViewDelegate(view: self)
        playlistsTable.delegate = tableActionDelegate
        
        playlistsTable.dataSource = self
    }
    
    public func setupAppTheme() {
        self.backgroundColor = AppTheme.shared.colorFor(.STANDART_BACKGROUND)
        
        header.backgroundColor = .clear
        playlistsTable.backgroundColor = .clear
        
        createButton.tintColor = AppTheme.shared.colorFor(.STANDART_BUTTON)
        deleteButton.tintColor = AppTheme.shared.colorFor(.STANDART_BUTTON)
        
        playlistsTable.indicatorStyle = AppTheme.shared.scrollBarColor()
    }
    
    public func reloadData() {
        playlistsTable.reloadData()
    }
    
    public func updateTime(currentTime: Double, totalDuration: Double) {
        quickPlayerView.updateTime(currentTime: currentTime, totalDuration: totalDuration)
    }
    
    public func updateMediaInfo(track: AudioTrack) {
        quickPlayerView.updateMediaInfo(track: track)
    }
    
    public func updatePlayButtonState(playing: Bool) {
        quickPlayerView.updatePlayButtonState(playing: playing)
    }
    
    public func updatePlayOrderButtonState(order: AudioPlayOrder) {
        quickPlayerView.updatePlayOrderButtonState(order: order)
    }
    
    public func startDeletingLists() {
        if !playlistsTable.isEditing
        {
            playlistsTable.setEditing(true, animated: true)
            
            deleteButton.setTitle(Text.value(.ListsDoneButtonName), for: .normal)
        }
    }
    
    public func endDeletingLists() {
        if playlistsTable.isEditing
        {
            playlistsTable.setEditing(false, animated: true)
            
            deleteButton.setTitle(Text.value(.ListsDeleteButtonName), for: .normal)
        }
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
        self.onDidDeletePlaylistCallback(UInt(indexPath.row))
    }
}

// Actions
extension ListsView {
    @objc func actionCreateButtonClick() {
        self.onCreateButtonClickedCallback()
    }
    
    @objc func actionDeleteButtonClick() {
        self.onDeleteButtonClickedCallback()
    }
    
    @objc func actionPlaylistClick(index: UInt) {
        self.onPlaylistClickedCallback(index)
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
class ListsViewDataSource : NSObject, UITableViewDataSource
{
    let audioInfo: AudioInfo
    var playlists: [BaseAudioPlaylist]
    
    init(audioInfo: AudioInfo, playlists: [BaseAudioPlaylist]) {
        self.audioInfo = audioInfo
        self.playlists = playlists
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
        
        cell.artCoverImage.image = firstTrack.albumCoverImage
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
}

// Table delegate
class ListsViewDelegate : NSObject, UITableViewDelegate
{
    private weak var view: ListsView?
    
    init(view: ListsView) {
        self.view = view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view?.actionPlaylistClick(index: UInt(indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ListsItemCell.HEIGHT
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        
        return .none
    }
}
