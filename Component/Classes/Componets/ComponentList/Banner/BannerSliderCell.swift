//
//  BannerSliderCellModel.swift
//  Base
//
//  Created by poniavit on 5/6/2561 BE.
//

import Foundation
import Base
import RxSwift
import RxCocoa

public class BannerSliderCellModel : BaseTableViewCellModel {
    
    public var image : BehaviorRelay<UIImage>!
    public var action : String?
    public var onPressBanner : ((_ banner:BannerSliderCellModel) -> Swift.Void)?
    
    public override func getCellSelectionStyle() -> UITableViewCellSelectionStyle {
        return UITableViewCellSelectionStyle.none
    }
    
    public convenience init() {
        self.init(withName: "BannerSliderCell", nibName: "BannerSliderCell")
    }
}

public class BannerSliderCell : BaseCollectionViewCell {
    
    @IBOutlet weak var imvProductImage: UIImageView!

    var bag = DisposeBag()

    override public func setupView() {
        self.getModel().image?.asObservable()
            .subscribe(onNext: { (image) in
                print("did get image and try to set")
                self.imvProductImage.image = image
            })
        .disposed(by: self.bag)
    }
    
    public override func getModel() -> BannerSliderCellModel {
        return self.viewModel as! BannerSliderCellModel
    }
}
