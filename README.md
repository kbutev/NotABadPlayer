# NotABadPlayer-iOS

Created: 2019 June

iOS's default music player sucks so much that I remade it with some extra features.

Platform: iOS 11+

Usage: Media player

Technologies: iOS 11, [iOSDropDown](https://github.com/jriosdev/iOSDropDown), [GTProgressBar](https://github.com/gregttn/GTProgressBar)

Architectural design:

* MVP (Model=data, View=interface, Presenter=data/interface bridge, state controller)

* Normally the views themselves are the delegate for the presenters in MVP. However, here the view controlelrs are the ones who are view delegates for the presenters. The views are dumb, they don't know the presenter, and their interface is completely exposed to their view controllers. View controllers manager their views and communicate with their presenters, who, communicate back.

* No storyboards are used. Interface creation and navigation is entirely programmatic.

* The main view controller is essentially a custom tab view controller class. It is responsible for most of the navigation of the app. It creates the tab view controllers and their presenters and passes the model to them.

* Views use constraints to position themselves and their subviews properly.

* Presenters hold the model, responsible for decision making. They respond to view input (user interaction) and then forward back messages to their view delegates, to order them what to do.

Design patterns:

* Delegate - presenters and their views are delegates, both handling requests and forwarding them to each other, views are the responders to user input, who forward those events to the presenters, who, based on decision making, may or may not forward an action to their views

* Observer - some interface is updated trough a Looper singleton service, that notifies their observers when the timer elapses a specific interval; audio player notifies their observers when the audio state changes (start, pause, etc...)

* Singleton - used to easily refer to services such as the Audio Player (a wrapper of the built in iOS player), the Looper (repeated interval update for its clients), and the user storage used to store general info such at the app settings

* Decorator - the Audio Player wraps the iOS built in audio player - the AVAudioPlayer

* Command - keybind actions

General design:

* CPU and energy efficient, memory ineffecient since the audio information is retrieved once and reused when trying to use the audio player

* Very little little exception handling is done, do-catch blocks usually are there just to print errors/warnings

* Audio Library, a singleton that stores audio data of albums and tracks. It uses the iOS API MediaPlayer.

* Lifecycle: Very simple - when starting app, the launch view controller is launched before anything else. The view controller asks for permission, and after gaining it, it proceeeds with the app. The presenters have no real state, besides the view delegate property.

* Supports one orientation only: portrait

# Features

Bind all kinds of user actions like making the next/previous buttons jump backwards and forwards.

3 app themes and different sorting options.

CPU & energy efficient.

Includes standart player features like creating playlists, searching for tracks, controlling the audio player even when not on the player screen (a quick player is available, attached to the bottom of the screen).

Includes slightly more fancy features like jumping back to the previously played song, regardless to which album or list it belonged to.

You can control the audio player from the status and lock screen

Portrait mode only.

# Screens

Albums screen (quick player at the bottom, swipe up to open player screen)

![alt text](https://github.com/felixisto/NotABadPlayer/blob/master/About/scrn1.PNG)

Player screen

![alt text](https://github.com/felixisto/NotABadPlayer/blob/master/About/scrn2.PNG)

Playlist screen

![alt text](https://github.com/felixisto/NotABadPlayer/blob/master/About/scrn3.PNG)

Search screen

![alt text](https://github.com/felixisto/NotABadPlayer/blob/master/About/scrn4.PNG)

Settings screen - keybind options

![alt text](https://github.com/felixisto/NotABadPlayer/blob/master/About/scrn5.PNG)

Dark app theme

![alt text](https://github.com/felixisto/NotABadPlayer/blob/master/About/scrn6.PNG)
