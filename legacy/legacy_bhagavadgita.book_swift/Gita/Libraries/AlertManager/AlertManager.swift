//
//  AlertManager.swift
//  AlertManager
//
//  Created by Mikhail Kulichkov on 19/04/2017.
//  Updated by Stanislav Grinberg on 13 Jun 2017
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

fileprivate class QueuedAlertController {
	
	typealias CompletionBlock = () -> ()
	
	let alertController: UIAlertController
	let animated: Bool
	let completionBlock: CompletionBlock?
	
	init(alertController: UIAlertController, animated: Bool, completionBlock: CompletionBlock?) {
		self.alertController = alertController
		self.animated = animated
		self.completionBlock = completionBlock
	}
	
}

final class AlertManager {
	
	typealias DismissBlock = (Int) -> ()
	
    private static let shared = AlertManager()
    
    private var alertQueue = [QueuedAlertController]()
    
    /**
        * Note:
        The first element in buttons always is Cancel
        * Attention: When using UIAlertController alerts wil be shown ordered accending (1 2 3 .. n).
        When using UIAlertView alerts wil be shown backwards (n .. 3 2 1).
    */
    //MARK: - Public
	
	static func present(title: String = AlertManager.applicationName,
                        message: String,
                        buttons: [String],
                        dismissBlock: @escaping DismissBlock) {
		if #available(iOS 8.0, *) {
			let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

			let dismissControllerBlock = {
				self.abort(animated: true)
			}

			// Default Cancel action
			if buttons.isEmpty {
				let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in dismissControllerBlock() })
				alertController.addAction(actionCancel)
			}

			// Default Cancel will be changed with dismissBlock(0)
			for index in 0..<buttons.count {
				let actionStyle: UIAlertActionStyle = (index == 0) ? .cancel : .default
				let actionButtonTitle = buttons[index]
				let actionDismiss = UIAlertAction(title: actionButtonTitle, style: actionStyle, handler: { _ in dismissBlock(index); dismissControllerBlock() })
				alertController.addAction(actionDismiss)
			}

			performInMainThread {
				shared.present(alertController, animated: true, completionBlock: nil)
			}
		} else {
            let alertView = UIAlertView.alertView(title: title, message: message, buttons: buttons, dismissBlock: dismissBlock)
			performInMainThread {
				alertView.show()
			}
        }
    }
	
	static func abort(animated: Bool) {
		if let currentAlert = shared.alertQueue.first?.alertController {
			currentAlert.dismiss(animated: animated)
			shared.alertQueue.remove(at: 0)
		}
		
		if shared.alertQueue.count != 0 {
			shared.presentFirstQueuedController()
		}
	}
	
	static func abortAll(animated: Bool) {
		if let currentAlert = self.shared.alertQueue.first?.alertController {
			currentAlert.dismiss(animated: animated)
		}
		
		//FIXME: Remove warning "Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior"
		shared.alertQueue.removeAll()
	}

    //MARK: - Private
	
    private func present(_ alertController: UIAlertController, animated: Bool, completionBlock: QueuedAlertController.CompletionBlock?) {
        let queuedAlertController = QueuedAlertController(alertController: alertController, animated: animated, completionBlock: completionBlock)
        alertQueue.append(queuedAlertController)

        if alertQueue.count == 1 {
            presentFirstQueuedController()
		}
    }
	
    private func presentQueuedAlertController(index: Int) {
        let queuedAlertController = alertQueue[index]
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            let targetVC = AlertManager.topViewController(rootViewController: rootVC)
            targetVC.present(queuedAlertController.alertController,
                             animated: queuedAlertController.animated,
                             completion: queuedAlertController.completionBlock)
        }
    }
    
    private func presentFirstQueuedController() {
        presentQueuedAlertController(index: 0)
    }
    
    // MARK: - Helpers
	
    private static func topViewController(rootViewController: UIViewController) -> UIViewController {
        if let presentedVC = rootViewController.presentedViewController {
            return self.topViewController(rootViewController: presentedVC)
        } else if let navVC = rootViewController as? UINavigationController {
            if navVC.viewControllers.count > 0 {
                if let topVC = navVC.topViewController {
                    return self.topViewController(rootViewController: topVC)
                }
            }
        } else if let tabVC = rootViewController as? UITabBarController {
            if let count = tabVC.viewControllers?.count, count > 0 {
                if let selectedVC = tabVC.selectedViewController {
                    return self.topViewController(rootViewController: selectedVC)
                }
            }
        } else if let splitVC = rootViewController as? UISplitViewController {
            if let lastVC = splitVC.viewControllers.last {
                return self.topViewController(rootViewController: lastVC)
            }
        }
        return rootViewController
    }
    
	private static var applicationName: String {
        if let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String, appName.characters.count > 0 {
            return appName
        } else if let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String, appName.characters.count > 0 {
            return appName
        }  else if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String, appName.characters.count > 0 {
            return appName
        }
        return ""
    }
    
    private static func performInMainThread(block: () -> ()) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
    }
	
}
