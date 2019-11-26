//
//  ViewController.swift
//  AlamofireTest
//
//  Created by 深瀬貴将 on 2019/11/13.
//  Copyright © 2019 fukase. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Foundation

struct Title: Codable {
    let title: String
    let url: String
}

class ViewController: UIViewController {
    
    var titles:[Title]?
    
    @IBOutlet weak var tableView: UITableView!

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //APIから帰ってきた記事一覧のデータを格納
    fileprivate var articles: [String] = [] {
        //didSetと書くことで、上の配列に値がセットされるたびに{}内が実行される
        didSet {
            tableView.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        afFetchArticles()
        initTableView()
    }

    
    //AlamofireとswiftyJSONとCodableを使用
    private func afFetchArticles() {
        
        let urlString: String = "http://qiita.com/api/v2/items"
        
        Alamofire.request(urlString, method: .get).responseJSON { response in
            
            guard let data = response.data else {
                return
            }
            
            self.titles = try! JSONDecoder().decode([Title].self, from: data)
            
            do {
                print("取得したタイトル：\(self.titles)")
                self.tableView.reloadData()
            }
            catch {
                print(error)

            }
            
        }
    }
    
    
    private func initTableView() {
        //作成したカスタムセル（xibファイルで作ったもの)を使う
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        //セルの高さを自動調節
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
    }
    

    
}

//TableViewのセルの個数や中身に関する基本設定
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.titles?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        if let title = self.titles?[indexPath.row].title {
            if let url = self.titles?[indexPath.row].url {
                cell.bindData(text: "タイトル: \(title)\nURL:\(url)")

            }else {
                cell.bindData(text: "タイトル: \(title)")

            }
        }
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


//TableViewのイベント発生時の処理の設定
extension ViewController: UITableViewDelegate {
    
    //セルタップ時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("section: \(indexPath.section) index: \(indexPath.row)")
    }
    
    //セルスクロール時の処理
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        return
    }
}

