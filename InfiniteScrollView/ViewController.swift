//
//  ViewController.swift
//  InfiniteScrollView
//
//  Created by Tejas Dubal on 02/08/18.
//  Copyright © 2018 Tejas Dubal. All rights reserved.
//

import UIKit

class ViewController: UIViewController, InfiniteScrollDelegate {
    
    @IBOutlet weak var infiniteScrollCollection: InfiniteScrollView!
    var menuArray = ["Home", "Login", "News", "Video", "Audio", "Sports"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupInfiniteScrollView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupInfiniteScrollView() {
        var cellStyle = CellStyle()
        cellStyle.selectedTitleColor = UIColor.red
        cellStyle.normalTitleColor = UIColor.black
        cellStyle.indicatorColor = UIColor.red
        cellStyle.isCellWidthDynamic = true
        cellStyle.isListCircular = false
        infiniteScrollCollection.infiniteScrollDelegate = self
        infiniteScrollCollection.setupCollection(menuArray: menuArray, cellStyle: cellStyle)
    }
    
    func actionClickOn(index: Int) {
        
    }
}
