## 🖇️ 개요

GPT 3.5를 기반으로 동작하는 채팅 앱
<br><br>
### 🙋 팀원
| [Roks](https://github.com/KimRoks) | [Howard](https://github.com/JEON-Sungsu) |
| --- | --- |
| <img src="https://github.com/JEON-Sungsu/ios-chat-bot/assets/63297236/73c18a04-ed50-44e8-a303-2203cf755dea" width = 150 height = 150 />|<img src="https://github.com/JEON-Sungsu/ios-chat-bot/assets/63297236/0e96b3ea-fded-40f6-aed4-7a902253752b" width=150 height= 150/>| 

<br><br>
### 🗓️ 기간

24.01.02 ~ 24.01.26
<br><br>
## 📁 디렉토리 구조

```
├── ChatBot
│   ├── ApiKeys.plist
│   ├── ChatBot
│   │   ├── Assets.xcassets
│   │   │   ├── AccentColor.colorset
│   │   │   │   └── Contents.json
│   │   │   ├── AppIcon.appiconset
│   │   │   │   └── Contents.json
│   │   │   └── Contents.json
│   │   ├── Base.lproj
│   │   │   └── LaunchScreen.storyboard
│   │   ├── Controller
│   │   │   └── ChatRoomViewController.swift
│   │   ├── Delegate
│   │   │   ├── AppDelegate.swift
│   │   │   └── SceneDelegate.swift
│   │   ├── Enums
│   │   │   ├── Constant
│   │   │   │   └── RequestBodyConstant.swift
│   │   │   ├── Error
│   │   │   │   └── NetworkingError.swift
│   │   │   └── Network
│   │   │       ├── APIName.swift
│   │   │       ├── BaseURL.swift
│   │   │       └── HTTPMethod.swift
│   │   ├── Extensions
│   │   │   ├── ChatBot++Bundle.swift
│   │   │   ├── UITextView++Extension.swift
│   │   │   └── UIView++Extension.swift
│   │   ├── Info.plist
│   │   ├── Models
│   │   │   └── DTO
│   │   │       ├── AIContentModel.swift
│   │   │       ├── Message.swift
│   │   │       └── UserContentModel.swift
│   │   ├── Utility
│   │   │   ├── Endpoint
│   │   │   │   ├── Implementation
│   │   │   │   │   └── ChatBotEndpoint.swift
│   │   │   │   └── Interface
│   │   │   │       └── Endpointable.swift
│   │   │   ├── JSONCoder
│   │   │   │   └── Encoder.swift
│   │   │   └── Network
│   │   │       └── NetworkingManager.swift
│   │   └── View
│   │       ├── ChatView
│   │       │   ├── ChatView.swift
│   │       │   └── CollectionView
│   │       │       ├── Cell
│   │       │       │   ├── ChatBubbleTail.swift
│   │       │       │   ├── ChatCollectionViewCell.swift
│   │       │       │   └── LoadingAnimationView.swift
│   │       │       └── DataSource
│   │       │           └── ChatCollectionViewDataSource.swift

```
<br><br>
## ⭐️ 핵심 구현 내용

- Request 및 Response를 위한 데이터 모델 설계
    - httpMethod POST 사용
- Modern collectionView의 사용
    - diffableDataSource 활용
    - snapShot 활용
    - compositionalLayout 활용
- Protocol을 활용한 모델의 추상화 작업
- Core Graphics 활용
    - 커스텀 UI 제작
- Core Animation 활용
    - 커스텀 애니메이션 제작 (메세지 로딩 애니메이션)
- KeyboardLayout 구현
<br><br>

## 📱 동작화면

| 이름 학습 | 키보드 레이아웃 | 애니메이션 | 
| --- | --- | --- | 
|![rememberName](https://github.com/tasty-code/ios-chat-bot/assets/63297236/e7d8da20-3497-46cf-8187-825df7772c64)| ![keyboardLayout](https://github.com/tasty-code/ios-chat-bot/assets/63297236/e316ec75-9deb-473c-8a8e-0ceedf7c22cc)|![reuseableAnimationETC](https://github.com/tasty-code/ios-chat-bot/assets/63297236/b1b9da8a-6e8a-44ae-a6a5-6150b286c1bd)|

<br><br>

## 🌠 Trouble Shooting

- **Networking 과 관련하여, 각 역할별 객체들의 범용성을 위한 작업**
    - Request를 생성해주는 객체의 범용성을 위한 작업 진행
        - Request생성을 위해 필요한 프로퍼티들, httpMethod, httpHeader, httpBody, APIKey, URL 등을 가지고 있는 객체 Endpoint 를 생성하고, 프로토콜을 사용해서 인터페이스 분리
        - Request를 생성하는 객체는, 이 프로토콜을 채택한 녀석을 파라미터로 받아서 리퀘스트 생성하도록 함
    - 이러한 과정을 거치니, 통신 요청을 하는 VC에서 코드가 너무 길어지는 상황 발생
        - 유저에게 Text입력값 받음 → Body 생성을 위한(인코딩을) 인스턴스 형성 → 인코딩 데이터 받아옴 → body(인코딩된 데이터), Header 생성, URL 생성, APIKey생성 → Endpoint 객체에 주입 → Request 객체에 Endpoint 파라미터로 넘김 → Request 생성 → NetworkingManager에 Request를 넘겨서 API호출 → 받아온 값을통한 처리
        - 텍스트로 적어서 저정도인데 코드로 적으니 너무 길어져서 줄여야될 필요성을 느낌
        - Request객체를 삭제하고, 어차피 Endpoint에 Request생성을 위한 재료들이 모두 들어있으니, Protocol의 Extension을 통해서 Endpoint에서 Request를 생성할 수 있도록 만들어줌. 거기에 더해 Encoder를 가지고 있게 해줌으로써 자체 body생성도 가능하게 함.
    - 위의 과정은 Endpoint를 채택하는 객체의 재사용성을 높이기 위함이었지만, 결과적으로는 재사용성도 떨어지고 코드도 지저분해지는 결과를 낳게됨
        - 다시 Endpoint 프로토콜에서 Request 메서드와 Encoder를 지우고, 기본값들만남김. 그리고 `useAccesskey: Bool` 프로퍼티를 추가해줌
        - Endpoint를 채택하는 객체가 기본값을 가지도록 만들어줌
        - NetworkingManager가 httpBody에 들어갈 타입을 받아서 request를 생성하도록 만들어줌
        - 결과적으로 Endpoint를 채택하는 객체는 하나의 Endpoint만 가지는 역할을 하도록 분리되었고, NetworkManager는 Endpoint를 채택하는 객체만 주입받아서 통신이 가능하도록 만들 수 있게 됨.
- **Cell을 그리는 방법**
    - Configuration의 활용
        - 큰 효용성을 못느낌. 성능상의 이점에 있다고는 하나 크게 와닿지 않아서 별도의 커스텀 configuration을 만들어보지는 않음
    - CellRegstration의 활용 (커스텀 UICollectionVIewCell을 여러개 만듬)
        - User용 cell과 AI용 cell 두개를 따로 만들어서 사용하는 팀들이 존재함.
        - cellRegstration 을 가지 선언하고, dequeue에서 분기처리를 통해서, item의 role이 user면 A라는 cell을 쓰고 Ai 면 B라는 cell을 쓰도록 만듬
    - 커스텀 셀을 하나로 만들고, 셀 내부의 UIView들의 위치를, role에 따라 좌측 또는 우측으로 붙게 만들어줌
        - autolayout을 통한 방법임.
    - 평가 및 의견
        - Cell을 2개를 만드는게, 시간이 좀 걸리는것 같기는 한데, 훨씬 더 코드가 깔끔하고 복잡한 autolayout 계산을 계속해서 반복할 필요가 없다는 부분에서 오버헤드가 더 작지 않나 라는 생각이 들었음. 다음에는 이런 방식을 채택하는게 좋을것 같다.
- **유저 side와 챗봇 side의 채팅 말풍선의 위치를 다르게 하기위해, identifier를 받아서, 분기처리를 통해 각각 별개의 autolayout을 동적으로 적용시킴.**
    - 문제 발생
        - Cell 이 Reuse 될 때, 기존의 유저 side에서 사용되어 적용되어있던 autolayout이, 챗봇 side로 적용이 되면서 autolayout 충돌 현상이 발생
    - 해결 시도
        - 시도 1
            - diffableDataSource에서 사용할 수 있는 defaultContentConfiguration을 통해서 무엇인가 해보려 했으나, 이것은 여기서 쓰는게 아님을 깨달음
        - 시도 2
            - diffableDataSource 에서 cell 을 return 하기 전에, autolayout을 초기화 하려고 하였으나, 해당 위치에서는 cell을 특정할 수 없어서 실패
        - 시도 3
            - cellRegistration 을 2개로 만들어서, 유저와 챗봇을 구분하고, diffable단에서 identifier를 가지고 분기처리를 통해서 각각의 역할 구분지어버리기.
            - 소스가 길어지고, 가독성이 떨어지는것 같아서 보류
        - 시도 4 (성공!)
            - 각각의 채팅 말풍선에 필요한 autolayout 을 별도의 property로 만듬 → cellRegistration을할 때, identifier에 맞춰서 해당 autolayout 을 active → `prepareForReuse()`  메서드에서, autolayout가 저장된 프로퍼티들을 가지고 `NSLayoutConstraint.deactivate(autolayout)` 과 `layoutIfNeeded()` 호출을 통해서 기존에 적용되어있던 레이아웃을 초기화 시켜줌.
- **질문을 하고, 메세지를 수신할때까지, 메세지 수신 중을 표시하기 위한 상태값을 받아오는 방법에 대하여**
    - 문제상황
        - diffableDataSource를 사용함에 따라서 Data입력 여부에 따른 자동으로 Cell을 반환하기 때문에, 어떤 수동으로 내가 Cell을 반환하기 위해서는, snapShot을 통한 MockData를 넣는방법밖에 없었음
    - 해결방안
        - 유저의 질문(데이터)를 snapShot에 저장을 할 때, MockData도 함께 저장하도록 함. 이후에 AI 답변이 오는 시점에서 snapShot에 저장된 MockData는 삭제해줌. 이게 가능하도록 하기 위해서, 데이터(Hashable한 item)의 UUID가 같아야 하기 때문에, 그때그때 인스턴스를 생성해서 넣는게 불가능한 상황이었음. 상수로 인스턴스를 생성해두고, 이것을 계속해서 돌려쓰는 방법을 채택하였음
- **Animation을 동작시키기 위한 방법**
    - 문제상황
        - 커스텀 UICollectionViewCell 내부에, 애니메이션 동작을 하는 커스텀 UIView를 넣어서, User가 AI의 답을 기다릴때 생성되는 말풍성에 애니메이션 View를 addSubView를 하는 상황에서, 애니메이션이 동작하지 않고 후에 reuse 될때에만 애니메이션이 동작하게됨
    - 시도 1
        - 시점의 문제인것 같아서, animation을 동작시키는 함수인 `runSpinner()` 를, 다양한 시점에서 호출해봄 → 실패
    - 시도 2
        - Cell을 그려주는 위치에서, UICollectionViewDelegate를 채택하여, collectionView( willDisplay) 메서드나 didEndDisplay 메서드를 통해 runSpinner() 메서드를 호출해보려고 했지만 실패함
        - 대신 여기서, DispatchQueue.asyncAfter 메서드를 통해서, 호출 시점은 0.1초 지연시키니깐 제대로 동작을 함 하지만 이건 좀 아닌것 같다라는 판단
    - 시도 3 (성공!)
        - 커스텀 UICollectionVIewCell에서 `layoutSubViews()` 메서드를 오버라이드 하여, 해당 메서드 내에서 `runSpinner()` 메서드 호출하게함.
    - 시도 4 (성공!)
        - `layoutSubViews()` 라는 메서드를 직접적으로 호출하는것은 지양해야된다는 리뷰를 듣고, UICollectionViewDelegate 를 채택하여 willDisplay 메서드를 호출해서 runSpinner() 를 실행시킴 → 실패
        - 해당 메서드 내에서 DispatchQueue.main.asyncAfter 를 통해서 0.1초를 지연시킨 후 메소드를 실행시키니 성공함.
        - 이 방법도 정상적이진 않음. 추후 다른 방식의 개선이 필요할것으로 사료됨.
<br><br>
## ❗️느낀점

- Roks: 이번 프로젝트를 진행하며 프로젝트의 구조, 코드의 범용성과 코딩 컨벤션에 주로 신경을 썻던것 같다 특히 Extension을 활용하여 키보드 레이아웃을 제한 하는 코드를 재사용 가능하게 만들거나, Protocol을 활용하여 네트워킹 코드의 범용성을 늘렸던 방식은 유의미했다.
또한 CoreAnimation을 사용하며 “시점”의 중요성에 대해 다시 한번 느끼게 되었고 앞으로도 계속해서 고려해야 할 중요한 부분을 배운 것 같다.
- Howard: 리뷰어에게 지적을 많이 받았던 부분이 주로 코딩 컨벤션과, 네이밍 부분이었던 것 같습니다. 구현에 급급하다 보니 기초적인부분을 전혀 고려하지않고 진행했던것 같아서 많은 반성을 했습니다. 또한 유의미하게 학습했던 부분은 POST 메서드를 보내기 위해서, 어떻게 DTO를 구성하고, body를 어떻게 넣을것인지에 대해서 깊게 고민하고 구현했던 것과, modern collectionView의 사용법, 그리고 Animation 을 동작시키기 위해 ViewLifeCycle에 대해서 다시한번 복습을 거쳤던 과정이 가장 유익했던 부분인것 같습니다.
