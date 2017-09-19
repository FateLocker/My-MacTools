//
//  ViewController.swift
//  SequenceManager
//
//  Created by Hu on 2017/8/22.
//  Copyright © 2017年 xx. All rights reserved.
//

import Cocoa
import SWXMLHash

class ViewController: NSViewController {
    
    var i = 1
    
    let moduleFileManager = ModuleFileManger.shareInstance
    
    let resourcePath = Bundle.main.bundlePath + "/Contents/Resources/ModuleTemplate"
    
    var dataSource:[SequenceModule] = {
        
        var module1 = SequenceModule("区域沙盘")
        module1.isLeaf = true
        var module2 = SequenceModule("项目沙盘")
        module2.isLeaf = true
        var module3 = SequenceModule("单体1")
        module3.isLeaf = true
        
        var modules1 = SequenceModule("沙盘1")
        var modules2 = SequenceModule("沙盘2")
        
        modules1.leafModules = [module1,module2,module3]
        modules1.isLeaf = false
        
        modules2.leafModules = [module1,module2,module3]
        modules2.isLeaf = false
        
        return [modules1,modules2]
    }()
    
    @IBOutlet weak var moduleListOutlineView: NSOutlineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    @IBAction func saveModule(_ sender: Any) {
        
        let panel = NSSavePanel()
        
        panel.directoryURL = NSURL(string: moduleFileManager.getDesktopPath()) as URL?
        
        panel.allowsOtherFileTypes = true
        
        panel.canCreateDirectories = true
        
        panel.begin { (result) in
            
            if result == NSFileHandlingPanelOKButton {
            
                let path = panel.url!.path
                
                self.moduleFileManager.createDirectory(path)
                
            }
            
        }
        
    }
    
    ///添加模块
    @IBAction func addSubModule(_ sender: NSButton) {
        
        let module1 = SequenceModule("区域沙盘")
        module1.isLeaf = true
        let module2 = SequenceModule("项目沙盘")
        module2.isLeaf = true
        let module3 = SequenceModule("单体1")
        module3.isLeaf = true
        
        let modules = SequenceModule("沙盘3")
        
        modules.leafModules = [module1,module2,module3]
        modules.isLeaf = false
        
        self.dataSource.append(modules)
        
        self.moduleListOutlineView.reloadData()
        
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
        
        if let outlineView = notification.object as? NSOutlineView {
            
            print("column: \(outlineView.selectedTag()) And row: \(outlineView.selectedRow)" )
            
        }
    }
    
    public func outlineView(_ outlineView: NSOutlineView, didClick tableColumn: NSTableColumn) {
        
        print("click")
        
    }
    
    public func outlineView(_ outlineView: NSOutlineView, selectionIndexesForProposedSelection proposedSelectionIndexes: IndexSet) -> IndexSet {
        
        return proposedSelectionIndexes
    }
    
    
}

