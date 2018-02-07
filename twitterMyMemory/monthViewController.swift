
//
//  monthViewController.swift
//  twitterMyMemory
//
//  Created by Hiroki Taniguchi on 2018/01/29.
//  Copyright © 2018年 Hiroki Taniguchi. All rights reserved.
//

import UIKit

class monthViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var dateArray = [Date]()
    var imageArray = [String]()
    var memoryArray = [Date : String]()
    var monthsMemoryArray = [Int : [Date : String]]()
    var yearAndMonthArray = [Int]()
    var currentMonthKey : Int?
    var loadNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        
        print("memoryArray", memoryArray)
        
        self.getMonthsMemoryArray()
        self.sortMonthsMemoryArray()
        self.getFirstMonthMemory()
        
        let vc = self.getViewController()
        self.setViewControllers([vc], direction: .forward, animated: false)
    }
    
    func getViewController () -> UIViewController {
        let twitterMemoryViewController = storyboard!.instantiateViewController(withIdentifier: "TwitterMemoryViewController") as! TwitterMemoryViewController
        let currentMemory = monthsMemoryArray[currentMonthKey!]
        twitterMemoryViewController.memoryArray = currentMemory!
        return twitterMemoryViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        getNextMonthMemory(pageFlag: false)
        
        return self.getViewController()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        getNextMonthMemory(pageFlag: true)
        
        return self.getViewController()
    }
    
    func getMonthsMemoryArray() {
        for (key, value) in memoryArray {
            self.loadNumber += 1
            print("何周目/合計", String(loadNumber) + "/" + String(memoryArray.count))

            
            let monthKey = key.year * 100 + key.month
            print("monthsMemoryArray" , monthsMemoryArray)
            if var monthValue = monthsMemoryArray[monthKey] {
                print("monthValue1", monthValue)
                print("[key : value]", [key : value])
                monthValue[key] = value
                print("monthValue2", monthValue)
                monthsMemoryArray[monthKey] = monthValue
            } else {
                monthsMemoryArray[monthKey] = [key : value]
            }
        }
    }
    
    func getFirstMonthMemory() {
        let firstKey = yearAndMonthArray.last!
        if let monthMemory = monthsMemoryArray[firstKey] {
            monthMemory.sorted(by: {$0.0 < $1.0})
            self.currentMonthKey = firstKey
        }
    }
    
    func getNextMonthMemory(pageFlag: Bool) {
        if let currentMonthKey = currentMonthKey {
            var nextMonthKey : Int?
            var indexNumber = yearAndMonthArray.index(of: currentMonthKey)
            if pageFlag == true {
                print("左スワイプ")
                if indexNumber == yearAndMonthArray.count - 1 {
                    nextMonthKey = yearAndMonthArray[0]
                } else {
                    nextMonthKey = yearAndMonthArray[indexNumber! + 1]
                }
            } else {
                print("右スワイプ")
                if indexNumber == 0 {
                    nextMonthKey = yearAndMonthArray[yearAndMonthArray.count - 1]
                } else {
                    nextMonthKey = yearAndMonthArray[indexNumber! - 1]
                }
            }
            let nextMonthMemory = monthsMemoryArray[nextMonthKey!]!
            self.currentMonthKey = nextMonthKey!
            print("nextMonthKey!", nextMonthKey!)
        }
    }
    
    func sortMonthsMemoryArray() {
        yearAndMonthArray = monthsMemoryArray.keys.sorted(by: {$0 < $1})
        print("yearAndMonthArray：", yearAndMonthArray)
    }
    
}
