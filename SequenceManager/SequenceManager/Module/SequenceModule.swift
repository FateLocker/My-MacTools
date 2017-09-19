//
//  SequenceModule.swift
//  SequenceManager
//
//  Created by Hu on 2017/9/13.
//  Copyright © 2017年 xx. All rights reserved.
//

import Cocoa

class SequenceModule: NSObject {
    
    var moduleID:String
    
    var isLeaf:Bool
    
    var leafModules = [SequenceModule]()
    
    init(_ moduleIDName:String) {
        
        moduleID = moduleIDName
        
        isLeaf = false
    }
    
    

}
