//
//  HRSlideShowViewController.swift
//  AlamofireTest
//
//  Created by 深瀬貴将 on 2019/11/19.
//  Copyright © 2019 fukase. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import Foundation


class HRSlideShowViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var StartButton: UIButton!
    @IBOutlet weak var nextImageButton: UIButton!
    
    //BGMを再生するためのインスタンスを宣言しておく
    var audioPlayer: AVAudioPlayer!
    
    // APIを利用するためのアプリケーションID
    let apikey: String = "AIzaSyDVyxhFCjqj5shwAWzo0EI2nT81pHoMRDw"

    //APIを利用するためのサーチエンジンキー
    let cx: String = "009237515506121379779:giiokppklre"

    //利用するAPIのサーチタイプ
    let searchType: String = "image"

    // APIのURL
    let entryUrl: String = "https://www.googleapis.com/customsearch/v1"

    //関連画像URLを格納する配列
    var imageArray: [String] = []

    //現在表示している画像の添字を格納する変数
    var imageIndex :Int = 0;
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        playSound(name: "burnShortEdited")
        
    }
    
    
    
    @IBAction func startButton(_ sender: Any) {
        
        let query = textField.text
        
        imageArray.removeAll()
        
        //パラメーターの指定
        let parameter = ["key": apikey, "cx": cx, "searchType": searchType, "q": query]
        
        //パラメーターをエンコードしたURLを作成
        let requestUrl = createRequestUrl(parameter: parameter as! [String: String])
        
        
        //API通信リクエスト
        request(requestUrl: requestUrl) { result in
            if let url = URL(string: self.imageArray[0]) {
                let req = URLRequest(url: url)
                let task = URLSession.shared.dataTask(with: req, completionHandler: {data, response, error in
                    if let data = data {
                        if let anImage = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.imageView.image = anImage
                            }
                        }
                    }
                })
                task.resume()
            }
        }
        
        //MP3音源を再生
        audioPlayer.play()
    }
    
    
    @IBAction func nextButton(_ sender: Any) {
        
        let query = textField.text
        imageIndex = imageIndex + 1
        //画像配列の末尾に達していたら、配列に新たな１０件の画像を登録する
        if((imageIndex) == imageArray.count){

        //パラメータのstartを決める
        let startPara: String = String(imageIndex)

        
        // パラメータを指定する
        let parameter = ["key": apikey, "cx": cx, "searchType": searchType, "q": query, "start": startPara]

        // パラメータをエンコードしたURLを作成する
        let requestUrl = createRequestUrl(parameter: parameter as! [String : String])
            
            request(requestUrl: requestUrl) { result in
                if let url = URL(string: self.imageArray[self.imageIndex + 1]) {
                    let req = URLRequest(url: url)
                    let task = URLSession.shared.dataTask(with: req, completionHandler: {data, reponse, error in
                        if let data = data {
                            if let anImage = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self.imageView.image = anImage
                                }
                            }
                        }
                    })
                    task.resume()
                }
            }
        }else {
            if let url = URL(string: self.imageArray[self.imageIndex]) {
            let req = URLRequest(url: url)
            let task = URLSession.shared.dataTask(with: req, completionHandler: {data, reponse, error in
                if let data = data {
                    if let anImage = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.imageView.image = anImage
                        }
                    }
                }
            })
            task.resume()
            }
        }
    }
        
    

    //パラメーターのURLエンコード処理
    private func encodeParameter(key: String, value: String) -> String? {
        guard let escapeValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return nil
        }
        return "\(key)=\(escapeValue)"
    }
    
    
    //URL作成処理
    private func createRequestUrl(parameter: [String: String]) -> String {
        var parameterString = ""
        for key in parameter.keys {
            guard let value = parameter[key] else {
                continue
            }
            
            //既にパラメーターが設定されていた場合
            if parameterString.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                //パラメーター同士のセパレータである＆を追加
                parameterString += "&"
            }
            
            //値をエンコードする
            guard let encodeValue = encodeParameter(key: key, value: value) else {
                continue
            }
            //エンコードした値をパラメーターとして追加
            parameterString += encodeValue
        }
        
        let requestUrl = entryUrl + "?" + parameterString
        return requestUrl
    }
    
    
    //検索結果をパースする
    private func parseData(items: [Any], resultHandler: @escaping (([String]?) -> Void)) {
        for item in items {
            //レスポンスから画像の情報を取得する
            guard let item = item as? [String: Any], let imageURL = item["link"] as? String else {
                resultHandler(nil)
                return
            }
            print(imageURL)
            
            //配列に追加
            imageArray += [imageURL]
        }
        resultHandler(imageArray)
    }
    
    
    
    //リクエストを行う
    private func request(requestUrl: String, resultHandler: @escaping(([String]?) -> Void)) {
        guard let url = URL(string: requestUrl) else {
            resultHandler(nil)
            return
        }
        
        //リクエスト生成
        let request = URLRequest(url: url)
        
        //APIをコールして検索を行う
        let task: URLSessionTask = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            do {
                //guard letでオプショナルdataを代入アンラップ
                guard let data = data else { return }
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else {
                    resultHandler(nil)
                    return
                }
                
                guard let resultSet = json["items"] as? [Any] else {
                    resultHandler(nil)
                    return
                }
                self.parseData(items: resultSet, resultHandler: resultHandler)
                
                
            }
            catch {
                print(error)
            }
            
        })
        task.resume()
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

//オーディオの設定・アニメーションと連動した音声を流すため
extension HRSlideShowViewController: AVAudioPlayerDelegate {
    func playSound(name: String) {
        guard let path = Bundle.main.path(forResource: "burnShortEdited", ofType: "mp3") else {
                print("音源ファイルが見つかりません")
                return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        } catch {
            
        }
    }
}
