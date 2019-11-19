//
//  ViewController.swift
//  AlamofireTest
//
//  Created by 深瀬貴将 on 2019/11/13.
//  Copyright © 2019 fukase. All rights reserved.
//

import UIKit

//★★★API通信でライブラリを使わないオーソドックスなやり方の練習

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //APIから帰ってきた記事一覧のデータを格納
    fileprivate var articles: [[String: Any]] = [] {
        //didSetと書くことで、上の配列に値がセットされるたびに{}内が実行される
        didSet {
            tableView.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchArticles()
        initTableView()
    }

    
    
    private func fetchArticles() {
        //API通信リクエストと、取得したdataのJSON型への変換、パースを行なっていく
        let url: URL = URL(string: "http://qiita.com/api/v2/items")!
        
        let task: URLSessionTask = URLSession.shared.dataTask(with: url, completionHandler: {data, response, error in
            do {
                //guard letでオプショナルdataを代入アンラップ
                guard let data = data else { return }
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [Any] else { return }
                //mapを使って配列内の要素１つ１つにクロージャーで渡した処理を行う
                let articles = json.compactMap { (article) -> [String: Any]? in
                    return article as? [String: Any]
                }
                
                //メインスレッドで行う様にする書き方
                DispatchQueue.main.async() { () -> Void in
                    self.articles = articles
                }
            }
            catch {
                print(error)
            }
            
        })
        task.resume()
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
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        let article = articles[indexPath.row]
        let title = article["title"] as? String ?? ""
        cell.bindData(text: "タイトル: \(title)")
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

