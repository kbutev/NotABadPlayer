//
//  GeneralStorageObserver.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 28.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

struct GeneralStorageObserverValue
{
    weak var observer : GeneralStorageObserver?
    
    init(_ observer: GeneralStorageObserver)
    {
        self.observer = observer
    }
    
    var value : GeneralStorageObserver? {
        get {
            return observer
        }
    }
}

protocol GeneralStorageObserver : class {
    func onAppAppearanceChange()
    func onTabCachingPolicyChange(_ value: TabsCachingPolicy)
    func onResetDefaultSettings()
}
