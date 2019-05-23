//
//  CollectionIndexerView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 23.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

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
}

class CollectionIndexerView : UIView
{
    public static let TEXT_FONT = UIFont.systemFont(ofSize: 18)
    public static let TEXT_COLOR = UIColor.black
    public static let TEXT_ALPHA: CGFloat = 0.6
    
    public weak var delegate: CollectionIndexerDelegate?
    
    private (set) var selection: CollectionIndexerSelection?
    
    private (set) var previousSelection: CollectionIndexerSelection?
    
    private var spacing: CGFloat = 0
    
    private var characterLabels: [UILabel] = []
    
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
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onGestureEvent(recognizer:)))
        self.panGesture = panGesture
        addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onGestureEvent(recognizer:)))
        self.tapGesture = tapGesture
        addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onGestureEvent(recognizer:)))
        longPressGesture.minimumPressDuration = 0.01
        self.longPressGesture = longPressGesture
        addGestureRecognizer(longPressGesture)
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
        for i in 0..<alphabet.count
        {
            let label = UILabel()
            label.text = String(alphabet[i])
            
            label.font = CollectionIndexerView.TEXT_FONT
            label.textColor = CollectionIndexerView.TEXT_COLOR
            label.alpha = CollectionIndexerView.TEXT_ALPHA
            label.textAlignment = .center
            
            self.characterLabels.append(label)
            
            self.addSubview(label)
        }
    }
    
    @objc func onGestureEvent(recognizer: UIGestureRecognizer) {
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
    
    private func updateSelectedCharacter(location: CGPoint) -> Bool {
        for e in 0..<self.characterLabels.count
        {
            let label = self.characterLabels[e]
            
            guard location.y >= label.frame.minY && location.y <= label.frame.maxY else {
                continue
            }
            
            if location.y >= label.frame.minY && location.y <= label.frame.maxY
            {
                if let currentSelection = self.selection
                {
                    if currentSelection.character != alphabet[e]
                    {
                        previousSelection = self.selection
                        self.selection = CollectionIndexerSelection(character: alphabet[e], index: e)
                        return true
                    }
                }
                else
                {
                    self.selection = CollectionIndexerSelection(character: alphabet[e], index: e)
                    return true
                }
                
                break
            }
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
    
    func updateAlphabet(strings: [String]) {
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
        }
        
        self.alphabet = alphabet.sorted { $0 < $1 }
        
        self.alphabet = ["A", "B", "c", "d", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "e", "E"]
        
        rebuildLabels()
        layoutIfNeeded()
    }
}
