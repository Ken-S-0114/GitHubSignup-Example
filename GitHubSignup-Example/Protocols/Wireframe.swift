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
    func promptFor<Action: CustomStringConvertible>(_message: String, cancelAction: Action, actions: [Action]) -> Observable<Action>
}
