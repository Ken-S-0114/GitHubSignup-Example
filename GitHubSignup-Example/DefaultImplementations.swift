//
//  DefaultImplementations.swift
//  GitHubSignup-Example
//
//  Created by 佐藤賢 on 2018/09/25.
//  Copyright © 2018年 佐藤賢. All rights reserved.
//
import RxSwift
import Foundation

class GitHubDefaultValidationService: GitHubValidationService {
    let API: GitHubAPI
    static let sharedValidationService = GitHubDefaultValidationService(API: GitHubDefaultAPI.sharedAPI)

    init(API: GitHubAPI) {
        self.API = API
    }

    let minPasswordCount = 5

    func validateUsername(_ username: String) -> Observable<ValidationResult> {
        if username.isEmpty {
            // .just: これを宣言すると引数がこの場合は ValidationResult から Observable<ValidationResult> に変わる
            return .just(.empty)
        }

        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "Username can only contain numbers or digits"))
        }

        let loadingValue = ValidationResult.validating

        return API
            .usernameAvailable(username)
            .map { available in
                if available {
                    return .ok(message: "Username available")
                } else {
                    return .failed(message: "Username already taken")
                }

            }
            // .startWith: 先頭に指定した値(loadingValue)を発行するイベントを付け加える
            .startWith(loadingValue)
    }

    func validatePassword(_ password: String) -> ValidationResult {
        let numberOfCharacters = password.count
        if numberOfCharacters == 0 {
            return .empty
        }

        if numberOfCharacters < minPasswordCount {
            return .failed(message: "Password must be at least \(minPasswordCount) characters")
        }

        return .ok(message: "Password acceptable")
    }

    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult {
        if repeatedPassword.count == 0 {
            return .empty
        }

        if repeatedPassword == password {
            return .ok(message: "Password repeated")
        } else {
            return .failed(message: "Password different")
        }
    }
}

class GitHubDefaultAPI: GitHubAPI {
    let URLSessionForGitHub: URLSession
    static let sharedAPI = GitHubDefaultAPI(URLSessionForGitHub: URLSession.shared)

    init(URLSessionForGitHub: URLSession) {
        self.URLSessionForGitHub = URLSessionForGitHub
    }

    func usernameAvailable(_ username: String) -> Observable<Bool> {
        let url = URL(string: "https://github.com/\(username.URLEscaped)")!
        let request = URLRequest(url: url)
        return self.URLSessionForGitHub.rx.response(request: request)
            .map { pair in
                return pair.response.statusCode == 404
            }
            // errorが流れてきたら、errorを引数で渡した値のnextイベントに変換する。その後completeを自動で流し、Observableを終了する。
            .catchErrorJustReturn(false)
    }

    func signup(_ username: String, password: String) -> Observable<Bool> {
        let signupResult = arc4random() % 5 == 0 ? true : false
        // .just: これを宣言すると引数がこの場合は Int から Observable<Int> に変わる
        return Observable.just(signupResult).delay(1.0, scheduler: MainScheduler.instance)
    }
}
