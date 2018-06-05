//
//  BaseCollection.swift
//  Base
//
//  Created by poniavit on 5/6/2561 BE.
//

import Foundation
import Base
import RxSwift

open class BaseCollectionViewCell : UICollectionViewCell, BaseViewLC {
    
    public weak var viewModel : BaseViewModel!
    public var tabGesture : UITapGestureRecognizer?
    open func setupView() {
        if(self.getModel().onSetupView != nil) {
            self.getModel().onSetupView!(self)
        }
        tabGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(self.tabGesture!)
    }
    
    @objc func didTap(){
        print("🎯 did tap on cell \(self.getModel().name)")
        if let action = self.getModel().didSelectedRow {
            action(self.getModel())
        }
    }
    
    public func bind() {
        // do some rx to change sepecific value
    }
    
    open func getWHRatio() -> CGFloat {
        return 1
    }
    
    public func getHeighByRatio(_ width:CGFloat) -> CGFloat {
        return self.getWHRatio() * width
    }
    
    
    open func setupAccessibilityId() {
        self.accessibilityIdentifier = getModel().name
    }
    
    open func getModel() -> BaseTableViewCellModel {
        return self.viewModel as! BaseTableViewCellModel
    }
}

public class BaseCollectionViewModel : ComponentViewModel {
    
}

public class BaseCollectionView : UICollectionView {
    
}

public class BaseCollectionAdapter : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell(frame: CGRect.zero)
    }
}
