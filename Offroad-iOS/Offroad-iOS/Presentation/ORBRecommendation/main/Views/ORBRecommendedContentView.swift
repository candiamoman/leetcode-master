//
//  ORBRecommendedContentView.swift
//  ORB_Dev
//
//  Created by 김민성 on 4/20/25.
//

import CoreLocation
import UIKit

import ExpandableCell
import SnapKit

final class ORBRecommendedContentView: ExpandableCellCollectionView, ORBCenterLoadingStyle {
    
    // MARK: - Properties
    
    private let topInset: CGFloat = 138.5
    private let locationManager = CLLocationManager()
    private let placeService = NetworkService.shared.placeService
    
    // MARK: - UI Properties
    
    private let collectionViewContentBackground = UIView()
    
    // MARK: - Life Cycle
    
    init() {
        let contentInset: UIEdgeInsets = .init(top: topInset, left: 0, bottom: 0, right: 0)
        let sectionInset: UIEdgeInsets = .init(top: 19.5, left: 24, bottom: 19.5, right: 24)
        super.init(contentInset: contentInset, sectionInset: sectionInset, minimumLineSpacing: 16)
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        locationManager.startUpdatingLocation()
        panGestureRecognizer.delegate = self
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        sendSubviewToBack(collectionViewContentBackground)
    }
    
}

// Initial Setting
private extension ORBRecommendedContentView {
    
    func setupStyle() {
        backgroundColor = .clear
        delaysContentTouches = false
        collectionViewContentBackground.backgroundColor = .primary(.listBg)
        collectionViewContentBackground.isUserInteractionEnabled = false
    }
    
    func setupHierarchy() {
        addSubview(collectionViewContentBackground)
    }
    
    func setupLayout() {
        collectionViewContentBackground.snp.makeConstraints { make in
            make.top.equalTo(contentLayoutGuide)
            make.horizontalEdges.bottom.equalTo(frameLayoutGuide)
        }
    }
    
}


// MARK: - UICollectionViewDelegate

extension ORBRecommendedContentView: UIGestureRecognizerDelegate {
    
    // 상단 contentInset 영역 터치 시 제스처 무효화 (false 를 return)
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: self)
        if touchPoint.y < 0 {
            // 아래로 땡긴 후 원래 자리로 돌아가는 중에 상단 여백에서 스크롤 시도 시
            if isDecelerating {
                if let mainView = superview as? ORBRecommendationMainView {
                    mainView.showORBMessageButton()
                }
            }
            return false
        }
        return true
    }
    
}


// MARK: ORBEmptyCaseStyle

extension ORBRecommendedContentView: ORBEmptyCaseStyle {
    
    typealias placeholder = ORBRecommendationEmptyCaseView
    
}
