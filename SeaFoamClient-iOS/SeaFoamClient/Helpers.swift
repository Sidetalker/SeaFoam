//
//  Helpers.swift
//  SeaFoamClient
//
//  Created by Kevin Sullivan on 10/19/14.
//  Copyright (c) 2014 SideApps. All rights reserved.
//

import UIKit

// Takes a UIControl jiggles it back and forth
func jiggle(element: UIControl, count: Int, distance: CGFloat) {
    // Save variables for frame offset calculation
    let originalFrame = element.frame
    let constantSize = originalFrame.size
    let originalOrigin = originalFrame.origin
    let leftOrigin = originalOrigin.x - distance
    let rightOrigin = originalOrigin.x + distance
    
    // Calculate frame offsets
    let frameLeft = CGRect(origin: CGPoint(x: leftOrigin, y: originalOrigin.y), size: constantSize)
    let frameRight = CGRect(origin: CGPoint(x: rightOrigin, y: originalOrigin.y), size: constantSize)
    
    // Perform "count" shakes
    for x in 0...count {
        let delay = Double(x) / Double(count) / 2
        var destinationFrame = CGRect()
        
        if x == count { destinationFrame = originalFrame } // Restore original frame in last loop
        else if x % 2 == 0 { destinationFrame = frameRight } // Jiggle right on evens
        else { destinationFrame = frameLeft } // Jiggle left on odds
        
        // Fire the animation block
        UIView.animateWithDuration(0.1, delay: delay, options: UIViewAnimationOptions.CurveLinear, animations: {
            // Update the element's frame
            element.frame = destinationFrame
            }, completion: nil)
    }
}