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
        if let color = AppAppearanceColors.DEFAULT[value]
        {
            return color
        }
        
        Logging.log(AppTheme.self, "Error: Undefined color for color value \(value.hashValue)")
        
        return UIColor.black
    }
    
    public func scrollBarColor() -> UIScrollView.IndicatorStyle
    {
        switch self.theme {
        case .LIGHT:
            return .black
        case .DARK:
            return .white
        case .MIX:
            return .default
        }
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
        .NAVIGATION_ITEM_SELECTION : Colors.LIGHT_BLUE,
        .STANDART_BACKGROUND : Colors.PAPER_WHITE,
        .PLAYER_BACKGROUND : Colors.PAPER_WHITE,
        .QUICK_PLAYER_BACKGROUND : Colors.DARK_GRAY,
        .STANDART_TEXT : Colors.BLACK,
        .STANDART_SUBTEXT : Colors.DARK_GRAY,
        .STANDART_BUTTON : Colors.BLUE,
        .QUICK_PLAYER_TEXT : Colors.WHITE,
        .QUICK_PLAYER_SUBTEXT : Colors.PAPER_WHITE,
        .QUICK_PLAYER_BUTTON : Colors.PAPER_WHITE,
        .QUICK_PLAYER_SEEK_BAR : Colors.ORANGE,
        .ALBUM_COVER_TITLE : Colors.BLACK,
        .ALBUM_COVER_ARTIST : Colors.DARK_GRAY,
        .ALBUM_COVER_DESCRIPTION : Colors.GRAY,
        .PLAYER_TEXT : Colors.BLACK,
        .PLAYER_BUTTON : Colors.BLACK,
        .PLAYER_TRACK_TITLE : Colors.BLACK,
        .PLAYER_PLAYLIST_TITLE : Colors.BLACK,
        .PLAYER_ARTIST : Colors.ORANGE,
        .PLAYER_SEEK_BAR : Colors.GREEN,
        .PLAYER_SEEK_BAR_BACKGROUND : Colors.DARK_GRAY,
        .PLAYER_SEEK_BAR_BORDER : Colors.DARK_GRAY,
        .PLAYER_SEEK_BAR_THUMB : Colors.WHITE,
        .PLAYER_SEEK_BAR_THUMB_BORDER : Colors.BLACK,
        .PLAYLIST_HIGHLIGHTED_TRACK : Colors.LIGHT_BLUE,
        .SEARCH_FILTER_PICKER_SELECTION : Colors.BLACK,
        .SEARCH_FILTER_PICKER_TINT : Colors.GREEN,
        .INDEXER_CHAR_COLOR : Colors.DARK_GRAY,
        .CREATE_LIST_SELECTED_TRACK : Colors.LIGHT_BLUE,
        .ANIMATION_CLICK_EFFECT : Colors.GREEN,
        .SETTINGS_DROP_DOWN_SELECTION : Colors.ORANGE
    ]
    public static let LIGHT : [ColorValue:UIColor] = [:]
    public static let DARK : [ColorValue:UIColor] = [
        .STANDART_BACKGROUND : Colors.DARK_GRAY,
        .PLAYER_BACKGROUND : Colors.DARK_GRAY,
        .QUICK_PLAYER_BACKGROUND : Colors.WHITE,
        .STANDART_TEXT : Colors.WHITE,
        .STANDART_SUBTEXT : Colors.YELLOW,
        .STANDART_BUTTON : Colors.YELLOW,
        .QUICK_PLAYER_TEXT : Colors.BLACK,
        .QUICK_PLAYER_SUBTEXT : Colors.DARK_GRAY,
        .QUICK_PLAYER_BUTTON : Colors.DARK_GRAY,
        .PLAYER_TEXT : Colors.WHITE,
        .PLAYER_BUTTON : Colors.PAPER_WHITE,
        .PLAYER_TRACK_TITLE : Colors.WHITE,
        .PLAYER_PLAYLIST_TITLE : Colors.WHITE,
        .PLAYER_ARTIST : Colors.YELLOW,
        .PLAYER_SEEK_BAR : Colors.GREEN,
        .PLAYER_SEEK_BAR_BACKGROUND : Colors.GRAY,
        .PLAYER_SEEK_BAR_BORDER : Colors.DARK_GRAY,
        .PLAYER_SEEK_BAR_THUMB : Colors.WHITE,
        .PLAYER_SEEK_BAR_THUMB_BORDER : Colors.BLACK,
        .PLAYLIST_HIGHLIGHTED_TRACK : Colors.LIGHT_BLUE,
        .SEARCH_FILTER_PICKER_SELECTION : Colors.BLACK,
        .SEARCH_FILTER_PICKER_TINT : Colors.YELLOW,
        .INDEXER_CHAR_COLOR : Colors.WHITE,
        .ALBUM_COVER_TITLE : Colors.WHITE,
        .ALBUM_COVER_ARTIST : Colors.PAPER_WHITE,
        .ALBUM_COVER_DESCRIPTION : Colors.YELLOW,
        .ANIMATION_CLICK_EFFECT : Colors.GREEN
    ]
    public static let MIX : [ColorValue:UIColor] = [
        .PLAYER_BACKGROUND : Colors.DARK_GRAY,
        .PLAYER_TEXT : Colors.WHITE,
        .PLAYER_BUTTON : Colors.PAPER_WHITE,
        .PLAYER_TRACK_TITLE : Colors.WHITE,
        .PLAYER_PLAYLIST_TITLE : Colors.WHITE,
        .PLAYER_ARTIST : Colors.YELLOW,
        .PLAYER_SEEK_BAR : Colors.GREEN,
        .PLAYER_SEEK_BAR_BACKGROUND : Colors.GRAY,
        .PLAYER_SEEK_BAR_BORDER : Colors.DARK_GRAY,
        .PLAYER_SEEK_BAR_THUMB : Colors.WHITE,
        .PLAYER_SEEK_BAR_THUMB_BORDER : Colors.BLACK
    ]
}
