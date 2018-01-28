//
//  TwitterMemoryViewController.swift
//  twitterMyMemory
//
//  Created by Hiroki Taniguchi on 2018/01/28.
//  Copyright © 2018年 Hiroki Taniguchi. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class TwitterMemoryViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var dateArray = [String]()
    var imageArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TwitterMemoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let photoCell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        let date = dateArray[indexPath.row]
        photoCell.photoDateLabel.text = date
        let imageUrl = imageArray[indexPath.row]
        print("imageUrl", imageUrl)
        let req = request(imageUrl)
        req.responseData { (response) in
            if response.result.isSuccess == true {
                print("success", response.result.description)
                if let data = response.result.value {
                    DispatchQueue.main.async {
                        photoCell.photoImageView.image = UIImage(data: data)
                    }
                }
            } else {
                print("error", response.result.description)
            }
        }
        return photoCell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let count = imageArray.count
        print("コレクション数", count)
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize:CGFloat = self.view.bounds.width/2 - 2
        return CGSize(width: cellSize, height: cellSize)
    }
}
