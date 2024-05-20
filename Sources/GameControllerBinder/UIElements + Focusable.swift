//
//  UIElements + Focusable.swift
//  MyGameControllerFrameworkApp
//
//  Created by Vladislav Stolyarov on 24.03.2024.
//

import Foundation
import UIKit

/// A protocol defining the interface for elements that can be navigated using a game controller.
///
/// Conforming elements can be navigated through directional inputs and can receive focus,
/// allowing for visual customization when an element is focused or unfocused.
public protocol Focusable {
    /// A unique identifier for the focusable element, used for debugging and tracking purposes.
    ///
    /// Set this property to make it easier to identify elements during development. For example,
    /// you could use the name of the variable, the class name, or a custom identifier.
    var name: String { get set }

    /// Determines whether the element is currently able to receive focus.
    ///
    /// Elements that are hidden or disabled should return `false` to indicate that they
    /// cannot be focused. For example, a button that is not interactable should not be focusable.
    var isFocusable: Bool { get }

    /// The frame of the element in the coordinate space of the application's main window.
    ///
    /// This property is used to calculate spatial relationships with other focusable elements.
    /// Use it to provide the bounds that the `FocusManager` will use to navigate between elements.
    var globalFrame: CGRect { get }

    /// Called when the element gains focus.
    ///
    /// Implement this method to customize the appearance of the element when it is focused.
    /// Common customizations include highlighting, enlarging, or changing the border of the element.
    func focus()

    /// Called when the element loses focus.
    ///
    /// Implement this method to revert any changes made in `focus()`. This could involve
    /// removing highlights, resizing, or resetting borders.
    func unfocus()
    
    ///Called when "a" button of controller is tapped.
    ///
    /// Simulates a tap gesture, akin to triggering the primary action of the element.
    /// This method is called when the user presses a corresponding button on a game controller.
    func simulateTap()
}

// Extensions that allows certain subclasses of UIView be Focusable

extension UIControl: Focusable {
    
    
    public var globalFrame: CGRect {
        return (self.superview?.convert(self.frame, to: nil))!
    }
    
    
    private static var _nameKey: Void?
    
    public var name: String {
        get {
            if let name = objc_getAssociatedObject(self, &UIControl._nameKey) as? String {
                return name
            }
            let className = String(describing: type(of: self))
            return "\(className) \(self.globalFrame)"
        }
        set {
            objc_setAssociatedObject(self, &UIControl._nameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var isFocusable: Bool {
        get { return !isHidden && isEnabled }
    }
    
    public func focus() {
        self.layer.borderColor = UIColor.blue.cgColor
        self.layer.borderWidth = 2.0
    }
    
    public func unfocus() {
        // Revert visual changes made in focus()
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0.0
    }
    
    public func simulateTap() {
            switch self {
            case let button as UIButton:
                button.sendActions(for: .touchUpInside)
            case let switcher as UISwitch:
                switcher.setOn(!switcher.isOn, animated: true)
                switcher.sendActions(for: .valueChanged)
            case let slider as UISlider:
                slider.setValue((slider.maximumValue - slider.minimumValue) / 2, animated: true)
                slider.sendActions(for: .valueChanged)
            case let stepper as UIStepper:
                stepper.value += stepper.stepValue
                stepper.sendActions(for: .valueChanged)
            case let datePicker as UIDatePicker:
                datePicker.date = Date() // or a specific date, triggering the change
                datePicker.sendActions(for: .valueChanged)
            case let pageControl as UIPageControl:
                pageControl.currentPage = (pageControl.currentPage + 1) % pageControl.numberOfPages
                pageControl.sendActions(for: .valueChanged)
            case let segmentedControl as UISegmentedControl:
                segmentedControl.selectedSegmentIndex = (segmentedControl.selectedSegmentIndex + 1) % segmentedControl.numberOfSegments
                segmentedControl.sendActions(for: .valueChanged)
            case let colorWell as UIColorWell:
                colorWell.isSelected = true // Simulating tap may involve showing a color picker
                colorWell.sendActions(for: .valueChanged)
            default:
                sendActions(for: .touchUpInside)
            }
        }}


extension UITableView : Focusable {
    private static var _nameKey: Void?
    
    public var name: String {
        get {
            if let name = objc_getAssociatedObject(self, &UITableView._nameKey) as? String {
                return name
            }
            let className = String(describing: type(of: self))
            return "\(className) \(self.globalFrame)"
        }
        set {
            objc_setAssociatedObject(self, &UITableView._nameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public var isFocusable: Bool {
        get {
            !isHidden && isUserInteractionEnabled
        }

    }
    
    public var globalFrame: CGRect {
        return (self.superview?.convert(self.frame, to: nil))!
    }
    
    public func focus() {
        
    }
    
    public func unfocus() {
        
    }
    
    public func simulateTap() {

    }
}




extension UISearchBar: Focusable {
    
    public var globalFrame: CGRect {
        return (self.superview?.convert(self.frame, to: nil))!
    }
    
    private static var _nameKey: Void?
    
    public var name: String {
        get {
            if let name = objc_getAssociatedObject(self, &UISearchBar._nameKey) as? String {
                return name
            }
            let className = String(describing: type(of: self))
            return "\(className) \(self.globalFrame)"
        }
        set {
            objc_setAssociatedObject(self, &UISearchBar._nameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var isFocusable: Bool {
        get { return !isHidden }

    }
    
    public func focus() {
        self.layer.borderColor = UIColor.blue.cgColor
        self.layer.borderWidth = 2.0
        self.becomeFirstResponder()
    }
    
    public func unfocus() {
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0.0
        self.resignFirstResponder()
    }
    
    public func simulateTap() {
        self.becomeFirstResponder()
    }
}


extension UITextView: Focusable {
    
    public var globalFrame: CGRect {
        return (self.superview?.convert(self.frame, to: nil))!
    }
    
    private static var _nameKey: Void?
    
    public var name: String {
        get {
            if let name = objc_getAssociatedObject(self, &UITextView._nameKey) as? String {
                return name
            }
            let className = String(describing: type(of: self))
            return "\(className) \(self.globalFrame)"
        }
        set {
            objc_setAssociatedObject(self, &UITextView._nameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    public var isFocusable: Bool {
        get { return !isHidden && isEditable }
    }
    
    public func focus() {
        self.layer.borderColor = UIColor.blue.cgColor
        self.layer.borderWidth = 2.0
        self.becomeFirstResponder()
    }
    
    public func unfocus() {
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0.0
        self.resignFirstResponder()
    }
    
    public func simulateTap() {
        self.becomeFirstResponder()
    }
}


// Special type of Focusable element which is needed to show that element is Edge at a particular direction
final class EdgeElement: Focusable {
    var name: String = "Edge"
    var isFocusable: Bool = false
    var globalFrame: CGRect = .zero // Edge elements don't have a frame.

    func focus() { /* Do nothing */ }
    func unfocus() { /* Do nothing */ }
    
    public func simulateTap() {/* Do nothing */ }
}

extension EdgeElement {
    static let shared = EdgeElement()
}

// Function that collects all possible subviews of a particular view
extension UIView {
    public var allSubviews: [UIView]
    {
        return self.subviews.flatMap { [$0] + $0.allSubviews }
    }
}

