//
//  FocusManagementSystem.swift
//  
//
//  Created by Vladislav Stolyarov on 24.03.2024.
//

import Foundation
import UIKit


//Class that builds navigational map of the view and
//manages changing focusable element when input from gamecontroller comes
final class FocusManager {
    
    //MARK: - Properties
    
    
    // Singleton instance of the class
    static let shared = FocusManager()
    // Array which contains all `Focusable` elements embedded in `FocusableElement` class
    fileprivate var focusableElements: [FocusableElement] = []
    // Property which helds info about the element that is currently in focus
    private var currentFocusedElement: FocusableElement?
    // Dictionary which helds info about the indexpath of particular tableView that is currently in focus
    private var currentFocusedIndexPaths: [String: IndexPath] = [:]
    

    
    //MARK: - Main functions
    
    // Function which is called in GameControllerBinder class that adds element to an array
    internal func registerFocusableElement(_ element: Focusable) {
        if element.isFocusable {
            focusableElements.append(FocusableElement(element: element))
        }
        
    }
    
    // Function which sets initial focus by default - to the topmost element
    internal func setInitialFocus() {
        sortElementsVertically()
        currentFocusedElement = focusableElements.first
        currentFocusedElement?.thisElement.focus()
    }
    
    // Function that allows to set initial focus to a custom element
    internal func setInitialFocus(to elementName: String) {
        if let currentFocusedElement = currentFocusedElement {
            currentFocusedElement.thisElement.unfocus()
        }
        
        if let element = focusableElements.first(where: { $0.thisElement.name == elementName }) {
            currentFocusedElement = element
            currentFocusedElement?.thisElement.focus()
        } else {
            setInitialFocus()
        }
    }
    
    // Function that removes focus from an element
    internal func clearFocus() {
        if let currentFocusedElement = currentFocusedElement {
            currentFocusedElement.thisElement.unfocus()
        }
        currentFocusedElement = nil
    }
    
    //Function that changes currentFocusableElement based on direction of change
    internal func changeFocus(direction: FocusDirection) {
        guard let current = currentFocusedElement else { return }
        
        let nextFocusable: Focusable?
        switch direction {
            case .up:
                nextFocusable = current.nearestTop
            case .down:
                nextFocusable = current.nearestBottom
            case .left:
                nextFocusable = current.nearestLeft
            case .right:
                nextFocusable = current.nearestRight
        }
        
        if let next = nextFocusable {
            if let tableView = current.thisElement as? UITableView {
                handleLeavingTableView(tableView: tableView, direction: direction, nextFocusable: next)
            } else if let tableView = next as? UITableView {
                handleEnteringTableView(tableView: tableView, direction: direction)
                updateFocus(to: next)
            } else  {
                updateFocus(to: next)
            }
        }
    }
    
    //Function that visually changes currentFocusableElement when this element is found
    private func updateFocus(to focusable: Focusable?) {
        guard let newFocus = focusable else { return }
        guard newFocus.name != EdgeElement.shared.name else { return }
        guard let current = currentFocusedElement else { return }
        // Unfocus the current element
        current.thisElement.unfocus()
        // Update the current focus to the new element
        currentFocusedElement = focusableElements.first { $0.thisElement.name == newFocus.name }
        // Focus the new element
        currentFocusedElement?.thisElement.focus()
    }
    
    //Function that handles changes when next focusable element is of type UITableView
    private func handleEnteringTableView(tableView: UITableView, direction: FocusDirection) {
        // Determine the entry row based on the direction
        let entryRow = (direction == .up) ? (tableView.numberOfRows(inSection: tableView.numberOfSections - 1) - 1) : 0
        let entrySection = (direction == .up) ? (tableView.numberOfSections - 1) : 0
        currentFocusedIndexPaths[tableView.name] = IndexPath(row: entryRow, section: entrySection)

        // Set the focus to the first or last cell based on the direction
        updateFocusToTableView(tableView: tableView, at: IndexPath(row: entryRow, section: entrySection))
    }
    
    //Function that visually focuses particular TableViewCell
    private func updateFocusToTableView(tableView: UITableView, at indexPath: IndexPath) {
        // Update the visual state of the cell
        if let _ = tableView.cellForRow(at: indexPath) {
            currentFocusedElement?.thisElement.unfocus() // Unfocus current element
//            cell.backgroundColor = UIColor.lightGray // Focus cell
        }
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        
        // Ensure the cell is visible
        tableView.scrollToRow(at: indexPath, at: .none, animated: true)
        
        currentFocusedIndexPaths[tableView.name] = indexPath
    }
    
    //Function that visually removes focus from particular TableViewCell
    private func removeFocusFromTableView(tableView : UITableView, at indexPath: IndexPath) {
        //Update the visual state of the cell
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // Function that handles changes when currentFocusableElement is of type UITableView
    private func handleLeavingTableView(tableView: UITableView, direction: FocusDirection, nextFocusable : Focusable) {
        if let indexPath = currentFocusedIndexPaths[tableView.name] {
            switch direction {
                case .up where indexPath.row == 0 && indexPath.section == 0,
                        .down where indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 && indexPath.section == tableView.numberOfSections - 1,
                        .left, .right:
                    // If we're at the boundary, leave the table view
                    guard nextFocusable.name != EdgeElement.shared.name else { return }
                    removeFocusFromTableView(tableView: tableView, at: indexPath)
                    if let tableView = nextFocusable as? UITableView {
                        handleEnteringTableView(tableView: tableView, direction: direction)
                        updateFocus(to: nextFocusable)
                    } else  {
                        updateFocus(to: nextFocusable)
                    }
                    currentFocusedIndexPaths[tableView.name] = nil
                case .up, .down:
                    // Otherwise, move to the next row in the specified direction
                    removeFocusFromTableView(tableView: tableView, at: indexPath)
                    let newRow = direction == .up ? indexPath.row - 1 : indexPath.row + 1
                    let newSection = direction == .up && newRow < 0 ? indexPath.section - 1 : direction == .down && newRow >= tableView.numberOfRows(inSection: indexPath.section) ? indexPath.section + 1 : indexPath.section
                    let correctedRow = direction == .up && newRow < 0 ? tableView.numberOfRows(inSection: newSection) - 1 : direction == .down && newRow >= tableView.numberOfRows(inSection: indexPath.section) ? 0 : newRow
                    updateFocusToTableView(tableView: tableView, at: IndexPath(row: correctedRow, section: newSection))
            }
        }
    }
    
    // Function that simulates tap event  on the current focused element
    internal func simulateTapOnFocusedElement() {
        if let tableView = currentFocusedElement?.thisElement as? UITableView,
           let indexPath = currentFocusedIndexPaths[tableView.name] {
            // If the focused element is a UITableView and it has a focused index path
            tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
        } else {
            // For all other focusable elements, call the standard simulateTap method
            currentFocusedElement?.thisElement.simulateTap()
        }
    }

    // Main function that builds navigational map of the View
    internal func calculateNearestNeighbors() {
        guard focusableElements.count > 2 else {
            if focusableElements.count == 2 {
                switch position(to: focusableElements[0].thisElement, of: focusableElements[1].thisElement) {
                    case .down :
                        focusableElements[0].nearestBottom = focusableElements[1].thisElement
                        focusableElements[0].nearestLeft = EdgeElement.shared
                        focusableElements[0].nearestRight = EdgeElement.shared
                        focusableElements[0].nearestTop = EdgeElement.shared
                        focusableElements[1].nearestTop = focusableElements[0].thisElement
                        focusableElements[1].nearestLeft = EdgeElement.shared
                        focusableElements[1].nearestRight = EdgeElement.shared
                        focusableElements[1].nearestBottom = EdgeElement.shared
                        return
                    case .left :
                        focusableElements[0].nearestBottom = EdgeElement.shared
                        focusableElements[0].nearestLeft = focusableElements[1].thisElement
                        focusableElements[0].nearestRight = EdgeElement.shared
                        focusableElements[0].nearestTop = EdgeElement.shared
                        focusableElements[1].nearestTop = EdgeElement.shared
                        focusableElements[1].nearestLeft = EdgeElement.shared
                        focusableElements[1].nearestRight = focusableElements[0].thisElement
                        focusableElements[1].nearestBottom = EdgeElement.shared
                        return
                    case .right :
                        focusableElements[1].nearestBottom = EdgeElement.shared
                        focusableElements[1].nearestLeft = focusableElements[0].thisElement
                        focusableElements[1].nearestRight = EdgeElement.shared
                        focusableElements[1].nearestTop = EdgeElement.shared
                        focusableElements[0].nearestTop = EdgeElement.shared
                        focusableElements[0].nearestLeft = EdgeElement.shared
                        focusableElements[0].nearestRight = focusableElements[1].thisElement
                        focusableElements[0].nearestBottom = EdgeElement.shared
                        return
                    case .up :
                        focusableElements[1].nearestBottom = focusableElements[0].thisElement
                        focusableElements[1].nearestLeft = EdgeElement.shared
                        focusableElements[1].nearestRight = EdgeElement.shared
                        focusableElements[1].nearestTop = EdgeElement.shared
                        focusableElements[0].nearestTop = focusableElements[1].thisElement
                        focusableElements[0].nearestLeft = EdgeElement.shared
                        focusableElements[0].nearestRight = EdgeElement.shared
                        focusableElements[0].nearestBottom = EdgeElement.shared
                        return
                }
            } else if focusableElements.count == 1 {
                focusableElements[0].nearestTop = EdgeElement.shared
                focusableElements[0].nearestBottom = EdgeElement.shared
                focusableElements[0].nearestLeft = EdgeElement.shared
                focusableElements[0].nearestRight = EdgeElement.shared
                return
            } else {
                return
            }
        }
        
        sortElementsVertically()
        
        
        
        var currentIndex = 0
        
        focusableElements[currentIndex].nearestTop = EdgeElement.shared
        focusableElements[focusableElements.count-1].nearestBottom = EdgeElement.shared
        
        var backwardIndex = focusableElements.count - 2
        backwardLoop : while position(to: focusableElements[focusableElements.count - 1].thisElement, of: focusableElements[backwardIndex].thisElement) != .up {
            focusableElements[backwardIndex].nearestBottom = EdgeElement.shared
            backwardIndex -= 1
            if backwardIndex < 0 {
                break backwardLoop
            }
        }
        
        
        var forwardIndex = currentIndex + 1
        
        var checkIfLowerIndex = 0
        
        while focusableElements[currentIndex].nearestBottom == nil || currentIndex == 0 {
            
            forwardLoop : while position(to: focusableElements[currentIndex].thisElement, of: focusableElements[forwardIndex].thisElement) != .down {
                if currentIndex == 0 {
                    focusableElements[forwardIndex].nearestTop = EdgeElement.shared
                }
                
                forwardIndex += 1
                
                if forwardIndex > (focusableElements.count - 1) {
                    break forwardLoop
                }
                
            }
            
            if forwardIndex == (focusableElements.count - 1) && position(to: focusableElements[currentIndex].thisElement, of: focusableElements[forwardIndex].thisElement) != .down {
                focusableElements[currentIndex].nearestBottom = EdgeElement.shared
            } else if forwardIndex <= (focusableElements.count - 1) {
                
                if checkIfNearest(newElement: focusableElements[currentIndex].thisElement,
                                  toCurrentNearestElement: focusableElements[forwardIndex].nearestTop,
                                  inDirection: .up,
                                  ofElement: focusableElements[forwardIndex].thisElement) {
                    focusableElements[forwardIndex].nearestTop = focusableElements[currentIndex].thisElement
                }
                if checkIfNearest(newElement: focusableElements[forwardIndex].thisElement,
                                  toCurrentNearestElement: focusableElements[currentIndex].nearestBottom,
                                  inDirection: .down,
                                  ofElement: focusableElements[currentIndex].thisElement) {
                    focusableElements[currentIndex].nearestBottom = focusableElements[forwardIndex].thisElement
                }
            }
            
            if forwardIndex < (focusableElements.count - 1) {
                 checkIfLowerIndex = forwardIndex + 1
                innerLoop : while position(to: focusableElements[forwardIndex].thisElement, of: focusableElements[checkIfLowerIndex].thisElement) != .down {
                    if checkIfNearest(newElement: focusableElements[checkIfLowerIndex].thisElement,
                                      toCurrentNearestElement: focusableElements[currentIndex].nearestBottom,
                                      inDirection: .down, ofElement: focusableElements[currentIndex].thisElement) {
                        focusableElements[currentIndex].nearestBottom = focusableElements[checkIfLowerIndex].thisElement
                    }
                    if checkIfNearest(newElement: focusableElements[currentIndex].thisElement, toCurrentNearestElement: focusableElements[checkIfLowerIndex].nearestTop, inDirection: .up, ofElement:  focusableElements[checkIfLowerIndex].thisElement) {
                        focusableElements[checkIfLowerIndex].nearestTop = focusableElements[currentIndex].thisElement
                    }
                    checkIfLowerIndex += 1
                    
                    if checkIfLowerIndex == focusableElements.count {
                        break innerLoop
                    }
                    
                }
                
            }
            
            currentIndex += 1
            forwardIndex = currentIndex + 1
            
        }
        
        
        
        
        sortElementsHorizontally()
        
        
        //After elements are sorted horizontally the strategy of finding nearest one is other then for finding nearest Vertically as elements located diagonally - are located vertically, not horizontally, which leads to element which is located first in the array cannot have element to the right and next to it - may have.
        
        focusableElements[0].nearestLeft = EdgeElement.shared
        focusableElements[focusableElements.count-1].nearestRight = EdgeElement.shared
        
        for i in 0..<(focusableElements.count-1) {
            var hasRight = false
            innerLoop : for j in i+1..<focusableElements.count {
                if position(to: focusableElements[i].thisElement, of: focusableElements[j].thisElement) == .right {
                    hasRight = true
                    if checkIfNearest(newElement: focusableElements[j].thisElement, toCurrentNearestElement: focusableElements[i].nearestRight, inDirection: .right, ofElement: focusableElements[i].thisElement) {
                        focusableElements[i].nearestRight = focusableElements[j].thisElement
                    }
                    if checkIfNearest(newElement: focusableElements[i].thisElement, toCurrentNearestElement: focusableElements[j].nearestLeft, inDirection: .left, ofElement: focusableElements[j].thisElement) {
                        focusableElements[j].nearestLeft = focusableElements[i].thisElement
                    }
                    
                    if j < focusableElements.count - 1 {
                        var extraCheckIndex = j+1
                        extraCheckLoop : while focusableElements[extraCheckIndex].thisElement.globalFrame.minX == focusableElements[j].thisElement.globalFrame.minX
                                                &&
                                                position(to: focusableElements[i].thisElement, of: focusableElements[extraCheckIndex].thisElement) == .right {
                            if checkIfNearest(newElement: focusableElements[extraCheckIndex].thisElement, toCurrentNearestElement: focusableElements[i].nearestRight, inDirection: .right, ofElement: focusableElements[i].thisElement) {
                                focusableElements[i].nearestRight = focusableElements[extraCheckIndex].thisElement
                            }
                            if checkIfNearest(newElement: focusableElements[i].thisElement, toCurrentNearestElement: focusableElements[extraCheckIndex].nearestLeft, inDirection: .left, ofElement: focusableElements[extraCheckIndex].thisElement) {
                                focusableElements[extraCheckIndex].nearestLeft = focusableElements[i].thisElement
                            }
                            
                            extraCheckIndex += 1
                            
                            if extraCheckIndex > focusableElements.count - 1 {
                                break extraCheckLoop
                            }
                        }
                    }
                    
                    break innerLoop
                }
            }
            if !hasRight {
                focusableElements[i].nearestRight = EdgeElement.shared
            }
        }
        
        for i in 1..<focusableElements.count {
            if focusableElements[i].nearestLeft == nil {
                focusableElements[i].nearestLeft = EdgeElement.shared
            }
        }
        
    }

    
    
    
    //MARK: - Extra helpful functions
    
    
    //Function that sorts elements horizontally
    private func sortElementsHorizontally() {
        self.focusableElements.sort(by: {element1, element2 in
            if element1.thisElement.globalFrame.minX != element2.thisElement.globalFrame.minX {
                return element1.thisElement.globalFrame.minX < element2.thisElement.globalFrame.minX
            } else {
                return element1.thisElement.globalFrame.maxY < element2.thisElement.globalFrame.maxY
            }
        })
    }
    
    //Function that sorts elements vertically
    private func sortElementsVertically() {
        self.focusableElements.sort(by: {element1, element2 in
            if element1.thisElement.globalFrame.minY != element2.thisElement.globalFrame.minY {
                return element1.thisElement.globalFrame.minY < element2.thisElement.globalFrame.minY
            } else {
                return element1.thisElement.globalFrame.maxX < element2.thisElement.globalFrame.maxX
            }
        })
    }
    
    //Function that determines the position of one element in relation to another
    private func position(to currentElement : Focusable, of nearestElement : Focusable) -> FocusDirection {
        if currentElement.globalFrame.maxY <= nearestElement.globalFrame.minY {
            return .down
        } else if currentElement.globalFrame.minY >= nearestElement.globalFrame.maxY {
            return .up
        } else if currentElement.globalFrame.maxX <= nearestElement.globalFrame.minX {
            return .right
        } else {
            return .left
        }
        
    }
    
    //Function that checks whether new element is closer to another element at a particular direction
    private func checkIfNearest(newElement : Focusable, toCurrentNearestElement currentNearest : Focusable?, inDirection direction : FocusDirection, ofElement currentElement : Focusable) -> Bool {
        guard let currentNearest = currentNearest else {
            return true
        }
        
        guard currentNearest.name != EdgeElement.shared.name else {
            return false
        }
        
        switch direction {
            case .right :
                if newElement.globalFrame.minX < currentNearest.globalFrame.minX {
                    return true
                } else if newElement.globalFrame.minX > currentNearest.globalFrame.minX {
                    return false
                } else if
                    CGPointDistance(from: CGPoint(x: currentElement.globalFrame.maxX, y: currentElement.globalFrame.minY),
                                    to: CGPoint(x: newElement.globalFrame.minX, y: newElement.globalFrame.midY))
                        <=
                        CGPointDistance(from: CGPoint(x: currentElement.globalFrame.maxX, y: currentElement.globalFrame.minY),
                                        to: CGPoint(x: currentNearest.globalFrame.minX, y: currentNearest.globalFrame.midY))
                {
                    return true
                } else {
                    return false
                }
            case .left :
                if newElement.globalFrame.maxX > currentNearest.globalFrame.maxX {
                    return true
                } else if newElement.globalFrame.maxX < currentNearest.globalFrame.maxX {
                    return false
                } else if
                    CGPointDistance(from: CGPoint(x: currentElement.globalFrame.minX, y: currentElement.globalFrame.minY),
                                    to: CGPoint(x: newElement.globalFrame.maxX, y: newElement.globalFrame.midY))
                        <=
                        CGPointDistance(from: CGPoint(x: currentElement.globalFrame.minX, y: currentElement.globalFrame.minY),
                                        to: CGPoint(x: currentNearest.globalFrame.maxX, y: currentNearest.globalFrame.midY))
                {
                    return true
                } else {
                    return false
                }
            case .down :
                if newElement.globalFrame.minY < currentNearest.globalFrame.minY {
                    return true
                } else if newElement.globalFrame.minY > currentNearest.globalFrame.minY {
                    return false
                } else if
                    CGPointDistance(from: CGPoint(x: currentElement.globalFrame.minX, y: currentElement.globalFrame.maxY),
                                    to: CGPoint(x: newElement.globalFrame.midX, y: newElement.globalFrame.minY))
                        <=
                        CGPointDistance(from: CGPoint(x: currentElement.globalFrame.minX, y: currentElement.globalFrame.maxY),
                                        to: CGPoint(x: currentNearest.globalFrame.midX, y: currentNearest.globalFrame.minY))
                {
                    return true
                } else {
                    return false
                }
            case .up :
                if newElement.globalFrame.maxY > currentNearest.globalFrame.maxY {
                    return true
                } else if newElement.globalFrame.maxY < currentNearest.globalFrame.maxY {
                    return false
                } else if
                    CGPointDistance(from: CGPoint(x: currentElement.globalFrame.minX, y: currentElement.globalFrame.minY),
                                    to: CGPoint(x: newElement.globalFrame.midX, y: newElement.globalFrame.maxY))
                        <=
                        CGPointDistance(from: CGPoint(x: currentElement.globalFrame.minX, y: currentElement.globalFrame.minY),
                                        to: CGPoint(x: currentNearest.globalFrame.midX, y: currentNearest.globalFrame.maxY))
                {
                    return true
                } else {
                    return false
                }
        }
        
    }
    
    
    // Functions that calculate distance between CGPoints
    private func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }

    private func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }
    
}

// Enum which contain all possible directions to move using controller
internal enum FocusDirection {
    case up
    case down
    case left
    case right

}

// Class which contains information about focusable element and its nearest neighbours at four different directions
private final class FocusableElement {
  
    var thisElement : Focusable
    var nearestRight : Focusable? = nil
    var nearestLeft : Focusable? = nil
    var nearestBottom : Focusable? = nil
    var nearestTop : Focusable? = nil

    init(element : Focusable) {
        self.thisElement = element
    }
    
}
