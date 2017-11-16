//
//  RadioBarView.swift
//  Zonky Stats
//
//  Created by lgergel on 15/11/2017.
//  Copyright © 2017 Lukas Gergel. All rights reserved.
//

import Foundation
import UIKit

protocol RadioBarSelectionChanged: class {
    func selectionChanged(_ button: UIButton?, index: Int)
}

class RadioBarView: UIStackView {
    
    var selectionChanged: RadioBarSelectionChanged?
    
    public func setSelectionChangedHandler(handler: RadioBarSelectionChanged) {
        self.selectionChanged = handler
    }
    
    public func selectItem(index: Int){
        if self.subviews.count > index {
            for (i, btn) in (self.subviews as! [UIButton]).enumerated() {
                if (i == index){
                    btn.isSelected = true
                } else {
                    btn.isSelected = false
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.selectButton(touches)
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.selectButton(touches)
        super.touchesMoved(touches, with: event)
    }
    
    func selectButton(_ touches: Set<UITouch>){
        if let touch = touches.first {
            for (i, btn) in (self.subviews as! [UIButton]).enumerated() {
                let point = touch.location(in: self)
                if (btn.frame.contains(point)) {
                    btn.isSelected = true
                    if let handler = selectionChanged {
                        handler.selectionChanged(btn, index: i)
                    }
                } else {
                    btn.isSelected = false
                }
            }
        }
    }
}
