//
//  ViewController.swift
//  SequenceManager
//
//  Created by Hu on 2017/8/22.
//  Copyright © 2017年 xx. All rights reserved.
//

import Cocoa
import SWXMLHash

let ROOTMODULE_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Sand/RootModule"

let SUBMODULE_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Sand/SubModule"

let CONNECTMODULE_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Sand/ConnectModule"

let ICONMODULE_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Sand/IconModule"

let BACKBUTTON_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Sand/BackButton"

class ViewController: NSViewController {
    
    var i = 0
    
    @IBOutlet weak var textField: NSTextField!
    
    let moduleFileManager = ModuleFileManger.shareInstance
    
    let xmlTool = XMLParserTool()
    
    
    var dataSource:[SequenceModule] = {
        
        return []
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
    
    private func openSavePanel() ->NSSavePanel{
        
        
        let panel = NSSavePanel()
        
        panel.directoryURL = NSURL(string: moduleFileManager.getDesktopPath()) as URL?
        
        panel.allowsOtherFileTypes = true
        
        panel.canCreateDirectories = true
        
        return panel
    
    }
    
    //生成沙盘模块
    @IBAction func saveModule(_ sender: Any) {
        
        let panel = self.openSavePanel()
        
        panel.begin { (result) in
            
            if result == NSFileHandlingPanelOKButton {
            
                let path = panel.url!.path
                
                self.moduleFileManager.createDirectory(path)
                
                self.moduleFileManager.copyFile(from: ROOTMODULE_RESOURCE_PATH, to: path + "/模块")
                
                self.createSandModule(sourceArray: self.dataSource, savePath: path, parentModule: nil)
                
            }
        }
        
    }
    //生成区位模块
    
    @IBAction func saveTrafficModule(_ sender: NSButton) {
        
        let panel = self.openSavePanel()
        
        panel.begin { (result) in
            
            let path = panel.url!.path
            
            self.moduleFileManager.createDirectory(path)
            
            self.moduleFileManager.copyFile(from: ROOTMODULE_RESOURCE_PATH, to: path + "/模块")
            
            
        }
    }
    ///生成模块
    @IBAction func addSubModule(_ sender: NSButton) {
        
        i = 0
        
        if self.textField.stringValue.isEmpty {
            return
        }
        
        let module = SequenceModule(self.textField.stringValue)
        
        module.isLeaf = true
        
        guard self.dataSource.count != 0 else {
            
            self.dataSource.append(module)
            
            self.moduleListOutlineView.reloadData()
            
            return
        }
        
        
        guard let selectModuleItem = self.moduleListOutlineView.item(atRow: self.moduleListOutlineView.selectedRow) as? SequenceModule else {
            
            self.dataSource.append(module)
            
            self.moduleListOutlineView.reloadData()
            
            return
        }
            
        selectModuleItem.isLeaf = false
        
        selectModuleItem.leafModules.append(module)
        
        self.moduleListOutlineView.reloadData()
        
    }
    
    //创建区位模块
    private func createTracficModule(){
    
    
    }
    
    //创建沙盘模块
    private func createSandModule(sourceArray array:Array<SequenceModule>, savePath path:String, parentModule sequenceModuel:SequenceModule?) ->Void{
        
        let modulePath = path + "/模块/subs/模块"
        
        let sequenceFilePath = path + "/序列帧/沙盘/"
        
        guard array.count != 0 else {
            
            return
        }
        
        
        
        for item in array {
            
            //模块路径
            item.modulePath = modulePath + "/\(String(format:"%.2d",i))B.\(item.moduleID)"
            
            //创建沙盘场景模块
            
            self.createMuleAndAddID(from: SUBMODULE_RESOURCE_PATH, to: item.modulePath, AndItemID: item.moduleID)
            
            if let parentModuel = sequenceModuel {
                
                //衔接文件名
                let fileName = "\(parentModuel.moduleID)" + "到" + "\(item.moduleID)"
                
                //添加衔接点
                
                self.createMuleAndAddID(from: ICONMODULE_RESOURCE_PATH, to: parentModuel.modulePath + "/subs/模块/01/\(item.moduleID)", AndItemID: item.moduleID)
                
                //创建衔接模块
                
                self.createMuleAndAddID(from: CONNECTMODULE_RESOURCE_PATH, to: modulePath + "/\(String(format:"%.2d",i))A.\(fileName)", AndItemID: fileName)
                
                self.xmlTool.changeXMLRootElementProperty(targetXMLPath: modulePath + "/\(String(format:"%.2d",i))A.\(fileName)/datafile.xml", addProperty: "序列帧/沙盘/" + fileName)
                
                //创建衔接序列帧路径
                self.moduleFileManager.createDirectory(sequenceFilePath + "\(fileName)")
                
                //添加返回按钮
                self.createMuleAndAddID(from: BACKBUTTON_RESOURCE_PATH, to: item.modulePath + "/subs/装饰/返回", AndItemID: parentModuel.moduleID)
                
            }
            
            
            i = i + 1
            
            if !item.isLeaf {

                self.createSandModule(sourceArray: item.leafModules, savePath: path, parentModule: item)
            }
            
        }
        
    }
    
    private func createMuleAndAddID(from pathFrom:String,to pathTo:String,AndItemID item:String){
        
        //创建模块
        self.moduleFileManager.copyFile(from: pathFrom, to: pathTo)
        
        //命名模块ID
        self.xmlTool.addXMLFileElement(targetXMLPath: pathTo + "/config.xml", addProperty: item)
        
    }
    
    
}

//MARK: DataSource Delegate
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



//MARK: View Delegate
extension ViewController:NSOutlineViewDelegate{
    
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        var cell:NSTableCellView?
        
        cell = outlineView.make(withIdentifier: "Cell", owner: self) as? NSTableCellView
        
        if let item = item as? SequenceModule {
            
            cell?.textField?.stringValue = item.moduleID
            
        }
        
        return cell
        
    }
    
    //点击列的表头
    public func outlineView(_ outlineView: NSOutlineView, didClick tableColumn: NSTableColumn) {
        
    }
    
    public func outlineView(_ outlineView: NSOutlineView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        
        return proposedSelectionIndexes
    }
    
    
}

