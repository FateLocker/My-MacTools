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
        
        ROOTMODULE.leafModules = []
        
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
        
        ROOTMODULE.leafModules = []
        
        self.dataSource = ROOTMODULE.leafModules
        
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
            
            ROOTMODULE.leafModules.append(module)
            
            self.dataSource.append(module)
            
            self.moduleListOutlineView.reloadData()
            
            
            return
        }
        
        selectModuleItem.isLeaf = false
        
        selectModuleItem.leafModules.append(module)
        
        module.parentModule = selectModuleItem
        
        self.moduleListOutlineView.reloadData()
        
//        self.moduleListOutlineView.deselectRow(selectRow)
        
        
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
    
        //logo
        self.createModuleAndAddID(from: TRAFFICSUB_RESOURCE_PATH, to: savePath + "/subs/装饰/subs/logo", AndItemID: "")
        
        self.appointModuleSequence(sequenceModule: item)
        
        self.xmlTool.changeNodeElement(XMLFilePath: savePath + "/subs/背景/subs/内容/layout.xml", nodeName: "layout", elementDic: ["whenAppearUpdateLayout":"NO"])
    
    }
    
    
    private func appointModuleSequence(sequenceModule item:SequenceModule){
        
        let path = self.stringTailor(tailar: item.floderPath, withString: ROOTMODULE.floderPath)
        
        if !item.isLeaf || item.parentModule?.moduleID == "RootModule"{
            
            if item.parentModule?.moduleID == "RootModule" {
                
                let path1 = self.stringTailor(tailar: path, withString: "/模块/\(item.moduleID)")
                
                //背景
                
                self.changeLeafModuleSequencePath(modulePath: item.modulePath + "/subs/背景", sequenceFloderPath: "\(path1)/背景")
                
                //logo
                
                self.changeLeafModuleSequencePath(modulePath: item.modulePath + "/subs/装饰/subs/logo", sequenceFloderPath: "\(path1)/logo")
                
                self.changeLeafModuleSequencePath(modulePath:item.modulePath, sequenceFloderPath: path)
                
            }else{
                
                
                //背景
                
                self.changeLeafModuleSequencePath(modulePath: item.modulePath + "/subs/背景", sequenceFloderPath: "\(path)/背景")
                
                //logo
                
                self.changeLeafModuleSequencePath(modulePath: item.modulePath + "/subs/装饰/subs/logo", sequenceFloderPath: "\(path)/logo")
            }
            
            
        }else{
            
            self.changeLeafModuleSequencePath(modulePath: item.modulePath, sequenceFloderPath: path)
        
        
        }
    
    }
    
    //字符串裁剪
    private func stringTailor(tailar originalString:String ,withString segmentString:String) -> String{
        
        guard originalString.contains(segmentString) else {
            
            print("不包含需要裁剪字符串")
            
            return originalString
        }
        
        var originalStr = originalString
        
        let range = (originalString as NSString).range(of: segmentString)
        
        let startIndex = originalString.index(originalString.startIndex, offsetBy: range.location)
        
        let endIndex = originalString.index(originalString.startIndex, offsetBy: (range.location + range.length - 1))
        
        originalStr.removeSubrange(startIndex...endIndex)
        
        return originalStr
    
    }
    
    private func changeLeafModuleSequencePath(modulePath path:String,sequenceFloderPath sequencePath:String){
        
        //导入
        
        self.xmlTool.changeXMLRootElementProperty(targetXMLPath: "/\(path)/subs/模块/01.导入/datafile.xml", addProperty: "\(sequencePath)/导入" )
        
        //内容
        
        self.xmlTool.changeXMLRootElementProperty(targetXMLPath: "/\(path)/subs/模块/02.内容/datafile.xml", addProperty: "\(sequencePath)/内容" )
    
    
    
    }
    
    
    //《《《《《《《《《《《《《《《《《  区位模块重构测试  《《《《《《《《《《《//
    
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
        
        if (clickModule.parentModule?.leafModules.contains(clickModule))! {
            
            let index = clickModule.parentModule?.leafModules.index(of: clickModule)
            
            clickModule.parentModule?.leafModules.remove(at: index!)
            
            if clickModule.parentModule?.moduleID == "RootModule" {
                
                self.dataSource.remove(at: index!)
            }
            
            if clickModule.parentModule?.leafModules.count == 0 {
                
                clickModule.parentModule?.isLeaf = true
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

