//
//  GithubSignupViewModel1.swift
//  GitHubSignup-Example
//
//  Created by 佐藤賢 on 2018/09/25.
//  Copyright © 2018年 佐藤賢. All rights reserved.
//

import RxSwift

class GithubSignupViewModel1 {
    init(input: (
            username: Observable<String>,
            password: Observable<String>,
            repeatedPassword: Observable<String>,
            loginTaps: Observable<Void>
        ),
         dependency: (
            API: GitHubAPI,
            validationServer: GitHubValidationService,
            wireframe: Wireframe
        )
        ) {
        let API = dependency.API
        let validationServer = dependency.validationServer
        let wireframe = dependency.wireframe
    }
}
