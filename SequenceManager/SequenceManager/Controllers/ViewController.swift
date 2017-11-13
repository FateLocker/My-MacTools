//
//  ViewController.swift
//  SequenceManager
//
//  Created by Hu on 2017/8/22.
//  Copyright © 2017年 xx. All rights reserved.
//

import Cocoa
import SWXMLHash

let ROOTMODULE = SequenceModule.init("RootModule")

//沙盘资源

let ROOTMODULE_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Sand/RootModule"

let SUBMODULE_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Sand/SubModule"

let CONNECTMODULE_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Sand/ConnectModule"

let ICONMODULE_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Sand/IconModule"

let BACKBUTTON_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Sand/BackButton"

//区位资源

let TRAFFIC_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Traffic/TrafficModule"

let TRAFFICROOT_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Traffic/RootModule"

let TRAFFICSUB_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Traffic/SubModule"

let TRAFFICROOTFOLDER_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Traffic/Folder/Root"

let TRAFFICSUBFOLDER_RESOURCE_PATH = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate/Traffic/Folder/Sub"

class ViewController: NSViewController,NSWindowDelegate,NSApplicationDelegate{
    
    let mainWindow = NSWindowController()
    
    var i = 0
    
    @IBOutlet weak var textField: NSTextField!
    
    let moduleFileManager = ModuleFileManger.shareInstance
    
    let xmlTool = XMLParserTool()
    
    var dataSource:[SequenceModule] = {
        let data1 = SequenceModule.init("世界区位")
        data1.isLeaf = false
        
        let data2 = SequenceModule.init("中国区位")
        data2.isLeaf = true
        
        let data11 = SequenceModule.init("交通")
        data11.isLeaf = false
        data11.parentModule = data1
        
        let data21 = SequenceModule.init("港口")
        data21.isLeaf = true
        data21.parentModule = data1
        
        let data111 = SequenceModule.init("轨道")
        data111.isLeaf = true
        data111.parentModule = data11
        
        let data112 = SequenceModule.init("干道")
        data112.isLeaf = true
        data112.parentModule = data11
        
        data1.leafModules = [data11]
        data11.leafModules = [data111,data112]
        
        ROOTMODULE.leafModules = [data1,data2]
        data1.parentModule = ROOTMODULE
        data2.parentModule = ROOTMODULE
        
        return ROOTMODULE.leafModules
    }()
    
    @IBOutlet weak var moduleListOutlineView: NSOutlineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.moduleListOutlineView.expandItem(nil, expandChildren: true)
        
        let menu = NSMenu()
        menu.delegate = self
        self.moduleListOutlineView.menu = menu
        
        //关闭按钮直接退出程序
        NSApp.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(closeWindow), name: .NSWindowWillClose, object: mainWindow)
        
        //关闭窗口,不退出程序
        
    }
    
    func closeWindow(){
    
        NSApp.terminate(self)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        
        return true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func openSavePanel() -> NSSavePanel{
        
        let panel = NSSavePanel()
        
        panel.directoryURL = NSURL(string: moduleFileManager.getDesktopPath()) as URL?
        
        panel.allowsOtherFileTypes = true
        
        panel.canCreateDirectories = true
        
        return panel
    
    }
    @IBAction func clearDataSource(_ sender: NSButton) {
        
        self.dataSource.removeAll()
        self.moduleListOutlineView.reloadData()
    }
    ///添加模块
    @IBAction func addSubModule(_ sender: NSButton) {
        
        i = 0
        
        if self.textField.stringValue.isEmpty {
            return
        }
        
        let module = SequenceModule(self.textField.stringValue)
        
        module.isLeaf = true
        
        guard let selectModuleItem = self.moduleListOutlineView.item(atRow: self.moduleListOutlineView.selectedRow) as? SequenceModule else {
            
            module.parentModule = ROOTMODULE
            
            self.dataSource.append(module)
            
            self.moduleListOutlineView.reloadData()
            
            return
        }
        
        selectModuleItem.isLeaf = false
        
        selectModuleItem.leafModules.append(module)
        
        module.parentModule = selectModuleItem
        
        self.moduleListOutlineView.reloadData()
        
        
    }
    
    //生成沙盘文件夹
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
            
            self.createModuleAndAddID(from: SUBMODULE_RESOURCE_PATH, to: item.modulePath, AndItemID: item.moduleID)
            
            self.moduleFileManager.createDirectory(sequenceFilePath + "\(item.moduleID)")
            
            self.xmlTool.changeXMLRootElementProperty(targetXMLPath: item.modulePath + "/datafile.xml", addProperty: "序列帧/沙盘/" + item.moduleID)
            
            if let parentModuel = sequenceModuel {
                
                //衔接文件名
                let fileName = "\(parentModuel.moduleID)" + "到" + "\(item.moduleID)"
                
                //添加衔接点
                
                self.createModuleAndAddName(from: ICONMODULE_RESOURCE_PATH, to: parentModuel.modulePath + "/subs/模块/01/00.\(item.moduleID)", AndItemName: item.moduleID)
                
                //创建衔接模块
                
                self.createModuleAndAddID(from: CONNECTMODULE_RESOURCE_PATH, to: modulePath + "/\(String(format:"%.2d",i))A.\(fileName)", AndItemID: fileName)
                
//                self.xmlTool.changeXMLRootElementProperty(targetXMLPath: modulePath + "/\(String(format:"%.2d",i))A.\(fileName)/datafile.xml", addProperty: "序列帧/沙盘/" + fileName)
                let transSequencePath = "序列帧/沙盘/" + fileName
                
                
                let transXMLString = "<root sequenceFile='\(transSequencePath.encode!)' fps='50' decelerationRate='0.010000' loopHorizontal='NO' changeOffset='{8, 0}' maximumZoomScale='1.500000' hotspotDirectory='hotspots' compassDataFile='compass/compassdatafile.xml' loopVertical='NO' minimumZoomScale='1.000000'>\n <gate entranceFrame='0' moduleID='\(parentModuel.moduleID.encode!)' direction='1' preloaded='0' allowNavigation='YES'>\n </gate>\n <gate entranceFrame='-1' moduleID='\(item.moduleID.encode!)' direction='4' preloaded='0' allowNavigation='YES'>\n </gate>\n </root>"
                
                self.xmlTool.createXMLFile(xmlString: transXMLString, savePath: modulePath + "/\(String(format:"%.2d",i))A.\(fileName)/datafile.xml")
                
                //创建衔接序列帧路径
                self.moduleFileManager.createDirectory(sequenceFilePath + "\(fileName)")
                
                //添加返回按钮
                self.createModuleAndAddName(from: BACKBUTTON_RESOURCE_PATH, to: item.modulePath + "/subs/装饰/返回", AndItemName: parentModuel.moduleID)
                
            }
            
            
            i = i + 1
            
            if !item.isLeaf {
                
                self.createSandModule(sourceArray: item.leafModules, savePath: path, parentModule: item)
            }
            
        }
        
    }
    
    
    //生成区位模块
    @IBAction func saveTrafficModule(_ sender: NSButton) {
        
        let panel = self.openSavePanel()
        
        panel.begin { (result) in
            
            if result == NSFileHandlingPanelOKButton {
                
                let path = panel.url!.path
                
                self.moduleFileManager.createDirectory(path)
                
                //生成区位模块外部总体框架
                ROOTMODULE.modulePath = path + "/模块"
                
                self.moduleFileManager.copyFile(from: TRAFFIC_RESOURCE_PATH, to:ROOTMODULE.modulePath)
                
                let sequenceFloderPath = path + "/序列帧/区位"
                
                ROOTMODULE.floderPath = path
                
                self.moduleFileManager.createDirectory(sequenceFloderPath)
                
                //区位序列文件夹
                self.createTrafficModuleSequenceFloder(trafficModuleData: self.dataSource, savePath: sequenceFloderPath)
                
                
                //区位模块
                self.createTrafficModule(sourceDataArr: self.dataSource, savePath: ROOTMODULE.modulePath)
            }
        }
        
    }
    
    
    /// 创建区位脚本模块
    ///
    /// - Parameters:
    ///   - array: 模块数据源
    ///   - path: 存储路径
    ///   - parentMod: 父模块(用于获得父模块的脚本存储路径，子模块需要存储于父模块的路径下)
    private func createTracficModule(sourceArray array:Array<SequenceModule>, savePath path:String,parentModule parentMod:SequenceModule?){
        
        
        
        //新模块存储路径：上一级模块的路径之下
        let modulePath = path + "/模块/subs/模块"
        
        guard array.count != 0 else {
            
            return
        }
        
        //遍历模型存储数据源
        for item in array {
            
            var j = 0
            
            j = array.index(of: item)!
            
            if item.isLeaf{
                
                var savePath = path
                
                if parentMod == nil {
                    
                    savePath = ROOTMODULE.modulePath +  "/subs/模块/\(String(format:"%.2d",j))" + item.moduleID
                    
                    self.createModuleAndAddID(from: TRAFFICROOT_RESOURCE_PATH, to: savePath, AndItemID: item.moduleID)
                    
                }else{
                    
                    let moduleFolderPath = savePath + "/subs/模块/\(String(format:"%.2d",j))" + item.moduleID
                    
                    self.createModuleAndAddID(from: TRAFFICSUB_RESOURCE_PATH, to: moduleFolderPath, AndItemID: item.moduleID)
                    
                    //指定模块路径
                    
                    self.appointModuleSequence(modulePath: moduleFolderPath, sequencePath: item.moduleID, parentModuleID: parentMod?.moduleID)
                
                }
                
            }else{
                
                var itemPath = modulePath + "/\(String(format:"%.2d",j))" + item.moduleID
                
                if let parentModule = parentMod {
                    
                    itemPath = "\(parentModule.modulePath)" + "/subs/模块/\(String(format:"%.2d",j))" + item.moduleID
                }
                
                
                self.createModuleAndAddID(from: TRAFFICROOT_RESOURCE_PATH, to: itemPath, AndItemID: item.moduleID)
                
                item.modulePath = itemPath
                
                self.createTracficModule(sourceArray: item.leafModules, savePath: path, parentModule: item)
                //背景
                self.createModuleAndAddID(from: TRAFFICSUB_RESOURCE_PATH, to: itemPath + "/subs/背景", AndItemID: "")
                
                self.appointModuleSequence(modulePath: itemPath + "/subs/背景", sequencePath: "背景", parentModuleID: item.moduleID)
                
                self.xmlTool.changeNodeElement(XMLFilePath: itemPath + "/subs/背景/subs/内容/layout.xml", nodeName: "layout", elementDic: ["whenAppearUpdateLayout":"NO"])
                //logo
                self.createModuleAndAddID(from: TRAFFICSUB_RESOURCE_PATH, to: itemPath + "/subs/装饰/subs/logo", AndItemID: "")
                
                self.appointModuleSequence(modulePath: itemPath + "/subs/装饰/subs/logo", sequencePath: "logo", parentModuleID: item.moduleID)
            }
        }
    }
    

//MARK: Test
    //》》》》》》》》》》》》》  区位模块重构测试   》》》》》》》》》》》》》//
    
    //生成区位序列帧文件夹
    private func createTrafficModuleSequenceFloder(trafficModuleData dataArr:Array<SequenceModule>,savePath:String){
    
        for item in dataArr {
            
            if item.isLeaf {
                
                var path = savePath + "/模块/\(item.moduleID)"
    
                if item.parentModule?.moduleID == "RootModule" {
                    
                    item.floderPath = savePath + "/\(item.moduleID)"
                    
                    self.moduleFileManager.copyFile(from: TRAFFICROOTFOLDER_RESOURCE_PATH, to: item.floderPath)
                    
                    path = item.floderPath + "/模块/\(item.moduleID)"
                    
                }
                item.floderPath = path
                
                self.moduleFileManager.copyFile(from: TRAFFICSUBFOLDER_RESOURCE_PATH, to: path)
                
                
            }else{
                if item.parentModule?.moduleID == "RootModule" {
                    
                    item.floderPath = savePath + "/\(item.moduleID)"
                    
                }else{
                    
                    item.floderPath = savePath + "/模块/\(item.moduleID)"
                }
                
                self.moduleFileManager.copyFile(from: TRAFFICROOTFOLDER_RESOURCE_PATH, to: item.floderPath)
                
                self.createTrafficModuleSequenceFloder(trafficModuleData: item.leafModules, savePath: item.floderPath)
            
            }
            
            
        }
    
    }
    
    //生成区位模块
    private func createTrafficModule(sourceDataArr dataArr:Array<SequenceModule>,savePath:String){
        
        for item in dataArr {
            
            var j = 0
            
            j = dataArr.index(of: item)!
            
            var moduleSavePath = savePath + "/subs/模块"
            
            if item.isLeaf {
                
                moduleSavePath = moduleSavePath + "/\(String(format:"%.2d",j))" + item.moduleID
                
                if item.parentModule?.moduleID == "RootModule" {
                    
                    self.createTrafficRootModule(savePath: moduleSavePath, item: item)
                    
                    moduleSavePath = moduleSavePath + "/subs/模块/\(item.moduleID)"
                    
                }
                
                item.modulePath = moduleSavePath
                
                self.createTrafficLeafModule(savePath: moduleSavePath, item: item)
                
            }else{
                
                self.createTrafficRootModule(savePath: moduleSavePath + "/\(String(format:"%.2d",j))" + item.moduleID, item: item)
                
                self.createTrafficModule(sourceDataArr: item.leafModules, savePath: item.modulePath)
            }
            
            
        }
    }
    
    //创建Leaf区位模块(导入，导出)
    private func createTrafficLeafModule(savePath:String,item:SequenceModule){
        
        
        self.createModuleAndAddID(from: TRAFFICSUB_RESOURCE_PATH, to: savePath, AndItemID: item.moduleID)
        
        //指定模块路径
        
        self.appointModuleSequence(sequenceModule: item)
    
    }
    
    //创建Root区位模块
    private func createTrafficRootModule(savePath:String,item:SequenceModule){
        
        
        self.createModuleAndAddID(from: TRAFFICROOT_RESOURCE_PATH, to: savePath, AndItemID: item.moduleID)
        
        item.modulePath = savePath
        
        //背景
        self.createModuleAndAddID(from: TRAFFICSUB_RESOURCE_PATH, to: savePath + "/subs/背景", AndItemID: "")
        
        self.appointModuleSequence(modulePath: savePath + "/subs/背景", sequencePath: "背景", parentModuleID: item.moduleID)
        
        self.xmlTool.changeNodeElement(XMLFilePath: savePath + "/subs/背景/subs/内容/layout.xml", nodeName: "layout", elementDic: ["whenAppearUpdateLayout":"NO"])
        //logo
        self.createModuleAndAddID(from: TRAFFICSUB_RESOURCE_PATH, to: savePath + "/subs/装饰/subs/logo", AndItemID: "")
        
        self.appointModuleSequence(modulePath: savePath + "/subs/装饰/subs/logo", sequencePath: "logo", parentModuleID: item.moduleID)
    
    }
    
    
    private func appointModuleSequence(sequenceModule item:SequenceModule){
        
        var str1 = NSString()
        
        str1 = item.floderPath as NSString
        
        let range = str1.range(of: ROOTMODULE.floderPath)
        
        print(range.location,range.length)
        
        let index = item.floderPath.index(item.floderPath.startIndex, offsetBy: range.length + 1)
        
        let index2 = item.floderPath.index(item.floderPath.endIndex, offsetBy: -1)
        
        let path = item.floderPath[index...index2]
        
        
        //导入
        
        self.xmlTool.changeXMLRootElementProperty(targetXMLPath: item.modulePath + "/subs/模块/01.导入/datafile.xml", addProperty: "\(path)/导入" )
        
        //内容
        
        self.xmlTool.changeXMLRootElementProperty(targetXMLPath: item.modulePath + "/subs/模块/02.内容/datafile.xml", addProperty: "\(path)//内容" )
    
    }
    
    
    //《《《《《《《《《《《《《《《《《  区位模块重构测试  《《《《《《《《《《《//
    
    private func appointModuleSequence(modulePath path:String,sequencePath sequence:String, parentModuleID parentID:String?){
        
        var sequencePath = "序列帧/区位"
        
        if let str = parentID {
            
            if sequence == "logo" || sequence == "背景"{
                
                sequencePath = sequencePath + "/\(str)"
                
            }else{
                
                sequencePath = sequencePath + "/\(str)" + "/模块"
                
            }
        }
        
        //导入
        
        self.xmlTool.changeXMLRootElementProperty(targetXMLPath: path + "/subs/模块/01.导入/datafile.xml", addProperty: sequencePath + "/\(sequence)/导入" )
        
        //内容
        
        self.xmlTool.changeXMLRootElementProperty(targetXMLPath: path + "/subs/模块/02.内容/datafile.xml", addProperty: sequencePath + "/\(sequence)/内容" )
    }
    
    //创建区位序列文件
    private func createTrafficSequenceFloder(source folderSource:Array<SequenceModule>,savePath path:String,parentModule parentMod:SequenceModule?){
        
        if folderSource.count == 0 {
            
            return
        }
        
        for item in folderSource {
            
            if item.isLeaf {
                
                self.moduleFileManager.copyFile(from: TRAFFICSUBFOLDER_RESOURCE_PATH, to: (parentMod?.floderPath)! + "/\(item.moduleID)")
                
                
            }else{
            
                if let parentModule = parentMod {
                    
                    item.floderPath = parentModule.floderPath + "/模块" + "/\(item.moduleID)"
                    
                    self.moduleFileManager.createDirectory(item.floderPath)
                    
                }else{
                    
                    let itemPath = path + "/" + item.moduleID
                    
                    self.moduleFileManager.copyFile(from: TRAFFICROOTFOLDER_RESOURCE_PATH, to: itemPath )
                    
                    item.floderPath = itemPath
                }
                
                self.createTrafficSequenceFloder(source: item.leafModules, savePath: path, parentModule: item)
            
            }
            /**
            
            if let parentModule = parentMod {
                
                self.moduleFileManager.copyFile(from: TRAFFICSUBFOLDER_RESOURCE_PATH, to: parentModule.modulePath + "/模块" + "/\(item.moduleID)")
                
            }else{
                
                let itemPath = path + "/" + item.moduleID
                
                self.moduleFileManager.copyFile(from: TRAFFICROOTFOLDER_RESOURCE_PATH, to: itemPath )
                
                item.modulePath = itemPath
                
                self.createTrafficSequenceFloder(source: item.leafModules, savePath: path, parentModule: item)
                
                if item.isLeaf {
                    
                    self.moduleFileManager.copyFile(from: TRAFFICSUBFOLDER_RESOURCE_PATH, to: itemPath + "/模块" + "/\(item.moduleID)")
                }
            
            
             }
             **/
            
        }
    }
    
    private func createModuleAndAddID(from pathFrom:String,to pathTo:String,AndItemID item:String){
        
        //创建模块
        self.moduleFileManager.copyFile(from: pathFrom, to: pathTo)
        
        //命名模块ID
//        self.xmlTool.addXMLFileElement(targetXMLPath: pathTo + "/config.xml", addProperty: item)
        self.xmlTool.addXMLFileElement(targetXMLPath: pathTo + "/config.xml", addProperty: item, withElementName: "id")
        
    }
    
    private func createModuleAndAddName(from pathFrom:String,to pathTo:String,AndItemName item:String){
        
        //创建模块
        self.moduleFileManager.copyFile(from: pathFrom, to: pathTo)
        
        //命名模块Name
        //        self.xmlTool.addXMLFileElement(targetXMLPath: pathTo + "/config.xml", addProperty: item)
        self.xmlTool.addXMLFileElement(targetXMLPath: pathTo + "/config.xml", addProperty: item, withElementName: "name")
        
    }
    
    
}

extension ViewController:NSMenuDelegate{

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        menu.addItem(NSMenuItem.init(title: "删除", action: #selector(remove), keyEquivalent: ""))
        
    }
    
    func remove(menu:NSMenu) {
        
        guard let clickModule = self.moduleListOutlineView.item(atRow: self.moduleListOutlineView.clickedRow) as? SequenceModule else { return
        
        }
        
        if clickModule.parentModule == nil {//没有父模块
            
            if self.dataSource.contains(clickModule) {
                
                let index = self.dataSource.index(of: clickModule)
                
                self.dataSource.remove(at: index!)
                
            }
    
        }else{
            
            if (clickModule.parentModule?.leafModules.contains(clickModule))! {
                
                let index = clickModule.parentModule?.leafModules.index(of: clickModule)
                
                clickModule.parentModule?.leafModules.remove(at: index!)
                
                if clickModule.parentModule?.leafModules.count == 0 {
                    
                    clickModule.parentModule?.isLeaf = true
                }
                
            }
            
        
        }
        
        self.moduleListOutlineView.reloadData()
        
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
    
    //删除
    public func outlineView(_ outlineView: NSOutlineView, didRemove rowView: NSTableRowView, forRow row: Int) {
        
        
        
    }
    
    //点击列的表头
    public func outlineView(_ outlineView: NSOutlineView, didClick tableColumn: NSTableColumn) {
        
    }
    
    public func outlineView(_ outlineView: NSOutlineView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        
        return proposedSelectionIndexes
    }
    
    
}

