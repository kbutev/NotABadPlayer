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
    public static let SIZE = CGSize(width: 0, height: 48)
    public static let SELECTED_SIZE = CGSize(width: 0, height: 248)
    public static let COVER_IMAGE_SIZE = CGSize(width: 48, height: 48)
    public static let HEADER_HEIGHT: CGFloat = 64
    
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var tracksTable: UITableView!
    
    public var onOpenedAlbumTrackSelectionCallback: (UInt)->Void = {(index) in }
    public var onOpenedAlbumTrackDeselectionCallback: (UInt)->Void = {(index) in }
    
    private var delegate : CreateListAlbumCellDelegate?
    
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
        
        // App theme setup
        setupAppTheme()
        
        // Cover image setup
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        coverImage.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        coverImage.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        coverImage.widthAnchor.constraint(equalToConstant: 48).isActive = true
        coverImage.heightAnchor.constraint(lessThanOrEqualToConstant: 48).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: coverImage.centerYAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: coverImage.rightAnchor, constant: 10).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        
        tracksTable.isHidden = true
        tracksTable.translatesAutoresizingMaskIntoConstraints = false
        tracksTable.topAnchor.constraint(equalTo: coverImage.bottomAnchor).isActive = true
        tracksTable.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        tracksTable.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        tracksTable.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        tracksTable.separatorStyle = .none
        
        let nib = UINib(nibName: String(describing: CreateListAlbumTrackCell.self), bundle: nil)
        tracksTable.register(nib, forCellReuseIdentifier: CreateListAlbumTrackCell.CELL_IDENTIFIER)
        
        self.delegate = CreateListAlbumCellDelegate(view: self)
        tracksTable.delegate = self.delegate
    }
    
    public func setupAppTheme() {
        self.backgroundColor = .clear
        content.backgroundColor = .clear
        tracksTable.backgroundColor = .clear
        titleLabel.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
    }
    
    public func selectAlbumTrack(at index: UInt) {
        tracksTable.selectRow(at: IndexPath(row: Int(index), section: 0), animated: false, scrollPosition: .none)
    }
    
    public func deselectAlbumTrack(at index: UInt) {
        tracksTable.deselectRow(at: IndexPath(row: Int(index), section: 0), animated: false)
    }
}

// Actions
extension CreateListAlbumCell {
    @objc func actionOnTrackSelection(_ index: UInt) {
        self.onOpenedAlbumTrackSelectionCallback(index)
    }
    
    @objc func actionOnTrackDeselection(_ index: UInt) {
        self.onOpenedAlbumTrackDeselectionCallback(index)
    }
}
