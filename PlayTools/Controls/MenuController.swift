/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Menu construction extensions for this sample.
 */

import UIKit

class RotateViewController: UIViewController {
    static let orientationList: [UIInterfaceOrientation] = [
        .landscapeLeft, .portrait, .landscapeRight, .portraitUpsideDown]
    static var orientationTraverser = 0

    static func rotate() {
        orientationTraverser += 1
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        RotateViewController.orientationList[
            RotateViewController.orientationTraverser % RotateViewController.orientationList.count]
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }
    override var modalPresentationStyle: UIModalPresentationStyle { get {.fullScreen} set {} }
}

extension UIApplication {
    @objc
    func switchEditorMode(_ sender: AnyObject) {
        EditorController.shared.switchMode()
    }

    @objc
    func removeElement(_ sender: AnyObject) {
        EditorController.shared.removeControl()
    }

    @objc
    func upscaleElement(_ sender: AnyObject) {
        EditorController.shared.focusedControl?.resize(down: false)
    }

    @objc
    func downscaleElement(_ sender: AnyObject) {
        EditorController.shared.focusedControl?.resize(down: true)
    }

    @objc
    func setIOSDeviceModelToIPad6_7(_ sender: AnyObject) {
        PlaySettings.shared.settingsData.iosDeviceModel = "iPad6,7"
    }

    @objc
    func setIOSDeviceModelToIPad8_6(_ sender: AnyObject) {
        PlaySettings.shared.settingsData.iosDeviceModel = "iPad8,6"
    }
}

extension UIViewController {
    @objc
    func rotateView(_ sender: AnyObject) {
        RotateViewController.rotate()
        let viewController = RotateViewController(nibName: nil, bundle: nil)
        self.present(viewController, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.dismiss(animated: true)
        })
    }
}

struct CommandsList {
    static let KeymappingToolbox = "keymapping"
}

var keymapping = ["Open/Close Keymapping Editor",
                  "Delete selected element",
                  "Upsize selected element",
                  "Downsize selected element",
                  "Rotate display area"]
var keymappingSelectors = [#selector(UIApplication.switchEditorMode(_:)),
                           #selector(UIApplication.removeElement(_:)),
                           #selector(UIApplication.upscaleElement(_:)),
                           #selector(UIApplication.downscaleElement(_:)),
                           #selector(UIViewController.rotateView(_:))]

class MenuController {
    init(with builder: UIMenuBuilder) {
        builder.insertSibling(MenuController.keymappingMenu(), afterMenu: .view)
        builder.insertSibling(MenuController.graphicsDisplayMenu(), afterMenu: .keymappingMenu)
    }

    class func keymappingMenu() -> UIMenu {
        let keyCommands = [ "K", UIKeyCommand.inputDelete, UIKeyCommand.inputUpArrow, UIKeyCommand.inputDownArrow, "R" ]

        let arrowKeyChildrenCommands = zip(keyCommands, keymapping).map { (command, btn) in
            UIKeyCommand(title: btn,
                         image: nil,
                         action: keymappingSelectors[keymapping.firstIndex(of: btn)!],
                         input: command,
                         modifierFlags: .command,
                         propertyList: [CommandsList.KeymappingToolbox: btn]
            )
        }

        let arrowKeysGroup = UIMenu(title: "",
                                    image: nil,
                                    identifier: .keymappingOptionsMenu,
                                    options: .displayInline,
                                    children: arrowKeyChildrenCommands)
        return UIMenu(title: NSLocalizedString("Keymapping", comment: ""),
                      image: nil,
                      identifier: .keymappingMenu,
                      options: [],
                      children: [arrowKeysGroup])
    }

    class func graphicsDisplayMenu() -> UIMenu {
        let deviceModelCommands = [UIKeyCommand(title: "iPad6,7",
                                                image: nil,
                                                action: #selector(UIApplication.setIOSDeviceModelToIPad6_7(_:)),
                                                input: "1",
                                                modifierFlags: .command,
                                                propertyList: nil),
                                   UIKeyCommand(title: "iPad8,6",
                                                image: nil,
                                                action: #selector(UIApplication.setIOSDeviceModelToIPad8_6(_:)),
                                                input: "2",
                                                modifierFlags: .command,
                                                propertyList: nil)]

        let deviceModelGroup = UIMenu(title: "",
                                      image: nil,
                                      identifier: .deviceMenu,
                                      options: .displayInline,
                                      children: deviceModelCommands)

        return UIMenu(title: NSLocalizedString("Device", comment: ""),
                      image: nil,
                      identifier: .graphicsDisplayMenu,
                      options: [],
                      children: [deviceModelGroup])
    }
}

extension UIMenu.Identifier {
    static var keymappingMenu: UIMenu.Identifier { UIMenu.Identifier("io.playcover.PlayTools.menus.editor") }
    static var keymappingOptionsMenu: UIMenu.Identifier { UIMenu.Identifier("io.playcover.PlayTools.menus.keymapping") }
    static var graphicsDisplayMenu: UIMenu.Identifier { UIMenu.Identifier("io.playcover.PlayTools.menus.graphicsdp") }
    static var deviceMenu: UIMenu.Identifier { UIMenu.Identifier("io.playcover.PlayTools.menus.device") }
}
