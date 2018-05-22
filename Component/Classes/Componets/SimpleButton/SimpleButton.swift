
import Foundation
import Base
import RxCocoa
import RxSwift


public class SimpleButtonViewModel: ComponentViewModel {
    public var title = Variable<String>("")
    public var disbleTitle = Variable<String>("")
    public var isEnable = Variable<Bool>(true)
    public var disableColor = Variable<UIColor>(UIColor.lightGray)
    public var enableColor = Variable<UIColor>(UIColor.red)
    public var font = Variable<UIFont>(UIFont.systemFont(ofSize: UIFont.systemFontSize))
    public var onPress: (() -> Void)?

    public convenience init(_ name: String!) {
        self.init(withName: name,nibName: "SimpleButton")
    }
    
    public func listen(onPress:(()->(Void))!){
        self.onPress = onPress
    }
}

public class SimpleButton : BaseView {
    @IBOutlet public weak var button : UIButton?
    
    let bag = DisposeBag()
    
    public override func setupView() {
        
        self.layer.cornerRadius = 10
        
        self.button?.setTitle(self.getModel().disbleTitle.value, for: .disabled)
        
        super.setupView()
    }

    public override func getModel() -> SimpleButtonViewModel{
        return self.viewModel as! SimpleButtonViewModel
    }
    
    public override func getPercentWidth() -> CGFloat {
        return getModel().percentWidth.value
    }
    
    public override func setupAccessibilityId() {
        self.button?.accessibilityIdentifier =
        "\(getModel().name!).\(self.button?.accessibilityIdentifier ?? "button")"
        super.setupAccessibilityId()
    }
    
    public override func getHeight() -> CGFloat {
        return getModel().height.value
    }
    
    public override func bind() {
        
        guard let btn = self.button else {
            super.bind()
            return
        }
        
        btn.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let onPress = self?.getModel().onPress else {
                    print("\(String(describing: type(of: self))) No button action bind")
                    return
                }
                onPress()
            }).disposed(by: bag)
        
        self.getModel().disableColor.asObservable()
            .subscribe(onNext: { [weak self] value in
                if(self?.button?.isEnabled)! {
                    self?.backgroundColor = value
                }
            }).disposed(by: bag)
        
        self.getModel().enableColor.asObservable()
            .subscribe(onNext: { [weak self] value in
                if(self?.button?.isEnabled)! {
                    self?.backgroundColor = value
                }
            }).disposed(by: bag)
        
        self.getModel().title.asObservable()
            .subscribe(onNext: { [weak self] (value) in
                self?.button?.setTitle(value, for: .normal)
            }).disposed(by: bag)
        
        self.getModel().disbleTitle.asObservable()
            .subscribe(onNext: { [weak self]  (value) in
                self?.button?.setTitle(value, for: .disabled)
            }).disposed(by: bag)
        
        self.getModel().isEnable.asObservable()
            .subscribe(onNext: { [weak self]  (value) in
                self?.button?.isEnabled = value
                let color = value ?
                    self?.getModel().enableColor.value : self?.getModel().disableColor.value
                self?.backgroundColor = color
            }).disposed(by: bag)
        
        self.getModel().font.asObservable()
            .subscribe(onNext: {[weak self] value in
                self?.button?.titleLabel?.font = value
            })
            .disposed(by: bag)
        
        
        super.bind()
    }
}
