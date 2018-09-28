//
//  GitHubSignupViewController1.swift
//  GitHubSignup-Example
//
//  Created by 佐藤賢 on 2018/09/25.
//  Copyright © 2018年 佐藤賢. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GitHubSignupViewController1: UIViewController {

    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!

    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!

    @IBOutlet weak var repeatedPasswordOutlet: UITextField!
    @IBOutlet weak var repeatedPasswordValidationOutlet: UILabel!

    @IBOutlet weak var signupOutlet: UIButton!
    @IBOutlet weak var signingUpOutlet: UIActivityIndicatorView!


    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // // Outletの要素をすべてViewModelにInitializeする引数に渡している
        let viewModel = GithubSignupViewModel1(
            input: (
                username: usernameOutlet.rx.text.orEmpty.asObservable(),
                password: passwordOutlet.rx.text.orEmpty.asObservable(),
                repeatedPassword: repeatedPasswordOutlet.rx.text.orEmpty.asObservable(),
                loginTaps: signupOutlet.rx.tap.asObservable()
            )
            , dependency: (
                API: GitHubDefaultAPI.sharedAPI,
                validationServer: GitHubDefaultValidationService.sharedValidationService,
                wireframe: DefaultWireframe.shared
            )
        )

        viewModel.signupEnable
            .subscribe(onNext: { [weak self] vaild in
                self?.signupOutlet.isEnabled = vaild
                self?.signupOutlet.alpha = vaild ? 1.0 : 0.5
                })
            .disposed(by: disposeBag)
        // ユーザー名入力チェック（登録可能ユーザー名か、すでに登録済か）
        viewModel.validatedUsername
            .bind(to: usernameValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        // パスワード入力チェック（パスワードの長さが一定以上か）
        viewModel.validatedPassword
            .bind(to: passwordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        // 再入力パスワードが一致しているかどうか
        viewModel.validatedPasswordRepeated
            .bind(to: repeatedPasswordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        // ログインアクション実行
        viewModel.signingIn
            .bind(to: signingUpOutlet.rx.isAnimating)
            .disposed(by: disposeBag)
        // ログイン成功時
        viewModel.signedIn
            .subscribe(onNext: { signedIn in
                print("User signed in \(signedIn)")
            })
            .disposed(by: disposeBag)
    }


}

