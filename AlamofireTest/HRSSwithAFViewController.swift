//
//  HRSSwithAFViewController.swift
//  AlamofireTest
//
//  Created by 深瀬貴将 on 2019/11/26.
//  Copyright © 2019 fukase. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import SwiftyJSON
import AlamofireImage
import Foundation

struct Items: Codable {
    var items: [Link]
    
    struct Link: Codable {
        var link: String
    }
}

class HRSSwithAFViewController: UIViewController, UITextFieldDelegate {
    
    var items: Items?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    // APIを利用するためのアプリケーションID
    let apikey: String = "AIzaSyDVyxhFCjqj5shwAWzo0EI2nT81pHoMRDw"

    //APIを利用するためのサーチエンジンキー
    let cx: String = "009237515506121379779:giiokppklre"

    //利用するAPIのサーチタイプ
    let searchType: String = "image"

    // APIのURL
    let urlString: String = "https://www.googleapis.com/customsearch/v1"
    
    //関連画像URLを格納する配列
    var imageUrlArray: [String] = []

    //現在表示している画像の添字を格納する変数
    var imageIndex :Int = 0
    
    
    @IBAction func startButton(_ sender: Any) {
        
        let query = textField.text
        imageIndex = imageIndex + 1
        //画像配列の末尾に達していたら、配列に新たな１０件の画像を登録する
        if((imageIndex) != imageUrlArray.count){

            //パラメータのstartを決める
            let startPara: String = String(imageIndex)

            
            // パラメータを指定する
            let parameter = ["key": apikey, "cx": cx, "searchType": searchType, "q": query, "start": startPara] as Parameters
            
            Alamofire.request(urlString, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil).responseJSON { response in
                print(response)
                let json = JSON(response.result.value as Any)
                print(json)
                print(json["items"])
                let result = json["items"]["link"]
                print(result)
                }
                
                
            }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
    }
    
    
    //入力フォームを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
              self.view.endEditing(true)
          }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

  

}
