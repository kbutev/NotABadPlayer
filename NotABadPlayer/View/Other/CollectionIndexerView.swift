//
//  CollectionIndexerView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 23.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol CollectionIndexerDelegate : class {
    func onTouchGestureBegin(selection: CollectionIndexerSelection)
    func onTouchGestureMove(selection: CollectionIndexerSelection)
    func onTouchGestureEnd(selection: CollectionIndexerSelection)
}

struct CollectionIndexerSelection {
    let character: Character
    let index: UInt
    
    init(character: Character, index: Int) {
        self.character = character
        self.index = UInt(index)
    }
    
    public func rowIndex(columns: UInt) -> UInt {
        let indexAsFloat = CGFloat(index)
        let columnsAsFloat = CGFloat(columns)
        return UInt((indexAsFloat / columnsAsFloat).rounded(.up))
    }
}

class CollectionIndexerView : UIView
{
    public static let TEXT_FONT = UIFont.systemFont(ofSize: 18)
    public static let ALPHABET_CAPACITY = 24
    public weak var delegate: CollectionIndexerDelegate?
    
    private (set) var selection: CollectionIndexerSelection?
    
    private (set) var previousSelection: CollectionIndexerSelection?
    
    private var spacing: CGFloat = 0
    
    private var characterLabels: [UILabel] = []
    
    private var fullAlphabet: [Character] = []
    private var alphabet: [Character] = []
    
    private var panGesture: UIPanGestureRecognizer?
    private var tapGesture: UITapGestureRecognizer?
    private var longPressGesture: UILongPressGestureRecognizer?
    
    convenience init(spacing: Float) {
        self.init(frame: .zero)
        self.spacing = CGFloat(spacing)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(actionGestureEvent(recognizer:)))
        self.panGesture = panGesture
        addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionGestureEvent(recognizer:)))
        self.tapGesture = tapGesture
        addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(actionGestureEvent(recognizer:)))
        longPressGesture.minimumPressDuration = 0.01
        self.longPressGesture = longPressGesture
        addGestureRecognizer(longPressGesture)
    }
    
    override func layoutSubviews() {
        let width = self.frame.width
        let height = self.frame.height
        let labelsCount = CGFloat(characterLabels.count)
        
        let labelSize = CGSize(width: width, height: height / labelsCount)
        
        var currentPositionY: CGFloat = 0
        
        // order the views
        for label in self.characterLabels
        {
            label.frame.origin = CGPoint(x: 0, y: currentPositionY)
            label.frame.size = labelSize
            
            currentPositionY += label.frame.height + spacing
        }
    }
    
    private func removeLabels() {
        for label in self.characterLabels
        {
            label.removeFromSuperview()
        }
        
        self.characterLabels = []
    }
    
    private func rebuildLabels() {
        removeLabels()
        buildLabels()
    }
    
    private func buildLabels() {
        let textColor = AppTheme.shared.colorFor(.INDEXER_CHAR_COLOR)
        
        for i in 0..<alphabet.count
        {
            let label = UILabel()
            label.text = String(alphabet[i])
            
            label.font = CollectionIndexerView.TEXT_FONT
            label.textColor = textColor
            label.textAlignment = .center
            
            self.characterLabels.append(label)
            
            self.addSubview(label)
        }
    }
    
    private func updateSelectedCharacter(location: CGPoint) -> Bool {
        guard characterLabels.count > 0 else {
            return false
        }
        
        var characterTappedOn: Character? = nil
        
        // What did we click on? Get the character of the label
        for e in 0..<characterLabels.count
        {
            let label = characterLabels[e]
            
            guard location.y >= label.frame.minY && location.y <= label.frame.maxY else {
                continue
            }
            
            if location.y >= label.frame.minY && location.y <= label.frame.maxY
            {
                characterTappedOn = self.alphabet[e]
                
                break
            }
        }
        
        guard let char = characterTappedOn else {
            return false
        }
        
        // Retrieve the first matching item for the character of the label we clicked on
        if let exactItemIndex = self.fullAlphabet.index(of: char)
        {
            self.selection = CollectionIndexerSelection(character: char, index: exactItemIndex)
            return true
        }
        
        return false
    }
    
    private func onTouchGestureBegin(_ recognizer: UIGestureRecognizer) {
        let _ = self.updateSelectedCharacter(location: recognizer.location(in: self))
        
        if let selection = self.selection
        {
            delegate?.onTouchGestureBegin(selection: selection)
        }
    }
    
    private func onTouchGestureMove(_ recognizer: UIGestureRecognizer) {
        let didChange = self.updateSelectedCharacter(location: recognizer.location(in: self))
        
        guard didChange else {
            return
        }
        
        if let selection = self.selection
        {
            delegate?.onTouchGestureMove(selection: selection)
        }
    }
    
    private func onTouchGestureEnd(_ recognizer: UIGestureRecognizer) {
        if let selection = self.selection
        {
            delegate?.onTouchGestureEnd(selection: selection)
        }
    }
    
}

// Alphabet
extension CollectionIndexerView {
    public func setAlphabet(_ strings: [String]) {
        var fullAlphabet: [Character] = []
        var alphabet: [Character] = []
        
        for title in strings
        {
            if title.count == 0
            {
                continue
            }
            
            let firstChar = title.uppercased()[title.startIndex]
            
            if !alphabet.contains(firstChar)
            {
                alphabet.append(firstChar)
            }
            
            fullAlphabet.append(firstChar)
            
            if alphabet.count >= CollectionIndexerView.ALPHABET_CAPACITY
            {
                break
            }
        }
        
        self.alphabet = alphabet.sorted { $0 < $1 }
        self.fullAlphabet = fullAlphabet.sorted { $0 < $1 }
        
        rebuildLabels()
        layoutIfNeeded()
    }
}

// Actions
extension CollectionIndexerView {
    @objc func actionGestureEvent(recognizer: UIGestureRecognizer) {
        switch recognizer.state
        {
        case .began:
            onTouchGestureBegin(recognizer)
            break
        case .ended:
            onTouchGestureEnd(recognizer)
            break
        default:
            onTouchGestureMove(recognizer)
            break
        }
    }
}
