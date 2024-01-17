//
//  ChatView.swift
//  ChatBot
//
//  Created by 김경록 on 1/14/24.
//

import UIKit

final class ChatView: UIView {
    
    // MARK: - CollectionView Section
    enum Section {
        case main
    }
    
    // MARK: - properties
    
    private var userContentStorage = [Message]()
    
    private lazy var textViewMaxHeightConstraint: NSLayoutConstraint = contentTextView.heightAnchor.constraint(equalToConstant: self.frame.height / 9)
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Message> = makeDataSource()
    
    private lazy var chatCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.keyboardDismissMode = .onDrag
        collectionView.register(ChatCollectionViewCell.self, forCellWithReuseIdentifier: ChatCollectionViewCell.reuseIdentifier)
        addSubview(collectionView)
        
        return collectionView
    }()
    
    private lazy var contentTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.layer.cornerRadius = 12
        textView.layer.borderColor = UIColor.systemCyan.cgColor
        textView.layer.borderWidth = 1.0
        textView.backgroundColor = .white
        textView.textContainerInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
    }()
    
    private lazy var contentSendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.message"), for: .normal)
        button.tintColor = UIColor.systemCyan
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(submitUserAnswer), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            contentTextView,contentSendButton
        ])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        return stackView
    }()
    
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private methods
    private func makeCollectionViewLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 10
        let estimatedHeight: CGFloat = 50
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .estimated(estimatedHeight))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitem: item, count: 1)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Message> {
        let cellRegistration = UICollectionView.CellRegistration<ChatCollectionViewCell, Message> { (cell, indexPath, identifier) in
            
            cell.configureBubbles(identifier: identifier)
        }
        
        dataSource =  UICollectionViewDiffableDataSource<Section, Message>(collectionView: chatCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Message) -> UICollectionViewCell? in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
            
            return cell
        }
        
        var snapShot = NSDiffableDataSourceSnapshot<Section, Message>()
        snapShot.appendSections([.main])
        dataSource.apply(snapShot, animatingDifferences: false)
        
        return dataSource
    }
    
    private let chatUIItem = Message(role: "indicator", content: "메세지 수신중..(임시)")
    
    private func updateSnapshot(item: [Message], isFetched: Bool) {
        var snapShot = dataSource.snapshot()
        
        if isFetched {
            snapShot.deleteItems([chatUIItem])
            dataSource.apply(snapShot, animatingDifferences: true)
        }
        
        snapShot.appendItems(item)
        dataSource.apply(snapShot, animatingDifferences: true)
    }
    
    private func configureLayout() {
        self.backgroundColor = .white
        NSLayoutConstraint.activate([
            contentTextView.widthAnchor.constraint(equalTo: contentSendButton.widthAnchor, multiplier: 6),
            
            chatCollectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            chatCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chatCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: chatCollectionView.bottomAnchor, constant: 3),
            contentStackView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor, constant: -5),
            contentStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 50),
            contentStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func submitUserAnswer() {
        guard let userMessage = contentTextView.text else {
            return
        }
        configureTextView()
        contentSendButton.isEnabled.toggle()
        let snapShotItems = [Message(role: "user", content: userMessage), chatUIItem]
        
        updateSnapshot(item: snapShotItems, isFetched: false)
        scrollToBottom()
        guard let endpoint = buildEndpoint(userMessage) else {
            return
        }
        
        NetworkingManager.shared.downloadData(request: endpoint.generateRequest(),
                                              to: AIContentModel.self) { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.updateSnapshot(item: [data.choices[0].message], isFetched: true)
                    self.contentSendButton.isEnabled.toggle()
                    self.scrollToBottom()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func buildEndpoint(_ userMessage: String) -> Endpointable? {
        guard let apiKey = Bundle.getAPIKey(for: APIKeyName.openAI.description) else {
            return nil
        }
        
        guard let url = URL(string: BaseURL.openAI.description) else {
            return nil
        }
        
        let newMessage = Message(role: UserContentConstant.userRole, content: userMessage)
        
        userContentStorage.append(newMessage)

        let body = UserContentModel(messages: userContentStorage)
        let header: [String: String] = [HeaderFieldName.contentType.description : ContentType.json.description,
                                        HeaderFieldName.authorization.description : "Bearer \(apiKey)"]
        let endpoint: Endpointable = ChatBotEndpoint(url: url, httpMethod: .post, httpHeader: header, httpBody: body)
        
        return endpoint
    }
    
    private func scrollToBottom() {
        let lastItemIndex = chatCollectionView.numberOfItems(inSection: 0) - 1
        if lastItemIndex < 0 {
            return
        }
        
        let indexPath = IndexPath(item: lastItemIndex, section: 0)
        chatCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    private func configureTextView() {
        resetTextViewHeight()
        contentTextView.isScrollEnabled = false
        contentTextView.text = nil
    }
    
    // MARK: - Public Method
    
    func setTextViewDelegate(_ delegate: UITextViewDelegate) {
        contentTextView.delegate = delegate
    }
    
    func limitTextViewHeight() {
        textViewMaxHeightConstraint.isActive = true
    }
    
    func resetTextViewHeight() {
        textViewMaxHeightConstraint.isActive = false
    }
}
