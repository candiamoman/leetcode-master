//
//  ORBRecommendationMainView.swift
//  ORB
//
//  Created by 김민성 on 4/20/25.
//

import UIKit

import SnapKit
import Then

final class ORBRecommendationMainView: UIView {
    
    // MARK: - Properties
    
    private let orbMessageButtonHidingAnimator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1)
    private let contentToolBarHeight: CGFloat = 48
    private var isORBMessageButtonShownWhenList: Bool = true
    private var topInset: CGFloat { recommendedContentView.contentInset.top }
    
    private lazy var contentToolBarBottomConstraint = contentToolBar.bottomAnchor.constraint(
        equalTo: recommendedContentView.topAnchor,
        constant: -recommendedContentView.contentOffset.y
    )
    
    private lazy var orbMapViewTopConstraint = orbMapView.topAnchor.constraint(
        equalTo: recommendedContentView.topAnchor
    )
    
    // MARK: - UI Properties
    
    let backButton = NavigationPopButton()
    private let titleLabel = UILabel()
    private let titleImageView = UIImageView(image: .icnOrbRecommendationMainTitle)
    private lazy var titleStack = UIStackView(arrangedSubviews: [titleLabel, titleImageView])
    let orbMessageButton = ORBRecommendationMessageButton()
    let orbMapView = ORBMapView()
    let recommendedContentView = ORBRecommendedContentView()
    let contentToolBar = ORBRecommendationMainViewToolBar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        setupDelegate()
        setupButtonActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// Initial Settings
private extension ORBRecommendationMainView {
    
    func setupStyle() {
        backgroundColor = .main(.main1)
        
        backButton.configureButtonTitle(titleString: "홈")
        
        titleLabel.do { label in
            label.text = "오브의 추천소"
            label.font = .offroad(style: .iosTextTitle)
            label.textColor = .main(.main2)
            label.textAlignment = .left
        }
        
        titleStack.do { stackView in
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.alignment = .fill
            stackView.distribution = .fillProportionally
        }
        
        orbMapView.isHidden = true
        orbMapView.mapView.maxTilt = 0
    }
    
    func setupHierarchy() {
        addSubviews(backButton, titleStack, recommendedContentView, orbMapView, orbMessageButton, contentToolBar)
    }
    
    func setupLayout() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(12)
            make.leading.equalToSuperview().inset(14)
        }
        
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        titleImageView.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        titleStack.snp.makeConstraints { make in
            let topInset: CGFloat = UIScreen.current.isAspectRatioTall ? 30 : 10
            make.top.equalTo(backButton.snp.bottom).offset(topInset)
            make.leading.equalToSuperview().inset(24)
            make.trailing.lessThanOrEqualToSuperview().inset(24)
        }
        
        orbMessageButton.snp.makeConstraints { make in
            make.top.equalTo(titleStack.snp.bottom).offset(30)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(85)
        }
        
        recommendedContentView.snp.makeConstraints { make in
            make.top.equalTo(titleStack.snp.bottom).offset(contentToolBarHeight)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        orbMapViewTopConstraint.isActive = true
        orbMapView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(recommendedContentView)
        }
        
        contentToolBarBottomConstraint.isActive = true
        contentToolBar.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(recommendedContentView)
            make.height.equalTo(contentToolBarHeight)
        }
    }
    
    func setupDelegate() {
        recommendedContentView.delegate = self
    }
    
    func setupButtonActions() {
        contentToolBar.onListButtonTapped = { [weak self] in
            guard let self else { return }
            self.orbMapView.isHidden = true
            if self.isORBMessageButtonShownWhenList {
                self.showORBMessageButton()
            } else {
                self.hideORBMessageButton()
            }
        }
        
        contentToolBar.onMapButtonTapped = { [weak self] in
            guard let self else { return }
            self.orbMapView.isHidden = false
            self.hideORBMessageButton()
        }
    }
    
    func enableMessageButton() {
        orbMessageButton.isUserInteractionEnabled = true
        guard subviews.last != orbMessageButton else { return }
        bringSubviewToFront(orbMessageButton)
    }
    
    // scrollToTop 동작 시 사용자가 중간에 동작을 멈추고 반대 방향으로 스크롤 시 잠깐 동안 message button의 alpha 값이 반영되지 않는 이슈
    // -> 뷰 계층의 아래로 숨기기
    func disableMessageButton() {
        orbMessageButton.isUserInteractionEnabled = false
        guard subviews.first != orbMessageButton else { return }
        sendSubviewToBack(orbMessageButton)
    }
    
}

// 스크롤 정도에 따른 상호작용 시 호출하는 메서드
private extension ORBRecommendationMainView {
    
    /// `orbMessageButton`의 크기 변경
    /// - Parameter process: 스크롤 진행률. 이 값이 0일 때 `orbMessageButton`이 완전히 보이고, 1일 때 완전히 가려짐.
    func transformORBMessageButton(process: CGFloat) {
        // 버튼이 최대로 커지는 비율
        let maxSizeRatio: CGFloat = 1.15
        // 스크롤에 따라 자연스러운 크기 변화를 위해 process에 따른 비율 계산
        let shrinkRatio = max(-(maxSizeRatio-1) * exp(process) + maxSizeRatio, 0)
        orbMessageButton.transform = .init(scaleX: shrinkRatio, y: shrinkRatio)
    }
    
    /// `orbMessageButton`의 투명도 변경
    /// - Parameter process: 스크롤 진행률. 이 값이 0일 때 `orbMessageButton`이 완전히 보이고, 1일 때 완전히 가려짐.
    func updateORBMessageButtonAlpha(process: CGFloat) {
        orbMessageButton.alpha = 1 - process * 2
    }
    
    /// `contentToolBar`의 세로 위치 변경
    /// - Parameter process: 스크롤 진행률. 이 값이 1 이하일 때 `contentToolBar`는 리스트 컨텐츠 상단에 붙어 움직이고, 1 이상인 경우 `title` 바로 아래 붙어서 고정
    func updateToolBarVerticalPosition(process: CGFloat) {
        if process < 1 {
            contentToolBarBottomConstraint.constant = -recommendedContentView.contentOffset.y
            orbMapViewTopConstraint.constant = -recommendedContentView.contentOffset.y
            recommendedContentView.scrollIndicatorInsets =
                .init(top: -recommendedContentView.contentOffset.y, left: 0, bottom: 0, right: 0)
        } else {
            contentToolBarBottomConstraint.constant = 0
            orbMapViewTopConstraint.constant = 0
        }
    }
    
}

// 오브 메세지 버튼 보이기/숨기기 동작
extension ORBRecommendationMainView {
    
    func showORBMessageButton() {
        orbMessageButtonHidingAnimator.stopAnimation(true)
        orbMessageButtonHidingAnimator.addAnimations { [weak self] in
            guard let self else { return }
            self.recommendedContentView.setContentOffset(.init(x: 0, y: -self.topInset), animated: false)
            self.layoutIfNeeded()
        }
        orbMessageButtonHidingAnimator.startAnimation()
    }
    
    func hideORBMessageButton() {
        // 이미 숨겨진 경우 return
        guard recommendedContentView.contentOffset.y < 0 else { return }
        orbMessageButtonHidingAnimator.stopAnimation(true)
        orbMessageButtonHidingAnimator.addAnimations { [weak self] in
            guard let self else { return }
            self.recommendedContentView.setContentOffset(.zero, animated: false)
            self.layoutIfNeeded()
        }
        orbMessageButtonHidingAnimator.startAnimation()
    }
    
}

// MARK: - UICollectionViewDelegate

extension ORBRecommendationMainView: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 리스트(스크롤 뷰)가 오브 메시지 버튼을 얼마나 가렸는지 정도
        // 리스트를 최상단까지 스크롤하여 버튼이 모두 보이는 경우 0, 리스트가 아래로 스크롤되어 버튼을 모두 가리기 시작하는 경우 1.
        let orbMessageHidingProcess = (scrollView.contentOffset.y + topInset)/topInset
        
        transformORBMessageButton(process: orbMessageHidingProcess)
        updateORBMessageButtonAlpha(process: orbMessageHidingProcess)
        updateToolBarVerticalPosition(process: orbMessageHidingProcess)
        
        // 버튼이 제자리에 왔을 때만 orbMessageButton 활성화 활성화
        // 버튼이 제자리에 올 때 실제 process 값은 0이 아닌 0.001... 의 값으로 계산됨.
        if -0.002...0.002 ~= orbMessageHidingProcess {
            enableMessageButton()
        } else {
            disableMessageButton()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let detent1: CGFloat = -(topInset/2)
        let detent2: CGFloat = 0
        
        switch targetContentOffset.pointee.y {
        case ..<detent1:
            targetContentOffset.pointee = .init(x: .zero, y: -topInset)
            isORBMessageButtonShownWhenList = true
        case detent1..<detent2:
            targetContentOffset.pointee = .zero
            isORBMessageButtonShownWhenList = false
        default:
            isORBMessageButtonShownWhenList = false
            return
        }
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        guard orbMapView.isHidden else { return false }
        return true
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if -topInset < yOffset && yOffset < 0 {
            showORBMessageButton()
        }
        isORBMessageButtonShownWhenList = true
    }
    
}
