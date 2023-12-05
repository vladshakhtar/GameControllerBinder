// The Swift Programming Language
// https://docs.swift.org/swift-book


import Foundation
import UIKit
import GameController



/// A class that binds game controller inputs to UI elements for navigation and interaction within an iOS app.
public final class GameControllerBinder {
    
    
    /// Represents the names of buttons available on a standard game controller.
    public enum ButtonName {
        /// The A button, often used for main actions. ("Cross" on PlayStation Controllers)
        case buttonA
        /// The B button, often used for secondary actions or canceling.  ("Circle" on PlayStation Controllers)
        case buttonB
        /// The X button, typically used for alternative actions.  ("Square" on PlayStation Controllers)
        case buttonX
        /// The Y button, also used for alternative actions or menu navigation.  ("Triangle" on PlayStation Controllers)
        case buttonY
        /// The left shoulder button, usually triggers shoulder actions or item switching.  ("L1" on PlayStation Controllers)
        case leftShoulder
        /// The right shoulder button, similar to the left shoulder in use.  ("R1" on PlayStation Controllers)
        case rightShoulder
        /// The menu button, typically brings up in-game or app menus.  ("Options" on PlayStation Controllers)
        case buttonMenu
        /// The options button, can be used for additional in-game options.  ("Share" on PlayStation Controllers)
        case buttonOptions
        /// The home button, often used to exit to the main menu or dashboard.  ("PlayStation" on PlayStation Controllers)
        case buttonHome
        /// The left thumbstick click button, used for additional actions.
        case leftThumbstickButton
        /// The right thumbstick click button, similar to the left thumbstick button.
        case rightThumbstickButton
        /// The directional pad up button.
        case dpadUp
        /// The directional pad down button.
        case dpadDown
        /// The directional pad left button.
        case dpadLeft
        /// The directional pad right button.
        case dpadRight
    }
    
    /// Represents the names of triggers on a game controller.
    public enum TriggerName {
        /// The left trigger, often used for actions like aiming or braking.
        case leftTrigger
        /// The right trigger, commonly used for actions such as shooting or accelerating.
        case rightTrigger
    }
    
    /// Represents the thumbsticks on a game controller.
    public enum ThumbstickName {
        /// The left thumbstick, used for primary character movement or navigation.
        case leftThumbstick
        /// The right thumbstick, used for camera control or secondary navigation.
        case rightThumbstick
    }
    
    /// Represents the type of game controller connected.
    public enum ControllerType {
        /// A DualSense controller (PlayStation 5).
        case dualSense
        /// A DualShock controller (PlayStation 4).
        case dualShock
        /// An Xbox controller.
        case xbox
        /// A generic controller type, for other controllers.
        case generic
    }
    
    /// Represents the specific buttons found on PlayStation controllers.
    public enum PlayStationButtonName {
        /// The touchpad button, which can also act as a clickable button.
        case touchpadButton
        /// The top part of the touchpad, acting as the up directional input that is touched or pressed by the primary finger.
        case touchpadPrimaryUp
        /// The bottom part of the touchpad, acting as the up directional input that is touched or pressed by the primary finger.
        case touchpadPrimaryDown
        /// The left part of the touchpad, acting as the up directional input that is touched or pressed by the primary finger.
        case touchpadPrimaryLeft
        /// The right part of the touchpad, acting as the up directional input that is touched or pressed by the primary finger.
        case touchpadPrimaryRight
        /// The top part of the touchpad, acting as the up directional input that is touched or pressed by the secondary finger.
        case touchpadSecondaryUp
        /// The bottom part of the touchpad, acting as the up directional input that is touched or pressed by the secondary finger.
        case touchpadSecondaryDown
        /// The left part of the touchpad, acting as the up directional input that is touched or pressed by the secondary finger.
        case touchpadSecondaryLeft
        /// The right part of the touchpad, acting as the up directional input that is touched or pressed by the secondary  finger.
        case touchpadSecondaryRight
    }
    
    /// Represents the specific buttons found on Xbox controllers.
    public enum XboxButtonName {
        /// The  paddle 1 button element, which has a P1 label on the back of the controller.
        case paddleButton1
        /// The paddle 2 button element, which has a P2 label on the back of the controller.
        case paddleButton2
        /// The paddle 3 button element, which has a P2 label on the back of the controller.
        case paddleButton3
        /// The paddle 4 button element, which has a P2 label on the back of the controller.
        case paddleButton4
        /// The share button on an Xbox Series X|S controller or later.
        case shareButton
    }
    
    
    
    private var buttonActionBindings: [ButtonName: () -> Void] = [:]
    private var buttonActionReleaseBindings: [ButtonName: (press: () -> Void, release: () -> Void)] = [:]
    private var triggerActionBindings: [TriggerName: (Float) -> Void] = [:]
    private var thumbstickActionBindings: [ThumbstickName: (Float, Float) -> Void] = [:]
    private var psButtonActionBindings: [PlayStationButtonName: () -> Void] = [:]
    private var psButtonActionReleaseBindings: [PlayStationButtonName: (press: () -> Void, release: () -> Void)] = [:]
    private var xboxButtonActionBindings: [XboxButtonName: () -> Void] = [:]
    private var xboxButtonActionReleaseBindings: [XboxButtonName: (press: () -> Void, release: () -> Void)] = [:]
    
    
    
    /// Initializes a new GameControllerBinder instance.
    /// It sets up notification observers for when game controllers connect or disconnect.
    public init() {
        NotificationCenter.default.addObserver(self, selector: #selector(controllerConnected), name: .GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controllerDisconnected), name: .GCControllerDidDisconnect, object: nil)
    }
    
    
    //MARK: - Main Framework Functions
    
    /// Indicates whether a game controller is currently connected.
    public var isConnected : Bool = false
    /// The type of game controller that is currently connected, if any.
    /// This property is nil if no controller is connected.
    public var controllerType: ControllerType?
    
    
    
    /// Binds an action to be performed when the specified controller button is pressed.
    /// - Parameters:
    ///   - buttonName: The name of the controller button to which the action will be bound.
    ///   - action: The closure to be executed when the button is pressed.
    public func bindButtonToAction(buttonName: ButtonName, action: @escaping () -> Void) {
        buttonActionBindings[buttonName] = action
    }
    
    
    /// Binds actions to be performed when the specified controller button is pressed and released.
    /// - Parameters:
    ///   - buttonName: The name of the controller button to which the press action  and release action will be bound.
    ///   - pressAction: The closure to be executed when the button is pressed.
    ///   - releaseAction: The closure to be executed when the button is released.
    public func bindButtonToAction(buttonName: ButtonName, pressAction: @escaping () -> Void, releaseAction: @escaping () -> Void) {
        buttonActionReleaseBindings[buttonName] = (pressAction, releaseAction)
    }
    
    
    /// Binds an action to a UI element, such as a UIButton, to be performed when the specified game controller button is pressed. Optionally includes animation when the button is pressed and released.
    /// - Parameters:
    ///   - buttonName: The name of the controller button to which the UI element will be bound.
    ///   - uiElement: The UIButton to which controller button will be bound.
    ///   - withAnimation: Specifies whether the UI element should show an animation on press and release. It is set `true` by default.
    ///   - action: The closure to be executed when the button is pressed.
    public func bindButtonToUIElement(buttonName: ButtonName, uiElement: UIButton, withAnimation : Bool = true, action: @escaping () -> Void) {
        bindButtonToAction(
            buttonName: buttonName,
            pressAction: {
                DispatchQueue.main.async {
                    if withAnimation {
                        uiElement.isHighlighted = true
                    }
                    action()
                }
            },
            releaseAction: {
                if withAnimation {
                    DispatchQueue.main.async {
                        uiElement.isHighlighted = false
                    }
                }
            }
        )
    }
    
    /// Binds an action to be performed when the specified controller trigger is activated.
    /// - Parameters:
    ///   - triggerName: The name of the controller trigger to which the action will be bound.
    ///   - action: The closure that takes the trigger's value and is executed when the trigger is activated.
    public func bindTriggerToAction(triggerName: TriggerName, action: @escaping (Float) -> Void) {
        triggerActionBindings[triggerName] = action
    }
    
    /// Binds an action to be performed when the specified controller thumbstick is moved.
    /// - Parameters:
    ///   - thumbstickName: The name of the thumbstick to which the action will be bound.
    ///   - action: The closure that takes the thumbstick's x and y values and is executed when the thumbstick is moved.
    public func bindThumbstickToAction(thumbstickName: ThumbstickName, action: @escaping (Float, Float) -> Void) {
        thumbstickActionBindings[thumbstickName] = action
    }
    
    /// Binds an action to be performed when the specified PlayStation controller button is pressed.
    /// - Parameters:
    ///   - playStationButtonName: The name of the PlayStation controller button to which the action will be bound.
    ///   - action: The closure to be executed when the PlayStation button is pressed.
    public func bindPlaystionButtonToAction(playStationButtonName : PlayStationButtonName, action: @escaping () -> Void) {
        psButtonActionBindings[playStationButtonName] = action
    }
    
    /// Binds actions to be performed when the specified PlayStation controller button is pressed and released.
    /// - Parameters:
    ///   - playStationButtonName: The name of the PlayStation controller  button to which the action will be bound.
    ///   - pressAction: The closure to be executed when the PlayStation controller button is pressed.
    ///   - releaseAction: The closure to be executed when the PlayStation controller button is released.
    public func bindPlaystationButtonToAction(playStationButtonName : PlayStationButtonName, pressAction: @escaping () -> Void, releaseAction: @escaping () -> Void) {
        psButtonActionReleaseBindings[playStationButtonName] = (pressAction, releaseAction)
    }
    
    /// Binds an action to be performed when the specified Xbox controller button is pressed.
    /// - Parameters:
    ///   - xboxButtonName: The name of the Xbox controller button to which the action will be bound.
    ///   - action: The closure to be executed when the Xbox controller button is pressed.
    public func bindXboxButtonToAction(xboxButtonName : XboxButtonName, action: @escaping () -> Void) {
        xboxButtonActionBindings[xboxButtonName] = action
    }
    
    /// Binds actions to be performed when the specified Xbox controller button is pressed and released.
    /// - Parameters:
    ///   - xboxButtonName: The name of the Xbox controller button to which the action will be bound.
    ///   - pressAction: The closure to be executed when the Xbox controller button is pressed.
    ///   - releaseAction: The closure to be executed when the Xbox controller button is releasen.
    public func bindXboxButtonToAction(xboxButtonName : XboxButtonName,  pressAction: @escaping () -> Void, releaseAction: @escaping () -> Void) {
        xboxButtonActionReleaseBindings[xboxButtonName] = (pressAction, releaseAction)
    }
    
    
    
    
    
    //MARK: - Helpful Framework Functions
    @objc private func controllerConnected() {
        guard let controller = GCController.controllers().first else { return }
        isConnected = true
        setupButtonHandlers(for: controller)
        setupTriggerHandlers(for: controller)
        setupThumbstickHandlers(for: controller)
        setupPlaystationButtonHandlers(for: controller)
        setupXboxButtonHandlers(for: controller)
        detectControllerType(for: controller)
        
    }
    
    @objc private func controllerDisconnected() {
        // Handle controller disconnection if needed
        isConnected = false
        self.controllerType = nil
    }
    
    private func setupButtonHandlers(for controller: GCController) {
        if let gamepad = controller.extendedGamepad {
            let buttons = [
                (gamepad.buttonA, ButtonName.buttonA),
                (gamepad.buttonB, ButtonName.buttonB),
                (gamepad.buttonX, ButtonName.buttonX),
                (gamepad.buttonY, ButtonName.buttonY),
                (gamepad.leftShoulder, ButtonName.leftShoulder),
                (gamepad.rightShoulder, ButtonName.rightShoulder),
                (gamepad.buttonMenu, ButtonName.buttonMenu),
                (gamepad.buttonOptions, ButtonName.buttonOptions),
                (gamepad.buttonHome, ButtonName.buttonHome),
                (gamepad.leftThumbstickButton, ButtonName.leftThumbstickButton),
                (gamepad.rightThumbstickButton, ButtonName.rightThumbstickButton),
                (gamepad.dpad.up, ButtonName.dpadUp),
                (gamepad.dpad.down, ButtonName.dpadDown),
                (gamepad.dpad.left, ButtonName.dpadLeft),
                (gamepad.dpad.right, ButtonName.dpadRight)
            ]
            
            for (button, name) in buttons {
                button?.valueChangedHandler = { [weak self] (_, _, pressed) in
                    if pressed {
                        // Check for press and release bindings first
                        if let pressReleaseAction = self?.buttonActionReleaseBindings[name] {
                            pressReleaseAction.press()
                        } else {
                            // Fallback to single-action binding
                            self?.buttonActionBindings[name]?()
                        }
                    } else {
                        // Handle button release
                        self?.buttonActionReleaseBindings[name]?.release()
                    }
                }
            }
        }
    }
    
    private func setupTriggerHandlers(for controller: GCController) {
        if let gamepad = controller.extendedGamepad {
            let triggers = [
                (gamepad.leftTrigger, TriggerName.leftTrigger),
                (gamepad.rightTrigger, TriggerName.rightTrigger)
            ]
            
            for (trigger, name) in triggers {
                trigger.valueChangedHandler = { [weak self] (trigger, value, pressed) in
                    self?.triggerActionBindings[name]?(value)
                }
            }
        }
    }
    
    private func setupThumbstickHandlers(for controller: GCController) {
        if let gamepad = controller.extendedGamepad {
            // Set up value changed handlers for the thumbsticks
            gamepad.leftThumbstick.valueChangedHandler = { [weak self] (thumbstick, xValue, yValue) in
                self?.thumbstickActionBindings[.leftThumbstick]?(xValue, yValue)
            }
            gamepad.rightThumbstick.valueChangedHandler = { [weak self] (thumbstick, xValue, yValue) in
                self?.thumbstickActionBindings[.rightThumbstick]?(xValue, yValue)
            }
        }
    }
    
    
    private func setupPlaystationButtonHandlers(for controller: GCController) {
        if let playstationGamepad = controller.physicalInputProfile as? GCDualShockGamepad {
            let psButtons : [(GCControllerButtonInput, PlayStationButtonName)] = [
                (playstationGamepad.touchpadButton, .touchpadButton),
                (playstationGamepad.touchpadPrimary.up, .touchpadPrimaryUp),
                (playstationGamepad.touchpadPrimary.right, .touchpadPrimaryRight),
                (playstationGamepad.touchpadPrimary.left, .touchpadPrimaryLeft),
                (playstationGamepad.touchpadPrimary.down, .touchpadPrimaryDown),
                (playstationGamepad.touchpadSecondary.up, .touchpadSecondaryUp),
                (playstationGamepad.touchpadSecondary.right, .touchpadSecondaryRight),
                (playstationGamepad.touchpadSecondary.down, .touchpadSecondaryDown),
                (playstationGamepad.touchpadSecondary.left, .touchpadSecondaryLeft)
            ]
            
            
            for (psButton, name) in psButtons {
                psButton.valueChangedHandler = { [weak self] (_, _, pressed) in
                    if pressed {
                        // Check for press and release bindings first
                        if let pressReleaseAction = self?.psButtonActionReleaseBindings[name] {
                            pressReleaseAction.press()
                        } else {
                            // Fallback to single-action binding
                            self?.psButtonActionBindings[name]?()
                        }
                    } else {
                        // Handle button release
                        self?.psButtonActionReleaseBindings[name]?.release()
                    }
                }
            }
        } else if let playstationGamepad = controller.physicalInputProfile as? GCDualSenseGamepad {
            let psButtons : [(GCControllerButtonInput, PlayStationButtonName)] = [
                (playstationGamepad.touchpadButton, .touchpadButton),
                (playstationGamepad.touchpadPrimary.up, .touchpadPrimaryUp),
                (playstationGamepad.touchpadPrimary.right, .touchpadPrimaryRight),
                (playstationGamepad.touchpadPrimary.left, .touchpadPrimaryLeft),
                (playstationGamepad.touchpadPrimary.down, .touchpadPrimaryDown),
                (playstationGamepad.touchpadSecondary.up, .touchpadSecondaryUp),
                (playstationGamepad.touchpadSecondary.right, .touchpadSecondaryRight),
                (playstationGamepad.touchpadSecondary.down, .touchpadSecondaryDown),
                (playstationGamepad.touchpadSecondary.left, .touchpadSecondaryLeft)
            ]
            
            
            for (psButton, name) in psButtons {
                psButton.valueChangedHandler = { [weak self] (_, _, pressed) in
                    if pressed {
                        // Check for press and release bindings first
                        if let pressReleaseAction = self?.psButtonActionReleaseBindings[name] {
                            pressReleaseAction.press()
                        } else {
                            // Fallback to single-action binding
                            self?.psButtonActionBindings[name]?()
                        }
                    } else {
                        // Handle button release
                        self?.psButtonActionReleaseBindings[name]?.release()
                    }
                }
            }
        }
        
    }
    
    
    private func setupXboxButtonHandlers(for controller: GCController){
        if let xboxGamepad = controller.physicalInputProfile as? GCXboxGamepad {
            let xboxButtons : [(GCControllerButtonInput?, XboxButtonName)] = [
                (xboxGamepad.buttonShare, .shareButton),
                (xboxGamepad.paddleButton1, .paddleButton1),
                (xboxGamepad.paddleButton2, .paddleButton2),
                (xboxGamepad.paddleButton3, .paddleButton3),
                (xboxGamepad.paddleButton4, .paddleButton4)
            ]
            
            for (xboxButton, name) in xboxButtons {
                xboxButton?.valueChangedHandler = { [weak self] (_, _, pressed) in
                    if pressed {
                        // Check for press and release bindings first
                        if let pressReleaseAction = self?.xboxButtonActionReleaseBindings[name] {
                            pressReleaseAction.press()
                        } else {
                            // Fallback to single-action binding
                            self?.xboxButtonActionBindings[name]?()
                        }
                    } else {
                        // Handle button release
                        self?.xboxButtonActionReleaseBindings[name]?.release()
                    }
                }
            }
        }
    }
    
    private func detectControllerType(for controller: GCController) {
        if let _ = controller.physicalInputProfile as? GCDualSenseGamepad {
            controllerType = .dualSense
        } else if let _ = controller.physicalInputProfile as? GCDualShockGamepad {
            controllerType = .dualShock
        } else if let _ = controller.physicalInputProfile as? GCXboxGamepad {
            controllerType = .xbox
        } else {
            controllerType = .generic
        }
    }
    
}
