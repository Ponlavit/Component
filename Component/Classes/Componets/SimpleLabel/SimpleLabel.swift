
import Foundation
import Base
import RxCocoa
import RxSwift

public class SimpleLabelViewModel : ComponentViewModel {
    public var title = Variable<String>("")
    public var font = Variable<UIFont>(UIFont.systemFont(ofSize: UIFont.systemFontSize))
    public var fontColor = Variable<UIColor>(UIColor.black)

    public convenience init(_ name: String!) {
        self.init(withName: name,nibName: "SimpleLabel")
    }
}

public class SimpleLabel : BaseView {
    @IBOutlet weak var titleField : UILabel?
    
    var bag = DisposeBag()
    
    public override func setupView() {
        super.setupView()
    }
    
    public override func getPercentWidth() -> CGFloat {
        return getModel().percentWidth.value
    }
    
    public override func getModel() -> SimpleLabelViewModel{
        return self.viewModel as! SimpleLabelViewModel
    }
    
    public override func getHeight() -> CGFloat {
        return getModel().height.value
    }
    
    public override func bind() {
        
        self.getModel().title.asObservable()
            .subscribe(onNext:{ [weak self] (value) in
                self?.titleField?.text = value
            })
        .disposed(by: bag)
        
        
        self.getModel().font.asObservable()
            .subscribe(onNext: {[weak self] value in
                self?.titleField?.font = value
            })
        .disposed(by: bag)
        
        self.getModel().fontColor.asObservable()
            .subscribe(onNext:{ [weak self] (value) in
                self?.titleField?.textColor = value
            })
        .disposed(by: bag)
        
        super.bind()
    }

}
