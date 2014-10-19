//
//  Helpers.swift
//  SeaFoamClient
//
//  Created by Kevin Sullivan on 10/19/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import Foundation
import UIKit

// Takes a UIElement jiggles it back and forth
func jiggle(element: UIControl) {
    let originalFrame = element.frame
    let originalOrigin = originalFrame.origin
    let frameLeft = CGRect(x: originalOrigin.x - 10, y: originalOrigin.y, width: originalFrame.width, height: originalFrame.height)
    let frameRight = CGRect(x: originalOrigin.x + 10, y: originalOrigin.y, width: originalFrame.width, height: originalFrame.height)
    
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        element.frame = frameRight
        }, completion: nil)
    
    UIView.animateWithDuration(0.1, delay: 0.1, options: UIViewAnimationOptions.CurveLinear, animations: {
        element.frame = frameLeft
        }, completion: nil)
    
    UIView.animateWithDuration(0.1, delay: 0.2, options: UIViewAnimationOptions.CurveLinear, animations: {
        element.frame = frameRight
        }, completion: nil)
    
    UIView.animateWithDuration(0.1, delay: 0.3, options: UIViewAnimationOptions.CurveLinear, animations: {
        element.frame = frameLeft
        }, completion: nil)
    
    UIView.animateWithDuration(0.1, delay: 0.4, options: UIViewAnimationOptions.CurveLinear, animations: {
        element.frame = frameRight
        }, completion: nil)
    
    UIView.animateWithDuration(0.1, delay: 0.5, options: UIViewAnimationOptions.CurveLinear, animations: {
        element.frame = originalFrame
        }, completion: nil)
}