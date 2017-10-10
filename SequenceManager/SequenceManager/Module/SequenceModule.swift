//
//  SequenceModule.swift
//  SequenceManager
//
//  Created by Hu on 2017/9/13.
//  Copyright © 2017年 xx. All rights reserved.
//

import Cocoa

class SequenceModule: NSObject {
    
    var parentModule:SequenceModule?
    
    var moduleID:String
    
    var isLeaf:Bool
    
    var modulePath = String()
    
    var leafModules = [SequenceModule]()
        {
            didSet{
            
                if leafModules.count == 0 {
                    
                    self.isLeaf = true
                }else{
                
                
                    self.isLeaf = false
                }
            
            }
    
    }
    
    init(_ moduleIDName:String) {
        
        moduleID = moduleIDName
        
        isLeaf = false
        
        
    }

}
