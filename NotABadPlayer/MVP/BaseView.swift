//
//  BaseView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

/*
 * Describes a generic view.
 */
protocol BaseView : class {
    func goBack()
}

/*
 * Describes a generic view that supports opening the playlist screen.
 */
protocol BasePlayingView: BaseView {
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylistProtocol, options: OpenPlaylistOptions)
}
