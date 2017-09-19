//
//  XMLParserTool.swift
//  Sand
//
//  Created by Hu on 2017/8/11.
//  Copyright © 2017年 xx. All rights reserved.
//

import Cocoa
import SWXMLHash

struct Book:XMLIndexerDeserializable{
    
    let title:String
    let price:Double
    let year:Int
    let amount:Int?
    
    static func deserialize(_ node:XMLIndexer) throws -> Book{
        
        return try Book(
            
            title:node["title"].value(),
            price: node["price"].value(),
            year: node["year"].value(),
            amount: node["amount"].value()
            
        )
        
    }
}

class XMLParserTool: NSObject {
    
    func parseXMLFile(_ xmlFile:String?){
        
//        guard let xml = xmlFile else {
//            
//            print("没有读取到文件")
//            
//            return
//        
//        }
        
        
    }
}
