//
//  Presenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 30.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

/*
 * Describes a generic presenter.
 *
 * Call start() after the view controller is finished, to start operations.
 */
protocol BasePresenter {
    func start()
}
