//
//  CreateListView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 2.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

struct CreateListAudioTrack: Equatable
{
    public let identifier: String
    
    public let title: String
    public let albumTitle: String
    public let description: String
    
    init(identifier: String, title: String, albumTitle: String, description: String) {
        self.identifier = identifier
        self.title = title
        self.albumTitle = albumTitle
        self.description = description
    }
    
    public static func createFrom(_ track: BaseAudioTrack) -> CreateListAudioTrack {
        return CreateListAudioTrack(identifier: CreateListAudioTrack.identifier(of: track),
                                    title: track.title,
                                    albumTitle: track.albumTitle,
                                    description: track.duration)
    }
    
    static func ==(lhs: CreateListAudioTrack, rhs: CreateListAudioTrack) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public func equalsToTrack(_ track: BaseAudioTrack) -> Bool {
        return identifier == CreateListAudioTrack.identifier(of: track)
    }
    
    public static func identifier(of track: BaseAudioTrack) -> String {
        return track.filePath.absoluteString
    }
}

class CreateListView : UIView
{
    public static let HORIZONTAL_MARGIN: CGFloat = 8
    public static let HEADER_HEIGHT: CGFloat = 48
    
    private var openedAlbum: CreateListAlbumCell?
    
    private var addedTracksTableDelegate : BaseCreateListViewAddedTracksActionDelegate?
    
    public var addedTracksTableDataSource : BaseCreateListViewAddedTracksTableDataSource? {
        get {
            return addedTracksTable.dataSource as? BaseCreateListViewAddedTracksTableDataSource
        }
        set {
            addedTracksTable.dataSource = newValue
        }
    }
    
    private var albumsTableDelegate : BaseCreateListViewAlbumTracksDelegate?
    
    public var albumsTableDataSource : BaseCreateListViewAlbumsDataSource? {
        get {
            return albumsTable.dataSource as? BaseCreateListViewAlbumsDataSource
        }
        set {
            albumsTable.dataSource = newValue
        }
    }
    
    private var searchTracksTableDelegate : BaseSearchViewActionDelegate? {
        get {
            return searchLayoutView.collectionActionDelegate
        }
        set {
            searchLayoutView.collectionActionDelegate = newValue
        }
    }
    
    public var searchTracksTableDataSource : BaseSearchViewDataSource? {
        get {
            return searchLayoutView.collectionDataSource
        }
        set {
            searchLayoutView.collectionDataSource = newValue
        }
    }
    
    public var onPlaylistNameFieldEditedCallback: (String)->Void = {(text) in }
    public var onCancelButtonClickedCallback: ()->Void = {() in }
    public var onDoneButtonClickedCallback: ()->Void = {() in }
    public var onSwitchTrackPickerCallback: ()->Void = {() in }
    public var onAddedTrackClickedCallback: (UInt)->Void = {(index) in }
    public var onAlbumClickedCallback: (UInt)->Void = {(index) in }
    public var onSearchQueryCallback: (String)->Void {
        get { return searchLayoutView.onSearchFieldTextEnteredCallback }
        set { searchLayoutView.onSearchFieldTextEnteredCallback = newValue }
    }
    public var onSearchItemClickedCallback: (UInt)->Void {
        get { return searchLayoutView.onSearchResultClickedCallback }
        set { searchLayoutView.onSearchResultClickedCallback = newValue }
    }
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var playlistNameField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var addedTracksLabel: UILabel!
    @IBOutlet weak var addedTracksTable: UITableView!
    
    @IBOutlet weak var pickTracksLayout: UIView!
    @IBOutlet weak var tracksSwitch: UISegmentedControl!
    @IBOutlet var albumsTable: UITableView!
    @IBOutlet var searchLayout: UIView!
    var searchLayoutView: SearchViewPlain!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    private func initialize() {
        self.searchLayoutView = SearchViewPlain.create(owner: self)
    }
    
    private func setup() {
        let guide = self.safeAreaLayoutGuide
        let entireContentSize = self.frame
        var top = self.bottomAnchor
        
        // App theme setup
        setupAppTheme()
        
        // Header
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        header.heightAnchor.constraint(equalToConstant: CreateListView.HEADER_HEIGHT).isActive = true
        header.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: CreateListView.HORIZONTAL_MARGIN).isActive = true
        header.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -CreateListView.HORIZONTAL_MARGIN).isActive = true
        
        top = header.bottomAnchor
        
        // Header buttons
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: CreateListView.HORIZONTAL_MARGIN).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        cancelButton.heightAnchor.constraint(equalTo: header.heightAnchor).isActive = true
        cancelButton.addTarget(self, action: #selector(actionCancelButtonClick), for: .touchUpInside)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        doneButton.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -CreateListView.HORIZONTAL_MARGIN).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: 48).isActive = true
        doneButton.heightAnchor.constraint(equalTo: header.heightAnchor).isActive = true
        doneButton.addTarget(self, action: #selector(actionDoneButtonClick), for: .touchUpInside)
        
        // Playlist name text field
        playlistNameField.translatesAutoresizingMaskIntoConstraints = false
        playlistNameField.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        playlistNameField.leftAnchor.constraint(equalTo: cancelButton.rightAnchor).isActive = true
        playlistNameField.rightAnchor.constraint(equalTo: doneButton.leftAnchor).isActive = true
        
        playlistNameField.delegate = self
        playlistNameField.addTarget(self, action: #selector(actionPlaylistNameChanged), for: .editingChanged)
        
        // Switch tracks
        tracksSwitch.translatesAutoresizingMaskIntoConstraints = false
        tracksSwitch.topAnchor.constraint(equalTo: top).isActive = true
        tracksSwitch.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: CreateListView.HORIZONTAL_MARGIN).isActive = true
        tracksSwitch.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -CreateListView.HORIZONTAL_MARGIN).isActive = true
        tracksSwitch.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        tracksSwitch.addTarget(self, action: #selector(switchTracksType), for: .valueChanged)
        
        if tracksSwitch.selectedSegmentIndex == 0 {
            setupSearchTracks()
        } else {
            setupAlbumTracks()
        }
        
        top = tracksSwitch.bottomAnchor
        
        // Pick tracks layout
        pickTracksLayout.translatesAutoresizingMaskIntoConstraints = false
        pickTracksLayout.topAnchor.constraint(equalTo: top).isActive = true
        pickTracksLayout.widthAnchor.constraint(equalTo: guide.widthAnchor).isActive = true
        pickTracksLayout.heightAnchor.constraint(equalToConstant: entireContentSize.height * 0.25).isActive = true
        
        top = pickTracksLayout.bottomAnchor
        
        // Label - added tracks
        addedTracksLabel.translatesAutoresizingMaskIntoConstraints = false
        addedTracksLabel.topAnchor.constraint(equalTo: top, constant: 5).isActive = true
        addedTracksLabel.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: CreateListView.HORIZONTAL_MARGIN).isActive = true
        addedTracksLabel.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -CreateListView.HORIZONTAL_MARGIN).isActive = true
        
        top = addedTracksLabel.bottomAnchor
        
        // Added tracks collection
        addedTracksTable.translatesAutoresizingMaskIntoConstraints = false
        addedTracksTable.topAnchor.constraint(equalTo: top, constant: 5).isActive = true
        addedTracksTable.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        addedTracksTable.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: CreateListView.HORIZONTAL_MARGIN).isActive = true
        addedTracksTable.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -CreateListView.HORIZONTAL_MARGIN).isActive = true
        
        addedTracksTable.separatorStyle = .none
        
        let nib = UINib(nibName: String(describing: CreateListAddedTrackCell.self), bundle: nil)
        addedTracksTable.register(nib, forCellReuseIdentifier: CreateListAddedTrackCell.CELL_IDENTIFIER)
        
        self.addedTracksTableDelegate = CreateListViewAddedTracksActionDelegate(view: self)
        addedTracksTable.delegate = self.addedTracksTableDelegate
    }
    
    public func setupAppTheme() {
        self.backgroundColor = AppTheme.shared.colorFor(.STANDART_BACKGROUND)
        
        addedTracksTable.backgroundColor = .clear
        albumsTable.backgroundColor = .clear
        addedTracksLabel.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
        
        cancelButton.tintColor = AppTheme.shared.colorFor(.STANDART_BUTTON)
        doneButton.tintColor = AppTheme.shared.colorFor(.STANDART_BUTTON)
        
        addedTracksTable.indicatorStyle = AppTheme.shared.scrollBarColor()
        albumsTable.indicatorStyle = AppTheme.shared.scrollBarColor()
    }
    
    public func reloadAddedTracksData() {
        addedTracksTable.reloadData()
    }
    
    public func reloadAlbumsData() {
        self.albumsTableDataSource?.closeAlbum()
        
        albumsTable.reloadData()
    }
    
    public func reloadSearchTracksData() {
        searchLayoutView.reloadData()
    }
    
    public func showLoadingIndicator(_ value: Bool) {
        if value {
            searchLayoutView.showLoadingIndicator()
        } else {
            searchLayoutView.hideLoadingIndicator()
        }
    }
    
    public func openAlbumAt(index: UInt,
                            albumTracks: [CreateListAudioTrack],
                            addedTracks: [CreateListAudioTrack]) {
        self.albumsTableDataSource?.openAlbum(index: index, albumTracks: albumTracks, addedTracks: addedTracks)
        self.albumsTableDelegate?.selectAlbum(index: index, albumTracks: albumTracks)
        
        albumsTable.reloadRows(at: [IndexPath(row: Int(index), section: 0)], with: .automatic)
    }
    
    public func deselectTrackFromOpenedAlbum(_ albumTrack: CreateListAudioTrack) {
        self.albumsTableDataSource?.deselectAlbumTrack(albumTrack)
    }
    
    public func isAlbumTracksShown() -> Bool {
        return self.albumsTable.superview != nil
    }
    
    public func showAlbumTracks() {
        if isAlbumTracksShown() {
            return
        }
        
        self.searchLayout.removeFromSuperview()
        
        setupAlbumTracks()
    }
    
    private func setupAlbumTracks() {
        pickTracksLayout.addSubview(self.albumsTable)
        
        let top = self.tracksSwitch.bottomAnchor
        
        // Albums table
        albumsTable.translatesAutoresizingMaskIntoConstraints = false
        albumsTable.topAnchor.constraint(equalTo: top, constant: 5).isActive = true
        albumsTable.heightAnchor.constraint(equalTo: pickTracksLayout.heightAnchor).isActive = true
        albumsTable.widthAnchor.constraint(equalTo: pickTracksLayout.widthAnchor).isActive = true
        
        let nib = UINib(nibName: String(describing: CreateListAlbumCell.self), bundle: nil)
        albumsTable.register(nib, forCellReuseIdentifier: CreateListAlbumCell.CELL_IDENTIFIER)
        
        self.albumsTableDelegate = CreateListViewAlbumTracksDelegate(view: self)
        albumsTable.delegate = self.albumsTableDelegate
    }
    
    public func showSearchTracks() {
        if !isAlbumTracksShown() {
            return
        }
        
        self.albumsTable.removeFromSuperview()
        
        setupSearchTracks()
    }
    
    private func setupSearchTracks() {
        pickTracksLayout.addSubview(self.searchLayout)
        
        var top = self.tracksSwitch.bottomAnchor
        
        // Search layout
        searchLayout.translatesAutoresizingMaskIntoConstraints = false
        searchLayout.topAnchor.constraint(equalTo: top, constant: 5).isActive = true
        searchLayout.heightAnchor.constraint(equalTo: pickTracksLayout.heightAnchor).isActive = true
        searchLayout.widthAnchor.constraint(equalTo: pickTracksLayout.widthAnchor).isActive = true
        
        top = searchLayout.topAnchor
        
        // Search plain view
        if self.searchLayoutView.superview == nil {
            searchLayout.addSubview(self.searchLayoutView)
        }
        
        // Filters are not displayed
        searchLayoutView.hideFiltersView()
    }
}

// Actions
extension CreateListView {
    @objc func actionCancelButtonClick() {
        self.onCancelButtonClickedCallback()
    }
    
    @objc func actionDoneButtonClick() {
        self.onDoneButtonClickedCallback()
    }
    
    @objc func actionAddedTrackClick(index: UInt) {
        self.onAddedTrackClickedCallback(index)
    }
    
    @objc func actionAlbumClick(index: UInt) {
        self.onAlbumClickedCallback(index)
    }
    
    @objc func actionPlaylistNameChanged() {
        self.onPlaylistNameFieldEditedCallback(self.playlistNameField.text ?? "")
    }
    
    @objc func actionSearchTrackClick(index: UInt) {
        self.onSearchItemClickedCallback(index)
    }
    
    @objc func switchTracksType() {
        if isAlbumTracksShown() {
            showSearchTracks()
        } else {
            showAlbumTracks()
        }
        
        self.onSwitchTrackPickerCallback()
    }
}

// Text field actions
extension CreateListView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let text = textField.text ?? ""
        
        if textField == self.playlistNameField {
            self.onPlaylistNameFieldEditedCallback(text)
        } else {
            self.onSearchQueryCallback(text)
        }
        
        return true
    }
}

// Builder
extension CreateListView {
    class func create(owner: Any) -> CreateListView? {
        let bundle = Bundle.main
        let nibName = String(describing: CreateListView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? CreateListView
    }
}
