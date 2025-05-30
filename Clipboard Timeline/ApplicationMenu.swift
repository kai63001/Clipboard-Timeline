//
//  ApplicationMenu.swift
//  Clipboard Timeline
//
//  Created by romeo on 30/5/2568 BE.
//

import Foundation
import SwiftUI

class ApplicationMenu: NSObject {
    let menu = NSMenu()

    func createMenu() -> NSMenu {
        let clipboardView = ContentView()
        let topView = NSHostingController(rootView: clipboardView)
        topView.view.frame.size = NSSize(width: 480, height: 300)
        
        let customMenuItem = NSMenuItem()
        customMenuItem.view = topView.view
        menu.addItem(customMenuItem)
        return menu
    }
    
}
