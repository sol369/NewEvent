//
//  StorageService.swift
//  Eventful
//
//  Created by Shawn Miller on 8/20/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

struct StorageService
{
    //provide method for uploading images// class method that will help us upload images to Firebase storage.
    static func uploadImage(_ image: UIImage, at reference: StorageReference, completion: @escaping (URL?) -> Void)
    {
        // 1
        //First we change the image from an UIImage to Data and reduce the quality of the image.
        //It is important to reduce the quality of the image because otherwise the images will take a long time to upload and download from Firebase Storage. If we can't convert image to data, we return nil to the completion callback to signal something went wrong
        guard let imageData = UIImageJPEGRepresentation(image, 0.1) else {
            return completion(nil)
        }
        
        // 2
        //We upload our media data to the path provided as a parameter
        reference.putData(imageData, metadata: nil, completion: { (metadata, error) in
            // 3
            //After upload completes, we checl of there was an error. Our assertFailure will crash the app and print the error when were running in debug mode
            if let error = error
            {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            // 4
            //If everything was succesful, we return the download URL for the image
            
            reference.downloadURL(completion: { (downloadURL, err) in
                guard let profileImageUrl = downloadURL?.absoluteString else { return }
                completion(URL(string: profileImageUrl))

            })
            
        })
    }
    
    // Upload videos
    static func uploadVideo(_ video: URL, at reference: StorageReference, completion: @escaping (URL?) -> Void)
    {
        reference.putFile(from: video, metadata: nil, completion: { (metadata, error) in
            
            if let error = error
            {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }
            
            reference.downloadURL(completion: { (downloadURL, err) in
                guard let videoURL = downloadURL?.absoluteString else { return }
                completion(URL(string: videoURL))
                
            })
        })
    }
    
}
