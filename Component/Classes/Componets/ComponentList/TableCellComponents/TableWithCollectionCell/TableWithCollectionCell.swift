//
//  Item.swift
//  BarcodeScanner
//
//  Created by poniavit on 17/5/2561 BE.
//

import Foundation
import Base

public class TableWithCollectionCellViewModel : BaseTableViewCellModel {
    public var adapter : BaseCollectionAdapter!
    public var flow : UICollectionViewFlowLayout!
    public var isPagingEnable : Bool! = false
    
    // Set register collection view for better performance register cell
    // or else it will call register on all cell ignore same type
    public var willRegisterCollectionView :  ((_ collectionView:UICollectionView)->Swift.Void)?
    
    public convenience init(_ name:String) {
        self.init(withName: name,
                  nibName: "TableWithCollectionCell")
    }
    
    override open func getNib() -> UINib {
        let bundle = Bundle(for: TableWithCollectionCellViewModel.self)
        return UINib(nibName: self.getNibName()!, bundle: bundle)
    }
    
    public override func getCellSelectionStyle() -> UITableViewCellSelectionStyle {
        return UITableViewCellSelectionStyle.none
    }
}

public class TableWithCollectionCell : BaseTableViewCell {
    var collectionViewModel : BaseCollectionViewModel?

    func getCellSelectionStyle() -> UITableViewCellSelectionStyle {
        return UITableViewCellSelectionStyle.none
    }
    
    override public func setupView() {
        if(self.collectionViewModel != nil){
            self.collectionViewModel?.getView().removeFromSuperview()
            self.collectionViewModel = nil
        }
        self.collectionViewModel = BaseCollectionViewModel(self.getModel().name,
                                                           withAdapter: self.getModel().adapter,
                                                           isPagingEnable:self.getModel().isPagingEnable,
                                                           layoutFlow:self.getModel().flow)
        self.collectionViewModel?.onRegisterCell = self.getModel().willRegisterCollectionView
        self.collectionViewModel?.percentWidth.value = self.getModel().percentWidth.value
        self.collectionViewModel?.height.value = self.getModel().height.value
        self.addSubview((self.collectionViewModel?.getView())!)
        self.collectionViewModel?.getView().setupView()
        self.collectionViewModel?.getCollectionView()?.setCollectionViewLayout(self.getModel().flow, animated: false)
        self.collectionViewModel?.getCollectionView()?.setContentOffset(CGPoint.zero, animated: false)
        super.setupView()
    }
    
    public override func getWHRatio() -> CGFloat {
        return self.getModel().height.value / (UIApplication.shared.windows.first?.frame.size.width)! 
    }
    
    override public func bind() {
        super.bind()
    }
    
    public override func getModel() -> TableWithCollectionCellViewModel {
        return self.viewModel as! TableWithCollectionCellViewModel
    }
}
