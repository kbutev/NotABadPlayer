//
//  CreateListsView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 2.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class CreateListsView : UICollectionViewCell
{
    static let CELL_IDENTIFIER = "cell"
    static let HORIZONTAL_MARGIN: CGFloat = 8
    static let HEADER_HEIGHT: CGFloat = 48
    static let BUTTON_WIDTH: CGFloat = 64
    
    public var onCancelButtonClickedCallback: ()->() = {() in }
    public var onDoneButtonClickedCallback: ()->() = {() in }
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var playlistNameField: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var addedTracksCollection: UICollectionView!
    @IBOutlet weak var tracksCollection: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    private func setup() {
        let guide = self.safeAreaLayoutGuide
        
        // Header
        header.translatesAutoresizingMaskIntoConstraints = false
        header.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: CreateListsView.HORIZONTAL_MARGIN).isActive = true
        header.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -CreateListsView.HORIZONTAL_MARGIN).isActive = true
        header.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        header.heightAnchor.constraint(equalToConstant: CreateListsView.HEADER_HEIGHT).isActive = true
        
        // Header buttons
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: header.leftAnchor).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: CreateListsView.BUTTON_WIDTH).isActive = true
        cancelButton.heightAnchor.constraint(equalTo: header.heightAnchor).isActive = true
        
        cancelButton.addTarget(self, action: #selector(actionCancelButtonClick), for: .touchUpInside)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        doneButton.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        doneButton.widthAnchor.constraint(equalToConstant: CreateListsView.BUTTON_WIDTH).isActive = true
        doneButton.heightAnchor.constraint(equalTo: header.heightAnchor).isActive = true
        
        doneButton.addTarget(self, action: #selector(actionDoneButtonClick), for: .touchUpInside)
        
        // Playlist name text field
        playlistNameField.translatesAutoresizingMaskIntoConstraints = false
        playlistNameField.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        playlistNameField.heightAnchor.constraint(equalTo: header.heightAnchor).isActive = true
        playlistNameField.leftAnchor.constraint(equalTo: cancelButton.rightAnchor).isActive = true
        playlistNameField.rightAnchor.constraint(equalTo: doneButton.leftAnchor).isActive = true
        
        // Stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
    }
}

// Actions
extension CreateListsView {
    @objc func actionCancelButtonClick() {
        self.onCancelButtonClickedCallback()
    }
    
    @objc func actionDoneButtonClick() {
        self.onDoneButtonClickedCallback()
    }
}

// Builder
extension CreateListsView {
    class func create(owner: Any) -> CreateListsView? {
        let bundle = Bundle.main
        let nibName = String(describing: CreateListsView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? CreateListsView
    }
}
