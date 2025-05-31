//
//  Clipboard_TimelineApp.swift
//  Clipboard Timeline
//
//  Created by romeo on 30/5/2568 BE.
//
import Cocoa
import ApplicationServices
import SwiftUI

@main
struct Clipboard_TimelineApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var clipboardMonitor: ClipboardMonitor?
    var globalMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        requestAccessibilityPermissionIfNeeded()
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.command) && event.modifierFlags.contains(.option) && event.keyCode == 9 {
                DispatchQueue.main.async {
                    ClipboardPopupManager.shared.showPopup()
                }
            }
        }
        
        // init clipboard Monitor
        clipboardMonitor = ClipboardMonitor()

        // Status Bar Item
        statusItem = NSStatusBar.system.statusItem(
            withLength: NSStatusItem.variableLength
        )
        if let button = statusItem.button {
            button.image = resizedIcon
            button.action = #selector(togglePopover(_:))
        }

        popover = NSPopover()
        popover.contentSize = NSSize(width: 350, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: ContentView()
        )

        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(
                    relativeTo: button.bounds,
                    of: button,
                    preferredEdge: .minY
                )
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }

    private var resizedIcon: NSImage {
        if let loadedImage = NSImage(named: "logo") {
            let ratio = loadedImage.size.height / loadedImage.size.width
            loadedImage.size.height = 29
            loadedImage.size.width = 21 / ratio
            return loadedImage
        } else {
            return NSImage()
        }
    }
    
    func requestAccessibilityPermissionIfNeeded() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let accessibilityEnabled = AXIsProcessTrustedWithOptions(options)
        if !accessibilityEnabled {
            print("⚠️ Accessibility Permission Not Enabled.")
        } else {
            print("✅ Accessibility Permission OK.")
        }
    }
}

//class AppDelegate: NSObject, NSApplicationDelegate {
//    static private(set) var instance: AppDelegate!
//    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
//    let menu = ApplicationMenu()
//
//    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        AppDelegate.instance = self
//        statusBarItem.button?.image = NSImage(named: NSImage.Name("logo"))
//        statusBarItem.button?.imagePosition = .imageLeading
//        statusBarItem.menu = menu.createMenu()
//    }
//}
