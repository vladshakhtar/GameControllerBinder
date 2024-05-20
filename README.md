# ``GameControllerBinder``

A Swift framework for easily integrating game controller inputs with UI elements in iOS applications.


## Overview

The GameControllerBinder framework simplifies the process of binding game controller inputs to UI elements and actions within your iOS app. With support for various controller types, including PlayStation and Xbox controllers, this framework allows for quick setup and configuration of controller inputs to enhance the gaming experience on iOS devices.


## Features

- Bind actions to game controller buttons and triggers
- Support for PlayStation and Xbox controllers
- Easy integration with UI elements
- Customize button actions for press and release states
- Automatic focus management for UI elements
- Directional navigation using D-pad and thumbsticks
- Simplified navigation setup for UI elements


## Installation

### Swift Package Manager

To integrate GameControllerBinder into your Xcode project using Swift Package Manager, add it to your package's dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/vladshakhtar/GameControllerBinder.git", from: "1.1.0")
]
```

### CocoaPods

GameControllerBinder is available through CocoaPods. To install it, simply add the following line to your Podfile:

```ruby
pod 'GameControllerBinder'
```

Don't forget to run pod install after editing the Podfile.


## Usage

Here's a short example of how you can use GameControllerBinder to bind a button action to a controller button:

```swift
import GameControllerBinder

let binder = GameControllerBinder()

// Bind the 'A' button to perform an action
binder.bindButtonToAction(buttonName: .buttonA) {
    print("Button A was pressed")
}
```

To bind a controller's thumbstick to UI navigation:
```swift
binder.bindThumbstickToAction(thumbstickName: .rightThumbstick) { [weak self] (xValue, yValue) in
            //code that handles Thumbsticks movements
        }
    
```

To bind a controller`s button to UIButton:
```swift
binder.bindButtonToUIElement(buttonName: .buttonMenu, uiElement: searchButton) {
            self.performSearch()  //You can use also @objc functions or @IBAction functions here
        }
```

Write next methods in override func viewDidAppear(_ animated: Bool) :
To register all focusable UI elements and set up default directional input handlers:
```swift
// Register all focusable subviews
binder.registerAllFocusableSubviews(from: view)

// Set up default directional input handlers
binder.setupDefaultDirectionalInputHandlers()
```
To set the initial focus on a specific element:
```swift
binder.setInitialFocus(to: yourInitialFocusableElement)
```
To set up the tap action input handler:
```swift
binder.setupTapActionInputHandler(for: .buttonA)
```

So everything will look like :
```swift
override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        binder.registerAllFocusableSubviews(from: view)
        binder.setupDefaultDirectionalInputHandlers()
        binder.setInitialFocus(to: yourInitialFocusableElement)
        binder.setupTapActionInputHandler()
    }
```
## License

GameControllerBinder is available under the MIT license. See the LICENSE file for details at 

```
https://github.com/vladshakhtar/GameControllerBinder/blob/main/LICENSE
```
