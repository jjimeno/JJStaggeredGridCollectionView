//
//  HeaderFooterCollectionViewCell.swift
//  JJLStaggeredGridCollectionViewExample
//
//  Created by Jose Jimeno Linares on 23/1/17.
//  Copyright © 2017 JJL. All rights reserved.
//

import UIKit

public class HeaderFooterCollectionReusableView: UICollectionReusableView {
    @IBOutlet public var lblTitle : UILabel?
    
    func drawWithText(text:String){
        self.lblTitle?.text = text
    }
}
