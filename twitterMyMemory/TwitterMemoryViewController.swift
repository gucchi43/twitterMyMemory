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
    
    @IBOutlet weak var yearView: UIView!
    @IBOutlet weak var yearLabel: UILabel!
    
    var dateArray = [Date]()
    var imageArray = [String]()
    var memoryArray = [Date : String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self

        yearView.layer.cornerRadius = 4
        yearView.clipsToBounds = true
        yearLabel.text = String(memoryArray.keys.first!.year) + "/" + String(memoryArray.keys.first!.month)
        setMonthColor(month: memoryArray.keys.first!.month)
        
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setMonthColor(month : Int) {
        switch month {
        case 1:
            collectionView.backgroundColor = #colorLiteral(red: 0.8446564078, green: 0.5145705342, blue: 1, alpha: 1)
        case 2:
            collectionView.backgroundColor = #colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1)
        case 3:
            collectionView.backgroundColor = #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1)
        case 4:
            collectionView.backgroundColor = #colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)
        case 5:
            collectionView.backgroundColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
        case 6:
            collectionView.backgroundColor = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1)
        case 7:
            collectionView.backgroundColor = #colorLiteral(red: 0.8321695924, green: 0.985483706, blue: 0.4733308554, alpha: 1)
        case 8:
            collectionView.backgroundColor = #colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1)
        case 9:
            collectionView.backgroundColor = #colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1)
        case 10:
            collectionView.backgroundColor = #colorLiteral(red: 0.4513868093, green: 0.9930960536, blue: 1, alpha: 1)
        case 11:
            collectionView.backgroundColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)
        case 12:
            collectionView.backgroundColor = #colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1)
        default:
            collectionView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
}

extension TwitterMemoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let photoCell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        photoCell.photoYearView.layer.cornerRadius = 4
        let date = Array(memoryArray.keys)[indexPath.row]
        photoCell.photoMonthLabel.text = String(date.day)
        photoCell.photoYearLabel.text = date.shortMonthName
//        photoCell.photoDateLabel.text = date.string()
        let imageUrl = Array(memoryArray.values)[indexPath.row]
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
        let count = memoryArray.count
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
