//
//  ViewController.swift
//  twitterMyMemory
//
//  Created by Hiroki Taniguchi on 2018/01/27.
//  Copyright © 2018年 Hiroki Taniguchi. All rights reserved.
//

import UIKit
import TwitterKit
import SwiftyJSON
import SVProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    var nextQuery = ""
    var userName : String?
    var dateArray = [String]()
    var imageArray = [String]()
    var maxId = ""
    var tweetCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func twitterLogin(_ sender: Any) {
        TWTRTwitter.sharedInstance().logIn { (session, error) in
            if session != nil {
                print("signed in as \(session!.userName)")
                self.userName = session!.userName
                self.userNameLabel.text = session!.userName
            } else {
                print("error: \(error!.localizedDescription)")
            }
        }
    }
    
    @IBAction func getTwitterMyPhoto(_ sender: Any) {
        SVProgressHUD.show()
        self.loadingQuery()
    }
    
    func loadingQuery() {
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            print(userID)
            let url = "https://api.twitter.com/1.1/statuses/user_timeline.json"
            var params = [
//                "q": "filter:images -filter:retweets -filter:faves",
                "screen_name" : "@" + self.userName!,
                "exclude_replies" : "true",
                "trim_user" : "true",
                "include_rts" : "false",
                "count": "200",
                ]
            if maxId != "" {
                params["max_id"] = maxId
            }
            let client = TWTRAPIClient(userID: userID)
            var request = client.urlRequest(withMethod: "GET", urlString: url, parameters: params, error: nil)
            client.sendTwitterRequest(request, completion: {
                response, data, error in
                if let error = error {
                    print("検索エラー", error)
                    SVProgressHUD.dismiss()
                    
                } else {
                    let json = try! JSON(data: data!)
                    print("json", json)
                    self.setImageArray(json: json)
                    if self.tweetCount >= 3200 || json.array!.count == 0 {
                        SVProgressHUD.dismiss()
                        self.performSegue(withIdentifier: "toTwitterMemoryView", sender: nil)
                    } else {
                        self.loadingQuery()
                    }
                    
                }
            })
        }
    }
    
    func setImageArray(json: JSON) {
        for tweet in json.array! {
            if let id = tweet["id"].int {
                self.maxId = String(id - 1)
            }
            self.tweetCount += 1
            print("取ってきたツイートのカウント", self.tweetCount)
            if let extendedEntities = tweet["extended_entities"]["media"].array {
                let created_at = tweet["created_at"].string!
                print("created_at(extendedEntities時)", created_at)
                for mediaInfo in extendedEntities {
                    if let imageUrl = mediaInfo["media_url_https"].string {
                        self.dateArray.append(created_at)
                        self.imageArray.append(imageUrl)
                        print("画像ゲット！")
                    }
                }
            }else {
                if let imageUrl = tweet["entities"]["media"][0]["media_url_https"].string {
                    let created_at = tweet["created_at"].string!
                    print("created_at(entities時)", created_at)
                    self.dateArray.append(created_at)
                    self.imageArray.append(imageUrl)
                    print("画像ゲット！")
                } else {
                    print("画像はなかった")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTwitterMemoryView" {
            let twitterMemoryViewController = segue.destination as! TwitterMemoryViewController
            twitterMemoryViewController.dateArray = self.dateArray
            twitterMemoryViewController.imageArray = self.imageArray
        }
    }
    
}

