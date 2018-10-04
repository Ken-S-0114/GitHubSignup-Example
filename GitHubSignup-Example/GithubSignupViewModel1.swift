//
//  GithubSignupViewModel1.swift
//  GitHubSignup-Example
//
//  Created by 佐藤賢 on 2018/09/25.
//  Copyright © 2018年 佐藤賢. All rights reserved.
//

import RxSwift
import RxCocoa

class GithubSignupViewModel1 {

    let validatedUsername: Observable<ValidationResult>
    let validatedPassword: Observable<ValidationResult>
    let validatedPasswordRepeated: Observable<ValidationResult>

    let signupEnable: Observable<Bool>
    let signedIn: Observable<Bool>
    let signingIn: Observable<Bool>

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

        validatedUsername = input.username
            // flatMapLatest = map(Observableの形を変換）＋switchLatest(最新のinnerObservable: 入れ子になったObservableの中身のものを取り出してemitする)
            // で求めたFlatなObservableが作り出せる
            .flatMapLatest { username in
            return validationServer.validateUsername(username)
                .observeOn(MainScheduler.instance)
                .catchErrorJustReturn(.failed(message: "Error contacting server"))
            }
            // validatedUsernameがsubscribeされるたびに何度も実行されるのを防ぐため
            .share(replay: 1)

        validatedPassword = input.password
            // map: Observableの型を変換
            .map { password in
                return validationServer.validatePassword(password)
            }
            .share(replay: 1)

        validatedPasswordRepeated = Observable
            // 最新のObservableを一つに合成する
            .combineLatest(input.password, input.repeatedPassword, resultSelector: validationServer.validateRepeatedPassword)
            .share(replay: 1)

        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asObservable()

        let usernameAndPassword = Observable.combineLatest(input.username, input.password) { (username: $0, password: $1) }

        signedIn = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest { pair in
                return API.signup(pair.username, password: pair.password)
                        .observeOn(MainScheduler.instance)
                        .catchErrorJustReturn(false)
                        .trackActivity(signingIn)
            }
            .flatMapLatest { loggedIn -> Observable<Bool> in
                let message = loggedIn ? "Mock: Signed in to GitHub." : "Mock: Sign in to GitHub failed"
                // alertViewのframeを作成する
                return wireframe.promptFor(message, cancelAction: "OK", actions: [])
                    .map { _ in
                        // mapで最終的にはlogin成功か失敗のObservable<Bool>の形で返却
                        loggedIn
                }
        }
        .share(replay: 1)

        signupEnable = Observable.combineLatest(
                            validatedUsername,
                            validatedPassword,
                            validatedPasswordRepeated,
                            signingIn.asObservable()
        ) { username, password, repeatPassword, signingIn in
            username.isValid &&
            password.isValid &&
            repeatPassword.isValid &&
            !signingIn
        }
        .distinctUntilChanged()
        .share(replay: 1)
    }
}
