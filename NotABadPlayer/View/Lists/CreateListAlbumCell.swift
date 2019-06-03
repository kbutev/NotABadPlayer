//
//  CreateListAlbumCell.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 3.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class CreateListAlbumCell: UITableViewCell
{
    public static let CELL_IDENTIFIER = "cell"
    public static let HEADER_HEIGHT: CGFloat = 64
    
    @IBOutlet var content: UIView!
    @IBOutlet var coverImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet weak var tracksTable: UITableView!
    
    public var onTrackClickedCallback: (UInt)->Void = {(index) in }
    
    private var delegate : CreateListAlbumCellActionDelegate?
    
    public var dataSource : CreateListAlbumCellDataSource? {
        get {
            return tracksTable.dataSource as? CreateListAlbumCellDataSource
        }
        set {
            tracksTable.dataSource = newValue
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    private func setup() {
        let guide = content!
        
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        coverImage.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        coverImage.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        coverImage.widthAnchor.constraint(equalToConstant: 48).isActive = true
        coverImage.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: coverImage.rightAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        
        tracksTable.isHidden = true
        tracksTable.translatesAutoresizingMaskIntoConstraints = false
        tracksTable.topAnchor.constraint(equalTo: coverImage.bottomAnchor).isActive = true
        tracksTable.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        tracksTable.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        tracksTable.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        tracksTable.tableFooterView = UIView()
        
        let nib = UINib(nibName: String(describing: CreateListAlbumTrackCell.self), bundle: nil)
        tracksTable.register(nib, forCellReuseIdentifier: CreateListAlbumCell.CELL_IDENTIFIER)
        
        self.delegate = CreateListAlbumCellActionDelegate(view: self)
        tracksTable.delegate = self.delegate
    }
}

// Actions
extension CreateListAlbumCell {
    @objc func actionOnTrackClick(index: UInt) {
        self.onTrackClickedCallback(index)
    }
}

// Table data source
class CreateListAlbumCellDataSource : NSObject, UITableViewDataSource
{
    let tracks: [AudioTrack]
    
    init(tracks: [AudioTrack]) {
        self.tracks = tracks
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: CreateListAlbumCell.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? CreateListAlbumTrackCell else {
            return reusableCell
        }
        
        let item = tracks[indexPath.row]
        
        cell.titleLabel.text = item.title
        cell.descriptionLabel.text = getTrackDescription(track: item)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CreateListAlbumTrackCell.HEIGHT
    }
    
    func getTrackDescription(track: AudioTrack) -> String {
        return track.duration
    }
}

// Table action delegate
class CreateListAlbumCellActionDelegate : NSObject, UITableViewDelegate
{
    private weak var view: CreateListAlbumCell?
    
    private var selectedAlbum: Int = -1
    
    init(view: CreateListAlbumCell) {
        self.view = view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view?.actionOnTrackClick(index: UInt(indexPath.row))
    }
}

