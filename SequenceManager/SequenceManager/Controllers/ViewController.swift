//
//  ViewController.swift
//  SequenceManager
//
//  Created by Hu on 2017/8/22.
//  Copyright © 2017年 xx. All rights reserved.
//

import Cocoa
import SWXMLHash

let ROOTMODULE_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/RootModule"

let SUBMODULE_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/SubModule"

let CONNECTMODULE_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/ConnectModule"

class ViewController: NSViewController {
    
    var i = 0
    
    @IBOutlet weak var textField: NSTextField!
    
    let moduleFileManager = ModuleFileManger.shareInstance
    
    var dataSource:[SequenceModule] = {
        
        var module1 = SequenceModule("区域沙盘")
        module1.isLeaf = false
        var module2 = SequenceModule("组团沙盘1")
        module2.isLeaf = false
        var module4 = SequenceModule("项目沙盘1")
        module4.isLeaf = false
        var module6 = SequenceModule("单体1")
        module6.isLeaf = true
        var module7 = SequenceModule("单体2")
        module7.isLeaf = true
        var module5 = SequenceModule("项目沙盘2")
        module5.isLeaf = false
        var module3 = SequenceModule("组团沙盘2")
        module2.isLeaf = false
        
        module4.leafModules = [module6,module7]
        
        module2.leafModules = [module4,module5]
        
        module1.leafModules = [module2,module3]
        
        return [module1]
    }()
    
    @IBOutlet weak var moduleListOutlineView: NSOutlineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.moduleListOutlineView.expandItem(nil, expandChildren: true)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //生成模块文件
    @IBAction func saveModule(_ sender: Any) {
        
        let panel = NSSavePanel()
        
        panel.directoryURL = NSURL(string: moduleFileManager.getDesktopPath()) as URL?
        
        panel.allowsOtherFileTypes = true
        
        panel.canCreateDirectories = true
        
        panel.begin { (result) in
            
            if result == NSFileHandlingPanelOKButton {
            
                let path = panel.url!.path
                
                self.moduleFileManager.createDirectory(path)
                
                self.moduleFileManager.copyFile(from: ROOTMODULE_RESOURCE_PATH, to: path + "/模块")
                
                self.createSandModule(sourceArray: self.dataSource, savePath: path, parentModule: nil)
                
            }
            
        }
        
    }
    
    ///添加模块
    @IBAction func addSubModule(_ sender: NSButton) {
        
        if self.textField.stringValue.isEmpty {
            return
        }
        
        let module = SequenceModule(self.textField.stringValue)
        
        module.isLeaf = true
        
        guard let selectModuleItem = self.moduleListOutlineView.item(atRow: self.moduleListOutlineView.selectedRow) as? SequenceModule else { return  }
            
        selectModuleItem.isLeaf = false
        
        selectModuleItem.leafModules.append(module)
        
        self.moduleListOutlineView.reloadData()
        
        
    }
    
    //创建沙盘模块
    func createSandModule(sourceArray array:Array<SequenceModule>, savePath path:String, parentModule sequenceModuel:SequenceModule?) ->Void{
        
        let modulePath = path + "/模块/subs/模块"
        
        let sequenceFilePath = path + "/序列帧/沙盘"
        
        guard array.count != 0 else {
            
            return
        }
        
        for item in array {
            
            if let parentModuel = sequenceModuel {
                
                //衔接文件名
                let fileName = "\(parentModuel.moduleID)" + "到" + "\(item.moduleID)"
                
                //创建衔接模块
                self.moduleFileManager.copyFile(from: CONNECTMODULE_RESOURCE_PATH, to: modulePath + "/\(String(format:"%.2d",i))A.\(fileName)")
                
              //创建衔接序列帧路径
                self.moduleFileManager.createDirectory(sequenceFilePath + "\(fileName)")
                
            }
            
            //创建沙盘场景模块
            self.moduleFileManager.copyFile(from: SUBMODULE_RESOURCE_PATH, to: modulePath + "/\(String(format:"%.2d",i))B.\(item.moduleID)")
            
            i = i + 1
            
            if !item.isLeaf {

                self.createSandModule(sourceArray: item.leafModules, savePath: path, parentModule: item)
            }
            
        }
        
    }
    
    

}

extension ViewController:NSOutlineViewDataSource {
    
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if let item = item as? SequenceModule {
            
            return item.leafModules.count
        }
        
        return dataSource.count
    }
    
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        
        if let item = item as? SequenceModule {
            
            return !item.isLeaf
        }
        
        return false
    }
    
    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if let item  = item as? SequenceModule {
            
            return item.leafModules[index]
        }
        
        return dataSource[index]
    }
    
}


extension ViewController:NSOutlineViewDelegate{
    
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        var cell:NSTableCellView?
        
        cell = outlineView.make(withIdentifier: "Cell", owner: self) as? NSTableCellView
        
        if let item = item as? SequenceModule {
            
            cell?.textField?.stringValue = item.moduleID
            
        }
        
        return cell
        
    }
    
    public func outlineViewSelectionDidChange(_ notification: Notification) {
        
        
//        if selectItem.isLeaf {
//            
//            selectItem.leafModules =
//        }
//        
    }
    
    //点击列的表头
    public func outlineView(_ outlineView: NSOutlineView, didClick tableColumn: NSTableColumn) {
        
        print("click")
        
    }
    
    public func outlineView(_ outlineView: NSOutlineView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        
        return proposedSelectionIndexes
    }
    
    
}

