//
//  PhotoLibraryViewController.swift
//  Slow Motion Camera Swift
//
//  Created by Chad Wiedemann on 10/17/16.
//  Copyright © 2016 Chad Wiedemann. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import QuartzCore
import MobileCoreServices

private let reuseIdentifier = "Cell"

class PhotoLibraryViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var URLArray1 : NSMutableArray = []
    var thumbNailArray : NSMutableArray = []
    var URLArray : NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.URLArray1.count != 0{
            self.createArrayOfImages()
            self.collectionView?.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.URLArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let imageView = UIImageView(image: self.thumbNailArray.object(at: indexPath.row) as? UIImage)
        cell.backgroundView = imageView
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let playerVC: VideoPlayerViewController = sb.instantiateViewController(withIdentifier: "VideoPlayerVC") as! VideoPlayerViewController
        playerVC.videoURLString = self.URLArray.object(at: indexPath.row) as? String
        self.navigationController?.pushViewController(playerVC, animated: true)
        return true
    }
    
    @IBAction func recordVideoButton(_ sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.videoQuality = .typeMedium
        imagePicker.videoMaximumDuration = 30.0
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //save video in documents directory
        let videoURL = info[UIImagePickerControllerMediaURL] as! NSURL
        let videoData = NSData(contentsOf: videoURL as URL)
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: AnyObject = paths[0] as AnyObject
        //get time stamp
        let date = NSDate()
        let timeSince = floor(date.timeIntervalSince1970)
        let str:String = String(format: "%.0f", timeSince)
        let path = String(format: "/vid%@.mp4", str)
        let dataPath = documentsDirectory.appending(path)
        videoData?.write(toFile: dataPath, atomically: false)
        let word:String = String(format: "/private%@", dataPath)
        //saves the URLs for the images that were saved in the dcouments directy in nsuser defaults
        let appDefaults = UserDefaults()
        if (appDefaults .object(forKey: "URLs") != nil){
            let tempArray = appDefaults.object(forKey: "URLs") as! NSArray
            self.URLArray1 = tempArray.mutableCopy() as! NSMutableArray
            self.URLArray1.add(word)
            appDefaults.set(self.URLArray1.copy(), forKey: "URLs")
        }else{
            self.URLArray1.add(word)
            appDefaults.set(self.URLArray1.copy(), forKey: "URLs")
        }
        appDefaults.synchronize()
        self.collectionView?.reloadData()
        self.dismiss(animated: true, completion: nil)
    }
    
    func createThumbnail(URLString:String) -> UIImage {
        let testURL = URL(fileURLWithPath: URLString)
        let asset = AVURLAsset(url: testURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(1.0, 1)
        var actualTime : CMTime = CMTimeMake(0,0)
        var thumbnail : CGImage?
        do{
            thumbnail = try generator.copyCGImage(at: time, actualTime: &actualTime)
        }
        catch let error as NSError{
            print(error.localizedDescription)
        }
        let image = UIImage(cgImage: thumbnail!)
        return image
    }
    
    func createArrayOfImages() -> Void {
        let appDefaults = UserDefaults()
        let tempArray = appDefaults.object(forKey: "URLs") as! NSArray
        self.URLArray = tempArray.mutableCopy() as! NSMutableArray
        self.thumbNailArray.removeAllObjects()
        for s in self.URLArray {
            let tempImage: UIImage = self.createThumbnail(URLString: s as! String)
            self.thumbNailArray.add(tempImage)
        }
    }

}
