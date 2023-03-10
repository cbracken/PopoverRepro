import Cocoa

/// Registers an NSStatusItem in the menu bar that, when clicked, opens an
/// NSPopover containing a MyView.
class StatusBarController {
  private var statusBar: NSStatusBar
  private var statusItem: NSStatusItem
  private var popover: NSPopover

  init(_ popover: NSPopover) {
    self.popover = popover
    statusBar = NSStatusBar.init()
    statusItem = statusBar.statusItem(withLength: 28.0)
    if let statusButton = statusItem.button {
      statusButton.image = #imageLiteral(resourceName: "Image")
      statusButton.image?.size = NSSize(width: 18.0, height: 18.0)
      statusButton.image?.isTemplate = true
      statusButton.action = #selector(togglePopover(sender:))
      statusButton.target = self
    }
  }

  @objc func togglePopover(sender: AnyObject) {
    if popover.isShown {
      hidePopover(sender)
    } else {
      showPopover(sender)
    }
  }

  func showPopover(_ sender: AnyObject) {
    if let statusButton = statusItem.button {
      popover.show(relativeTo: statusButton.bounds,
                   of: statusButton,
                   preferredEdge: NSRectEdge.maxY)

      // Dump the responder chain for the view.
      printResponderChain(from: popover.contentViewController?.view)
    }
  }

  func hidePopover(_ sender: AnyObject) {
    popover.performClose(sender)
  }

  /// Walk the responder chain starting at the specified responder and printing
  /// each one.
  func printResponderChain(from responder: NSResponder?) {
    var responder = responder
    print("###### Responder chain ######")
    while let r = responder {
      print(r)
      responder = r.nextResponder
    }
    print("#############################")
  }
}
