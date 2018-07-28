//  SegmentedProgressBar.swift
//  SegmentedProgressBar
//
//  Created by Dylan Marriott on 04.03.17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.
//
import Foundation
import UIKit

protocol SegmentedProgressBarDelegate: class {
    func segmentedProgressBarChangedIndex(index: Int)
    func segmentedProgressBarFinished()
}

class SegmentedProgressBar: UIView {
    
    weak var delegate: SegmentedProgressBarDelegate?
    
    var durations = [TimeInterval]()
    
    public var topColor = UIColor.lightGray {
        didSet {
            self.updateColors()
        }
    }
    var bottomColor = UIColor.lightGray.withAlphaComponent(0.3) {
        didSet {
            self.updateColors()
        }
    }
    var padding: CGFloat = 2.0
    
    var isPaused: Bool = false {
        didSet {
            if isPaused {
                for segment in segments {
                    let layer = segment.topSegmentView.layer
                    let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
                    layer.speed = 0.0
                    layer.timeOffset = pausedTime
                }
            } else {
                let segment = segments[currentAnimationIndex]
                let layer = segment.topSegmentView.layer
                let pausedTime = layer.timeOffset
                layer.speed = 1.0
                layer.timeOffset = 0.0
                layer.beginTime = 0.0
                let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                layer.beginTime = timeSincePause
            }
        }
    }
    
    private var segments = [Segment]()
    public var duration: TimeInterval
    private var hasDoneLayout = false // hacky way to prevent layouting again
    
    
    public var currentAnimationIndex = 0
    public var savedIndex = 0
    
    init(numberOfSegments: Int, duration: TimeInterval = 5.0) {
        self.duration = duration
        super.init(frame: CGRect.zero)
        
        for _ in 0..<numberOfSegments {
            let segment = Segment()
            addSubview(segment.bottomSegmentView)
            addSubview(segment.topSegmentView)
            segments.append(segment)
        }
        self.updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if hasDoneLayout {
            return
        }
        let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
        for (index, segment) in segments.enumerated() {
            let segFrame = CGRect(x: CGFloat(index) * (width + padding), y: 0, width: width, height: frame.height / 2)
            segment.bottomSegmentView.frame = segFrame
            segment.topSegmentView.frame = segFrame
            segment.topSegmentView.frame.size.width = 0
            
            let cr = frame.height / 2
            segment.bottomSegmentView.layer.cornerRadius = cr
            segment.topSegmentView.layer.cornerRadius = cr
            
            if index < savedIndex {
                segment.topSegmentView.frame.size.width = segment.bottomSegmentView.frame.width
            }
            
            
            
        }
        hasDoneLayout = true
    }
    
    func startAnimation() {
        layoutSubviews()
        animate()
    }
    
    func startAnimationAt(index: Int) {
        //layoutSubviews()
        animate(animationIndex: index)
    }
    
    private func animate(animationIndex: Int = 0) {
        let nextSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
        //self.isPaused = false // no idea why we have to do this here, but it fixes everything :D
        
        //durations[animationIndex]
        //duration
        
        UIView.animate(withDuration: durations[animationIndex], delay: 0.0, options: .curveLinear, animations: {
            nextSegment.topSegmentView.frame.size.width = nextSegment.bottomSegmentView.frame.width
            
        }) { (finished) in
            if !finished {
                return
            }
            
            self.next()
        }
        
        
        
        
    }
    
    private func updateColors() {
        for segment in segments {
            segment.topSegmentView.backgroundColor = topColor
            segment.bottomSegmentView.backgroundColor = bottomColor
        }
    }
    
    private func next() {
        
        if !isPaused {
            let newIndex = self.currentAnimationIndex + 1
            if newIndex < self.segments.count {
                self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
                self.animate(animationIndex: newIndex)
            } else {
                self.delegate?.segmentedProgressBarFinished()
            }
        }
        
    }
    
    func skip() {
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.frame.size.width = currentSegment.bottomSegmentView.frame.width
        currentSegment.topSegmentView.layer.removeAllAnimations()
        self.next()
    }
    
    func skipBars(number: Int) {
        for i in 0...number {
            let currentSegment = segments[i]
            currentSegment.topSegmentView.frame.size.width = currentSegment.bottomSegmentView.frame.width
            currentSegment.topSegmentView.layer.removeAllAnimations()
        }
        
        currentAnimationIndex += number
        
    }
    
    func rewind() {
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.layer.removeAllAnimations()
        currentSegment.topSegmentView.frame.size.width = 0
        let newIndex = max(currentAnimationIndex - 1, 0)
        let prevSegment = segments[newIndex]
        prevSegment.topSegmentView.frame.size.width = 0
        self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
        self.animate(animationIndex: newIndex)
    }
    
    func reset() {
        for segment in segments {
            segment.topSegmentView.layer.removeAllAnimations()
            segment.topSegmentView.frame.size.width = 0
        }
        currentAnimationIndex = 0
        self.delegate?.segmentedProgressBarChangedIndex(index: 0)
        self.animate(animationIndex: 0)
    }
    
}

fileprivate class Segment {
    let bottomSegmentView = UIView()
    let topSegmentView = UIView()
    init() {
    }
}
