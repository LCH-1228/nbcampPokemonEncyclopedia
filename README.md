# nbcampPokemonEncyclopedia
nbcampPokemonEncyclopedia는 Swift 학습을 목적으로 작성된 iOS용 포켓몬 도감 애플리케이션입니다.

## 프로젝트 개요
-   **프로젝트 이름**: nbcampPokemonEncyclopedia
-   **설명**: 내일배움캠프 iOS 스타터 과정 앱 심화 주차의 과제로, Swift 언어 학습의 결과물입니다.
-   **목표**: 소프트웨어 아이키텍처, 디자인패턴, 동기/비동기 개념의 필요성과 활용 방법 학습하고 확장성과 유지보수성이 높은 앱 개발 역량 강화

## 주요기능

- API를 통한 네트워크에서 데이터 호출

## 개발기간

2025.05.09(금) ~ 2025.05.13(화)  

## 기술스택

### 개발환경
| 구분 | 비고 |
|------|------|
| Swift 5 | iOS 앱 개발을 위한 프로그래밍 언어 |
| Xcode 16.2 | iOS 앱 개발을 위한 공식 IDE |
| iOS 16.6 | Target OS 버전 |

### 디자인 패턴
| 구분| 비고 |
|------|------|
|MVVM <br> (Model-View-ViewModel) | - UI(View)와 비즈니스 로직(Model)을 분리하여 코드의 재사용성, 유지보수성 향상 <br> - ViewModel은 RxSwift를 기반으로 구성하여 사용자 이벤트와 데이터를 반응형(Rx) 방식으로 처리 |

### UI 구성
| 구분 | 비고 |
|------|------|
| UIKit | iOS 기본 UI 프레임워크 |
| [SnapKit](https://github.com/SnapKit/SnapKit.git) 5.7.1 | AutoLayout을 간결하게 작성할 수 있는 DSL |
| [Kingfisher](https://github.com/onevcat/Kingfisher) 8.3.2 | 이미지를 다운로드하고 캐싱하는 데 사용되는 라이브러리 |

### 네트워크
| 구분 | 비고 |
|------|------|
| [Alamofire](https://github.com/Alamofire/Alamofire) 5.10.2 | HTTP 네트워킹 라이브러리 |

### 기타 라이브러리
| 구분 | 비고 |
|------|------|
| [RxSwift](https://github.com/ReactiveX/RxSwift) 6.9.0 | 반응형 프로그래밍을 위한 라이브러리 |
| [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) 5.0.2 | 테이블·컬렉션 뷰를 RxSwift로 바인딩할 수 있도록 도와주는 라이브러리 |


## 프로젝트 구조 및 역활 

### 파일별 역활

#### View
- `DetailViewController.swift` : 상세화면 UI 표시
- `ImageCell.swift` : UICollectionView 커스텀 셀 UI
- `MainViewController.swift` : 메인화면 UI 표시
- `SectionHeaderView.swift` : UICollectionView 헤더 UI

#### ViewModel
- `DetailViewModel.swift` : 상세화면 UI 표시를 위한 뷰 모델
- `MainViewModel.swift` :  메인화면 UI 표시를 위한 뷰 모델

#### Model
- `CollectionViewData.swift` : RxDataSources 사용을 위한 UICollectionView 데이터 구조체 정의
- `CustomError.swift` : 사용자 정의 타입 에러 정의
- `DetailResponse.swift` : JSON 디코딩용 구조체 정의
- `ListResponse.swift` : JSON 디코딩용 구조체 정의
- `NetworkManager.swift` : 네트워크 통신을 위한 클래스 정의
- `PokemonKoreanName.swift` : 포켓몬 이름 한글 번역을 위한 열거형 정의
- `PokemonKoreanType.swift` : 포켓몬 타입 한글 번역을 위한 열거형 정의

### 프로젝트 구조
```
nbcampPokemonEncyclopedia
├── nbcampPokemonEncyclopedia
│   ├── nbcampPokemonEncyclopedia
│   │   ├── App
│   │   │   ├── AppDelegate.swift
│   │   │   ├── Assets.xcassets
│   │   │   ├── Base.lproj
│   │   │   ├── Info.plist
│   │   │   └── SceneDelegate.swift
│   │   ├── Base.lproj
│   │   ├── Model
│   │   │   ├── CollectionViewData.swift
│   │   │   ├── CustomError.swift
│   │   │   ├── DetailResponse.swift
│   │   │   ├── ListResponse.swift
│   │   │   ├── NetworkManager.swift
│   │   │   ├── PokemonKoreanName.swift
│   │   │   └── PokemonKoreanType.swift
│   │   ├── View
│   │   │   ├── DetailViewController.swift
│   │   │   ├── ImageCell.swift
│   │   │   ├── MainViewController.swift
│   │   │   └── SectionHeaderView.swift
│   │   └── ViewModel
│   │       ├── DetailViewModel.swift
│   │       └── MainViewModel.swift
│   └── nbcampPokemonEncyclopedia.xcodeproj
└── README.md
```

## 샘플이미지

<div style="display: flex; gap: 10px; justify-content: center;">
  <img src="https://github.com/LCH-1228/nbcampPokemonEncyclopedia/blob/develop/SampleImage/MainViewUI.png?raw=true" alt="메인화면" width="40%">
  <img src="https://github.com/LCH-1228/nbcampPokemonEncyclopedia/blob/develop/SampleImage/DetailViewUI.png?raw=true" alt="상세화면" width="40%">
</div>

<br/>

<div style="display: flex; gap: 10px; justify-content: center;">
  <img src="https://github.com/LCH-1228/nbcampPokemonEncyclopedia/blob/develop/SampleImage/Sample.gif?raw=true alt="샘플" width="40%">
</div>

## 실행방법

1. 레포지토리 클론
```shell
git clone https://github.com/LCH-1228/nbcampPokemonEncyclopedia.git
```

2. 프로젝트 파일 실행