//
//  Item.swift
//  BarcodeScanner
//
//  Created by poniavit on 17/5/2561 BE.
//

import Foundation
import Base

open class TableTitleCellViewModel : BaseTableViewCellModel {
    
    public var titleText : String!
    public var extraText : String?
    public var titleTextFont : UIFont?
    public var titleFontColor : UIColor?
    public var extraTextFontColor : UIColor?
    public var extraTextFont : UIFont?
    public var backgroundColor : UIColor! = .white
    public var isHideBottomLine : Bool! = false
    public var action:URL?
    public var didTabAction: ((_ action:URL) -> Swift.Void)?
    public convenience init(_ name:String) {
        self.init(withName: name,
                  nibName: "TableTitleCell")
    }
    
    override open func getNib() -> UINib {
        let bundle = Bundle(for: TableTitleCellViewModel.self)
        return UINib(nibName: self.getNibName()!, bundle: bundle)
    }
    
    open override func getCellSelectionStyle() -> UITableViewCellSelectionStyle {
        return UITableViewCellSelectionStyle.none
    }
}

open class TableTitleCell : BaseTableViewCell {
    
    @IBOutlet public weak var lbAddition: UILabel!
    @IBOutlet public weak var lbTitle: UILabel!
    @IBOutlet public weak var viLine: UIView!
    
    @IBAction func didTabExtra() {
        guard let didTabAction = self.getModel().didTabAction,
        let `action` = self.getModel().action
            else { return }
        didTabAction(action)
    }
    
    override open func setupView() {
        self.lbTitle.text = self.getModel().titleText
        self.lbAddition.text = self.getModel().extraText
        
        self.lbTitle.font = self.getModel().titleTextFont
        self.lbAddition.font = self.getModel().extraTextFont
        
        self.viLine.isHidden = self.getModel().isHideBottomLine
        self.backgroundColor = self.getModel().backgroundColor
        
        if let color = self.getModel().titleFontColor {
            self.lbTitle.textColor = color
        }
        
        if let color = self.getModel().extraTextFontColor {
            self.lbAddition.textColor = color
        }
        
        super.setupView()
    }
    
    open override func getWHRatio() -> CGFloat {
        return self.getModel().height.value / self.getModel().getCellView().frame.size.width
    }
    
    override open func bind() {
        super.bind()
    }
    
    open override func getModel() -> TableTitleCellViewModel {
        return self.viewModel as! TableTitleCellViewModel
    }
}
