
import Foundation
import Base
import RxCocoa
import RxSwift


public class QRViewViewModel: ComponentViewModel {
    public var code = Variable<String>("")
    public var isHideWhenChange : Bool = false
    public convenience init(_ name: String!) {
        self.init(withName: name,nibName: "QRView")
    }
}

public class QRView : BaseView {
    @IBOutlet public weak var qrView : UIImageView?
    
    let bag = DisposeBag()
    
    public override func setupView() {
        self.layer.cornerRadius = 10
        super.setupView()
    }

    public override func getModel() -> QRViewViewModel{
        return self.viewModel as! QRViewViewModel
    }
    
    public override func getPercentWidth() -> CGFloat {
        return self.getModel().percentWidth.value
    }
    
    public override func setupAccessibilityId() {
        self.qrView?.accessibilityIdentifier =
        "\(getModel().name!).\(self.qrView?.accessibilityIdentifier ?? "button")"
        super.setupAccessibilityId()
    }
    
    public override func getHeight() -> CGFloat {
        return self.getModel().height.value
    }
    
    func generateQRCode(from string:String,withSize:CGFloat) -> UIImage? {
        let data =  string.data(using: String.Encoding.isoLatin1)
        if let filter = CIFilter(name:"CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: withSize, y: withSize)
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    public override func bind() {
        
        self.getModel().code.asDriver()
            .drive(onNext: { [unowned self] value in
                guard let imgView = self.qrView else { return }
                print("⚙️⚙️⚙️ Generate new QR \(value)")
                let size = max(imgView.frame.width, imgView.frame.height)
                let qr = self.generateQRCode(from: value,withSize: size)!
                DispatchQueue.main.async {
                    imgView.image = qr
                }
                
            })
        .disposed(by: bag)
        super.bind()
    }
}
