//
//  CreateListsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 2.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class CreateListsViewController: UIViewController {
    private var baseView: CreateListsView?
    
    private var subViewController: PlaylistViewController?
    private var subViewControllerPlaylistName: String = ""
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.baseView = CreateListsView.create(owner: self)
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
    }
    
    private func goBack() {
        NavigationHelpers.removeVCChild(self)
    }
}
