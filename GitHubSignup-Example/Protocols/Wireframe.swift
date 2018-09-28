//
//  Wireframe.swift
//  GitHubSignup-Example
//
//  Created by 佐藤賢 on 2018/09/25.
//  Copyright © 2018年 佐藤賢. All rights reserved.
//

import Foundation
import RxSwift

protocol Wireframe {
    func open(url: URL)
    func promptFor<Action: CustomStringConvertible>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action>
}

class DefaultWireframe: Wireframe {

    static let shared = DefaultWireframe()
    func open(url: URL) {
        UIApplication.shared.openURL(url)
    }

    private static func rootViewController() -> UIViewController {
        return UIApplication.shared.keyWindow!.rootViewController!
    }

    func promptFor<Action: CustomStringConvertible>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action>  {
        return Observable.create { observer in
            let alertView = UIAlertController(title: "RxExample", message: message, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: cancelAction.description, style: .cancel) { _ in
                observer.on(.next(cancelAction))
            })
            for action in actions {
                alertView.addAction(UIAlertAction(title: action.description, style: .default) { _ in
                    observer.on(.next(action))
                    })
            }

            DefaultWireframe.rootViewController().present(alertView, animated: true, completion: nil)

            return Disposables.create {
                alertView.dismiss(animated: false, completion: nil)
            }
        }
    }
}
