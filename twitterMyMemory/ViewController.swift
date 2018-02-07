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
import Alamofire
import SwiftDate

class ViewController: UIViewController {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    var nextQuery = ""
    var userName : String?
    var memoryArray = [Date : String]() //[created_date : imageUrl]
    var maxId = ""
    var tweetCount = 0
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var getImageButon: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 4
        getImageButon.layer.cornerRadius = 4
        getImageButon.isHidden = true
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Twitterログイン
    @IBAction func twitterLogin(_ sender: Any) {
        TWTRTwitter.sharedInstance().logIn { (session, error) in
            if session != nil {
                print("signed in as \(session!.userName)")
                self.userName = session!.userName
                self.userNameLabel.text = session!.userName
                
                let client = TWTRAPIClient(userID: session!.userID)
                client.loadUser(withID: session!.userID, completion: { (user, error) in
                    if let error = error {
                        print(error)
                    } else {
                        let req = request((user?.profileImageLargeURL)!)
                        req.responseData { (response) in
                            if response.result.isSuccess == true {
                                print("success", response.result.description)
                                if let data = response.result.value {
                                    DispatchQueue.main.async {
                                        self.userImageView.image = UIImage(data: data)
                                    }
                                }
                            } else {
                                print("error", response.result.description)
                            }
                        }
                    }
                })
                self.getImageButon.isHidden = false
            } else {
                print("error: \(error!.localizedDescription)")
            }
        }
    }
    
    //投稿画像ゲットボタンタップ
    @IBAction func getTwitterMyPhoto(_ sender: Any) {
        self.loadingQuery()
    }
    
    //投稿画像を取ってくる
    func loadingQuery() {
        SVProgressHUD.show(withStatus: "Twitterから画像取り込み中")
        if let userID = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
            print(userID)
            let url = "https://api.twitter.com/1.1/statuses/user_timeline.json"
            var params = [
                "screen_name" : "@" + self.userName!,
                "exclude_replies" : "true",
                "trim_user" : "true",
                "include_rts" : "false",
                "count": "200",
                ]
            
            //前回取ってきた時に一番後ろのtweetIDがあればそれ以降を取ってくるためにパラーメーター追加
            if maxId != "" {
                params["max_id"] = maxId
            }
            
            let client = TWTRAPIClient(userID: userID)
            var request = client.urlRequest(withMethod: "GET", urlString: url, parameters: params, error: nil)
            
            //リクエスト
            client.sendTwitterRequest(request, completion: {
                response, data, error in
                if let error = error {
                    print("検索エラー", error)
                    SVProgressHUD.dismiss()
                    
                } else {
                    let json = try! JSON(data: data!)
                    print("json", json)
                    self.setImageArray(json: json)
                    
                    //tweetCountが3200に達するか、帰ってきたjsonが0になったら抜けて画面遷移
                    if self.tweetCount >= 3200 || json.array!.count == 0 {
                        let getImageCount = self.memoryArray.count
                        SVProgressHUD.dismiss()
                        SVProgressHUD.showSuccess(withStatus: String(getImageCount) + "枚取り込み成功")
                        self.performSegue(withIdentifier: "toPageView", sender: nil)
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
            //写真がtweetに対して複数枚ある時
            if let extendedEntities = tweet["extended_entities"]["media"].array {
                let created_at = tweet["created_at"].string!
                print("created_at(extendedEntities時)", created_at)
                var created_date = try! DateInRegion(string: created_at, format: .custom("EEE MMM dd HH:mm:ss Z yyyy"))!.absoluteDate
                for mediaInfo in extendedEntities {
                    if let imageUrl = mediaInfo["media_url_https"].string {
                        while memoryArray.keys.contains(created_date) {
                            print("1秒たす前:", created_date)
                            let date = created_date
                            created_date = date + 1.second
                            print("1秒たした後:", created_date)
                        }
                        memoryArray[created_date] = imageUrl
                        print("画像ゲット！")
                    }
                }
            //写真がtweetに対して1枚の時
            } else if let imageUrl = tweet["entities"]["media"][0]["media_url_https"].string {
                let created_at = tweet["created_at"].string!
                print("created_at(entities時)", created_at)
                var created_date = try! DateInRegion(string: created_at, format: .custom("EEE MMM dd HH:mm:ss Z yyyy"))!.absoluteDate
                while memoryArray.keys.contains(created_date) {
                    print("1秒たす前:", created_date)
                    let date = created_date
                    created_date = date + 1.second
                    print("1秒たした後:", created_date)
                }
                self.memoryArray[created_date] = imageUrl
                print("画像ゲット！")
            } else {
                print("画像はなかった")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPageView" {
            let monthViewController = segue.destination as! monthViewController
            monthViewController.memoryArray = self.memoryArray
        } else if segue.identifier == "toTwitterMemoryView" {
            let twitterMemoryViewController = segue.destination as! TwitterMemoryViewController

        }
    }
    
}

