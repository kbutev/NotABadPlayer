//
//  AppTheme.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 5.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class AppTheme
{
    public static let shared: AppTheme = AppTheme()
    
    private var lock: NSObject = NSObject()
    
    private var theme: AppThemeValue = .LIGHT
    
    public func setAppearance(theme: AppThemeValue)
    {
        // Thread safe
        lockEnter(self.lock)
        
        defer {
            lockExit(self.lock)
        }
        
        self.theme = theme
    }
    
    public func themeColorFor(_ value: ColorValue) -> UIColor?
    {
        switch self.theme {
        case .LIGHT:
            return AppAppearanceColors.LIGHT[value]
        case .DARK:
            return AppAppearanceColors.DARK[value]
        case .MIX:
            return AppAppearanceColors.MIX[value]
        }
    }
    
    public func colorFor(_ value: ColorValue) -> UIColor
    {
        // Thread safe
        lockEnter(self.lock)
        
        defer {
            lockExit(self.lock)
        }
        
        // First check if a color is overriden with the current color theme
        if let color = themeColorFor(value)
        {
            return color
        }
        
        // If it's not overriden, check the default colors
        return AppAppearanceColors.DEFAULT[value] ?? UIColor.black
    }
    
    private func lockEnter(_ lock: Any) {
        objc_sync_enter(lock)
    }
    
    private func lockExit(_ lock: Any) {
        objc_sync_exit(lock)
    }
}

class AppAppearanceColors
{
    public static let DEFAULT : [ColorValue:UIColor] = [
        .STANDART_BACKGROUND : Colors.PAPER_WHITE,
        .QUICK_PLAYER_BACKGROUND : Colors.GRAY,
        .STANDART_TEXT : Colors.BLACK,
        .QUICK_PLAYER_TEXT : Colors.BLACK,
        .STANDART_SUBTEXT : Colors.DARK_GRAY,
        .QUICK_PLAYER_SUBTEXT : Colors.DARK_GRAY,
        .NAVIGATION_ITEM_SELECTION : Colors.LIGHT_BLUE,
        .PLAYER_SEEK_BAR : Colors.GREEN,
        .PLAYER_SEEK_BAR_BACKGROUND : Colors.DARK_GRAY,
        .PLAYER_SEEK_BAR_BORDER : Colors.DARK_GRAY,
        .PLAYER_SIDE_VOLUME_BAR : Colors.BLUE,
        .QUICK_PLAYER_SEEK_BAR : Colors.ORANGE,
        .INDEXER_CHAR_COLOR : Colors.DARK_GRAY,
        .ANIMATION_CLICK_EFFECT : Colors.GREEN,
        .SETTINGS_DROP_DOWN_SELECTION : Colors.ORANGE
    ]
    public static let LIGHT : [ColorValue:UIColor] = [:]
    public static let DARK : [ColorValue:UIColor] = [
        .STANDART_BACKGROUND : Colors.DARK_GRAY,
        .QUICK_PLAYER_BACKGROUND : Colors.WHITE,
        .STANDART_TEXT : Colors.WHITE,
        .QUICK_PLAYER_TEXT : Colors.WHITE,
        .STANDART_SUBTEXT : Colors.PAPER_WHITE,
        .QUICK_PLAYER_SUBTEXT : Colors.DARK_GRAY,
        .INDEXER_CHAR_COLOR : Colors.WHITE
    ]
    public static let MIX : [ColorValue:UIColor] = [:]
}
