//
//  PreviewViewController.swift
//  SwatchesReaderQuickLook
//
//  Created by Viktor Goltvyanytsya on 13.03.2021.
//

import UIKit
import QuickLook
import os.log






class PreviewViewController: UIViewController, QLPreviewingController {
    
    private var palette: CPSwatchesPalette
    
    lazy var table: UITableView = {
        let tableView = UITableView()
        tableView.register(SwatchCell.self, forCellReuseIdentifier: "swatchCell")
        tableView.rowHeight = 70
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    var tableConstraints: [NSLayoutConstraint]  {
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: self.table, attribute: .left, relatedBy: .equal,
                                              toItem: self.view, attribute: .left, multiplier: 1.0, constant: 1.0))
        constraints.append(NSLayoutConstraint(item: self.table, attribute: .right, relatedBy: .equal,
                                              toItem: self.view, attribute: .right, multiplier: 1.0, constant: 1.0))
        constraints.append(NSLayoutConstraint(item: self.table, attribute: .top, relatedBy: .equal,
                                              toItem: self.view, attribute: .top, multiplier: 1.0, constant: 1.0))
        constraints.append(NSLayoutConstraint(item: self.table, attribute: .bottom, relatedBy: .equal,
                                              toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 1.0))
        return constraints
    }
    
    deinit {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.palette = CPSwatchesPalette.empty
        super.init(coder: aDecoder)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(table)
        NSLayoutConstraint.activate(tableConstraints)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     * Implement this method and set QLSupportsSearchableItems to YES in the Info.plist of the extension if you support CoreSpotlight.
     *
    func preparePreviewOfSearchableItem(identifier: String, queryString: String?, completionHandler handler: @escaping (Error?) -> Void) {
        // Perform any setup necessary in order to prepare the view.
        
        // Call the completion handler so Quick Look knows that the preview is fully loaded.
        // Quick Look will display a loading spinner while the completion handler is not called.
        handler(nil)
    }
    */

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        
        do {
            guard let typeID = try url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier else { return }
            
            guard let supertypes = UTType(typeID)?.supertypes else {
                Logger.appLogger.error("Unknown UTType of the url: \(url)")
                handler(nil)
                return
            }
            
            if supertypes.contains(.GPLDocumentType) {
                Logger.appLogger.debug("GPL url: \(url)")
            }
        } catch {
            Logger.appLogger.error("QuickLook Error: \(error.localizedDescription)")
            handler(nil)
            return
        }
        
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        guard let fileData = try? Data(contentsOf: url) else {
            Logger.appLogger.error("Data is not readable, url: \(url)")
            if(didStartAccessing){
                url.stopAccessingSecurityScopedResource()
            }
            handler(nil)
            return
        }
        
        if(didStartAccessing){
            url.stopAccessingSecurityScopedResource()
        }
        
        
        guard let fileRep: CPGPLPaletteFileRepresentation = try? CPGPLPaletteFileRepresentation(data: fileData)else{
            Logger.appLogger.error("ColorPalette is not readable, url: \(url)")
            handler(nil)
            return
        }
        
        self.palette = fileRep.swatchesPalette()
        self.table.reloadData()
        Logger.appLogger.debug("Received \(self.palette)")
        
        handler(nil)
    }

}

extension PreviewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let groups = self.palette.groups()
        guard let group = groups.first else {
            Logger.appLogger.error("First group is empty")
            return 0
        }
        return group.count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "swatchCell", for: indexPath) as! SwatchCell
        
        let groups = self.palette.groups()
        guard let group = groups.first else {
            Logger.appLogger.error("First group is empty")
            cell.swatchName.text = ""
            return cell
        }
        
        let swObj = group.getSwatchAt(index: indexPath.row)
        cell.swatchName.text = swObj.swatch.baseColorName()
        cell.colorString.text = swObj.swatch.baseColorString()
        cell.swatchColor.backgroundColor = swObj.swatch.baseUIColor()
        return cell
    }
}

extension PreviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension UTType {
    static var GPLDocumentType: UTType {
        UTType(importedAs: "org.gimp.gpl")
    }
}
