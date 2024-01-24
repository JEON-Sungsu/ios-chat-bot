//
//  ViewController.swift
//  ChatBot
//
//  Created by Tacocat on 1/1/24.
//

import UIKit

final class ChatRoomViewController: UIViewController {
    
    // MARK: - properties
    
    private let chatView = ChatView()
    private var endPoint: Endpointable = ChatBotEndpoint()
    private var historyMessages: [Message] = [Message]()
    
    // MARK: - view life cycle
    
    override func loadView() {
        self.view = chatView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToHideKeyboard()
        configureDelegate()
    }
}

// MARK: - private methods

extension ChatRoomViewController {
    
    private func addTapGestureToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func configureDelegate() {
        chatView.setTextViewDelegate(self)
        chatView.delegate = self
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func showAlert(title: String, message: String, completionHandler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: completionHandler)
        alert.addAction(action)
        self.present(alert, animated: true)
    }
}

// MARK: - Delegate methods

extension ChatRoomViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView.contentSize.height < view.frame.height * 0.1
        else {
            textView.isScrollEnabled = true
            return
        }
        
        textView.isScrollEnabled = false
        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height { constraint.constant = textView.estimatedSizeHeight
            }
        }
    }
}

extension ChatRoomViewController: ChatViewDelegate {
    
    func blankCheckTextView(of chatView: ChatView) {
        showAlert(title: "메세지를 입력해주세요", message: "")
    }
    
    func submitUserMessage(chatView: ChatView, animationData: Message, userMessage: String) {
        let newMessage = Message(role: RequestBodyConstant.userRole, content: userMessage)
        historyMessages.append(newMessage)
        
        endPoint.httpBodyContent.messages = historyMessages
        
        let snapShotItems = [newMessage, animationData]
        chatView.updateSnapshot(items: snapShotItems, isFetched: false)
        chatView.scrollToBottom()
        
        NetworkingManager.shared.downloadData(endpoint: endPoint,
                                              to: AIContentModel.self) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    chatView.updateSnapshot(items: [data.choices[0].message], isFetched: true)
                    chatView.toggleSendButton()
                    chatView.scrollToBottom()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showAlert(title: "에러가 발생하였습니다", message: "\(error) 앱을 종료합니다") {_ in
                        exit(0)
                    }
                }
            }
        }
    }
}
