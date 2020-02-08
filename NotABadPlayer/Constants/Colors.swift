//
//  Colors.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 5.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

struct Colors
{
    public static let CLEAR = UIColor.clear
    public static let BLACK = UIColor.black
    public static let WHITE = UIColor.white
    public static let PAPER_WHITE = UIColor(red:0.99, green:0.99, blue:0.98, alpha: 1)
    public static let GRAY = UIColor.gray
    public static let DARK_GRAY = UIColor(red:0.31, green:0.31, blue:0.31, alpha: 1)
    public static let GREEN = UIColor(red:0.0, green:0.7, blue:0.25, alpha: 1)
    public static let LIGHT_GREEN = UIColor(red:0.56, green:0.93, blue:0.56, alpha: 1)
    public static let RED = UIColor.red
    public static let LIGHT_BLUE = UIColor(displayP3Red: 0.37, green: 0.59, blue: 0.94, alpha: 1)
    public static let BLUE = UIColor(displayP3Red: 0.37, green: 0.59, blue: 1.0, alpha: 1)
    public static let YELLOW = UIColor.yellow
    public static let ORANGE = UIColor.orange
    public static let PURPLE = UIColor.purple
}

enum ColorValue
{
    case NAVIGATION_ITEM_SELECTION;
    
    case STANDART_BACKGROUND;
    case PLAYER_BACKGROUND;
    case QUICK_PLAYER_BACKGROUND;
    
    case STANDART_TEXT;
    case STANDART_SUBTEXT;
    case STANDART_BUTTON;
    
    case QUICK_PLAYER_TEXT;
    case QUICK_PLAYER_SUBTEXT;
    case QUICK_PLAYER_BUTTON;
    case QUICK_PLAYER_SEEK_BAR;
    
    case PLAYER_TEXT;
    case PLAYER_BUTTON;
    case PLAYER_TRACK_TITLE;
    case PLAYER_PLAYLIST_TITLE;
    case PLAYER_ARTIST;
    case PLAYER_SEEK_BAR;
    case PLAYER_SEEK_BAR_BACKGROUND;
    case PLAYER_SEEK_BAR_BORDER;
    case PLAYER_SEEK_BAR_THUMB;
    case PLAYER_SEEK_BAR_THUMB_BORDER;
    
    case ALBUM_COVER_TITLE;
    case ALBUM_COVER_ARTIST;
    case ALBUM_COVER_DESCRIPTION;
    
    case INDEXER_CHAR_COLOR;
    
    case PLAYLIST_PLAYING_TRACK;
    
    case SEARCH_FILTER_PICKER_SELECTION;
    case SEARCH_FILTER_PICKER_TINT;
    
    case CREATE_LIST_SELECTED_TRACK;
    
    case ANIMATION_CLICK_EFFECT;
    case SETTINGS_DROP_DOWN_SELECTION;
}
