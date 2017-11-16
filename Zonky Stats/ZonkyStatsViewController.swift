//
//  ZonkyStatsViewController.swift
//  Zonky Stats
//
//  Created by lgergel on 15/11/2017.
//  Copyright © 2017 Lukas Gergel. All rights reserved.
//

import UIKit
//import RealmSwift

class ZonkyStatsViewController: UIViewController, RadioBarSelectionChanged {
    private var activeButton = 3
    @IBOutlet weak var radioBarView: RadioBarView!
    @IBOutlet weak var graphView: MyGraphView!
    
    var alert:UIAlertController!
    
    func showAlert(_ msg: String) {
        self.alert = UIAlertController(title: "Upozorneni", message: msg, preferredStyle: UIAlertControllerStyle.alert)
        self.present(self.alert, animated: true, completion: nil)
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ZonkyStatsViewController.closeAlert), userInfo: nil, repeats: false)
    }
    
    @objc func closeAlert(){
        self.alert.dismiss(animated: true, completion: nil)
    }
    
    func selectionChanged(_ button: UIButton?, index: Int) {
        activeButton = index
        radioBarView.selectItem(index: activeButton)
        selectRange(activeButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        radioBarView.setSelectionChangedHandler(handler: self)
        selectionChanged(nil, index: activeButton)
    }
    
    func selectRange(_ item: Int){
        let today = Date().resetTime()
        var toD: Date?;
        var fromD: Date?
        
        switch item {
        case 0:
            fromD = Calendar.current.date(byAdding: .month, value: -2, to: today!)?.firstDay()
            toD = today
            break;
        case 1:
            fromD = Calendar.current.date(byAdding: .month, value: -11, to: today!)?.firstDay()
            toD = today
            break
        case 2:
            fromD = Date.from(2016, 1, 1)
            toD = Date.from(2017, 1, 1)
            break;
        case 3:
            fromD = Date.from(2017, 1, 1)
            toD = Date.from(2018, 1, 1)
        default:
            return
        }
        fetchData(fromD, toD)
    }
   
    func fetchData(_ fromD: Date?, _ toD: Date?){
        let repo: Repository = Repository()
        let res = MarketplaceResource(fromD: fromD!, toD: toD!)
        let cfg = res.setupRequest(config: URLSessionConfiguration.ephemeral)
        let session = URLSession(configuration: cfg, delegate: nil, delegateQueue: OperationQueue.main)
        let request = ApiRequest(resource: res, session: session)
        
        repo.fetchMarketspaceData(apiRequest: request, withCompletion: {
            (data: DataResponse) -> Void in
            if let err = data.error {
                self.showAlert(err)
            }
            else{
                self.graphView.viewModel = MyGraphView.ViewModel(stats: data)
            }
        } )
    }
}


