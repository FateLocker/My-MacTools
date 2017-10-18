//
//  ModuleFileManger.swift
//  Sand
//
//  Created by Hu on 2017/8/11.
//  Copyright © 2017年 xx. All rights reserved.
//

import Cocoa

class ModuleFileManger: NSObject {
    
    static let shareInstance:ModuleFileManger = ModuleFileManger()
    
    //文件管理者
    let fileManger = FileManager.default
    
    //获取Document路径
    
    public func getDocumentPath() -> String{
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        let path = paths.first
        
        return path!
    
    }
    
    //获取桌面路径
    public func getDesktopPath() -> String{
    
        let paths = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)
        
        guard let path = paths.first else {
            
            return "路径不存在"
        
        }
        return path
    }
    
    ///根据传入的参数创建文件夹
   public func createDirectory(_ directorPath:String) {
        
        //创建文件夹
        
        do {
            try fileManger.createDirectory(atPath: directorPath, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            
            print(error.localizedDescription)
            
            print("创建文件夹失败")
        }
        
        
    }
    
    ///根据传入的文件名创建文件
   public func createFile(_ fileName:String, toPath targetPath:String){
        
        let filePath = targetPath + ("/\(fileName)")

        if !fileManger.fileExists(atPath: filePath) {
            
            let isSucces = fileManger.createFile(atPath: filePath, contents: nil, attributes: nil)
            
            if isSucces {
                print("文件创建成功")
            }else {
                print("文件创建失败")
            }
        }
        
//        return filePath
        
    }
    
    ///遍历文件夹
   public func traverseFilePath(targetPath:String){
        
//        let contentOfPath = try? fileManger.contentsOfDirectory(atPath: targetPath)
        
//        print(contentOfPath)
    }
    
    ///复制文件
   public func copyFile(from fromPath:String, to toPath:String ){
        
        try? fileManger.copyItem(at: URL.init(fileURLWithPath: fromPath), to: URL.init(fileURLWithPath: toPath))
    
    }
    
    //把String保存到文件
   public func saveStringToFile(saveString string:String ,savePath path:String){
        
        do {
            try string.write(toFile: path, atomically: true, encoding:String.Encoding.utf8)
        } catch{
            
            return
        }
    }

}
