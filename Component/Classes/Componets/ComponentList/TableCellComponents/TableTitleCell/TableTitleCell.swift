//
//  Item.swift
//  BarcodeScanner
//
//  Created by poniavit on 17/5/2561 BE.
//

import Foundation
import Base

public class TableTitleCellViewModel : BaseTableViewCellModel {

    public var titleText : String!
    public var extraText : String?
    
    public convenience init(_ name:String) {
        self.init(withName: name,
                  nibName: "TableTitleCell")
    }
    
    override open func getNib() -> UINib {
        let bundle = Bundle(for: TableTitleCellViewModel.self)
        return UINib(nibName: self.getNibName()!, bundle: bundle)
    }
    
    public override func getCellSelectionStyle() -> UITableViewCellSelectionStyle {
        return UITableViewCellSelectionStyle.none
    }
}

public class TableTitleCell : BaseTableViewCell {
    
    @IBOutlet weak var lbAddition: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @objc func didTabExtra(_ sender: UITapGestureRecognizer) {
        
    }
    
    override public func setupView() {
        self.lbTitle.text = self.getModel().titleText
        self.lbAddition.text = self.getModel().extraText
        super.setupView()
    }
    
    public override func getWHRatio() -> CGFloat {
        return self.getModel().height.value / self.getModel().getCellView().frame.size.width
    }
    
    override public func bind() {
        super.bind()
    }
    
    public override func getModel() -> TableTitleCellViewModel {
        return self.viewModel as! TableTitleCellViewModel
    }
}
