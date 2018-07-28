//
//  VideoLauncher.swift
//  Eventful
//
//  Created by Shawn Miller on 8/22/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit




class VideoLauncher: UIView{
    
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func showVideoPlayer (){
        print("Showing VIdeo PlaYER")
     
           let view = UIView()
            let height = view.frame.width * 9/16
            let videoPlayerFrame = CGRect(x: 0, y: 50, width: view.frame.width, height: height)
            let videoPlayerView = VideoLauncher(frame: videoPlayerFrame)
            view.addSubview(videoPlayerView)
        
    }
    
}
