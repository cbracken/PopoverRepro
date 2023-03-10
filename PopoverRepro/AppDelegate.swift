import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  private var statusBar: StatusBarController?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let popover = NSPopover()
    popover.contentSize = NSSize(width: 360.0, height: 360.0)
    popover.contentViewController = MyViewController()
    statusBar = StatusBarController.init(popover)
  }
}
