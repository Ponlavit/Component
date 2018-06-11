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
        print("🎯 did tap collection on cell \(self.getModel().name)")
        if let action = self.getModel().didSelectedRow {
            action(self.getModel())
        }
    }
    
    public func bind() {
        // do some rx to change sepecific value
    }
    
    public func registerOn(collectionView:UICollectionView){
        guard let name = self.getModel().getNibName() else {
            fatalError("Nibname should not be nil")
        }
        guard name == self.reuseIdentifier else {
            fatalError("Nibname and reuse id should be the same")
        }
        print("Register Cell \(name)")
        collectionView.register(self.getModel().getNib(),
                                forCellWithReuseIdentifier: self.getModel().getNibName()!)
    }
    
    open func getWHRatio() -> CGFloat {
        return 1
    }
    
    open func setupAccessibilityId() {
        self.accessibilityIdentifier = getModel().name
    }
    
    open func getModel() -> BaseCollectionViewCellModel {
        return self.viewModel as! BaseCollectionViewCellModel
    }
}


open class BaseCollectionViewCellModel : ComponentViewModel {
    public weak var cellView : BaseCollectionViewCell?

    public var didSelectedRow : ((_ model:BaseCollectionViewCellModel) -> Swift.Void)?
    public func getCellView() -> BaseCollectionViewCell {
        var cell: BaseCollectionViewCell?
        if(self.cellView == nil) {
            cell = (self.getNibView() as! BaseCollectionViewCell)
            self.cellView = cell
        }
        else {
            return self.cellView!
        }
        
        cell?.viewModel = self
        return cell!
    }
}


public class BaseCollectionViewModel : ComponentViewModel {
    public weak var adapter : BaseCollectionAdapter!
    public var isPageEnable : Bool! = false
    public var onRegisterCell : ((_ collectionView:UICollectionView)->Swift.Void)?

    public func getCollectionView() -> UICollectionView? {
        return self.adapter.baseCollectionView?.collectionView
    }
    
    public convenience init(_ name:String!,
                            withAdapter adapter:BaseCollectionAdapter,
                            isPagingEnable:Bool? = false,
                            layoutFlow: UICollectionViewFlowLayout,
                            onRefresh:((_ sender:UIRefreshControl)->Swift.Void)? = nil){
        self.init(withName: name, nibName: "")
        self.adapter = adapter
        self.isPageEnable = isPagingEnable
        self.adapter.baseCollectionView = self.getBaseView()
        self.getBaseView().initTable(withAdapter:adapter, layoutFlow: layoutFlow,onRefresh:onRefresh)
        self.adapter.reload()
    }
    
    private func getBaseView() -> BaseCollectionView{
        let vi:BaseCollectionView = self.getView()
        return vi
    }
    
    override public func getView<T>() -> T where T : BaseCollectionView {
        let vi:BaseCollectionView = super.getView()
        return vi as! T
    }
}

public class BaseCollectionView : BaseView {
    public weak private(set) var collectionView : UICollectionView?
    public var onRefresh : ((_ sender:UIRefreshControl) -> Swift.Void)?
    public var onRegisterCell : ((_ collectionView:UICollectionView)->Swift.Void)?
    public override func setupView() {
        self.collectionView?.delegate = self.getModel().adapter
        self.collectionView?.dataSource = self.getModel().adapter
        self.onRegisterCell = self.getModel().onRegisterCell ?? self.registerCell
        self.onRegisterCell!(self.collectionView!)
        
        self.collectionView?.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView?.frame = self.bounds
        self.collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        self.collectionView?.isPagingEnabled = self.getModel().isPageEnable
        self.getModel().adapter.baseCollectionView = self
        super.setupView()
    }

    func registerCell(collectionView:UICollectionView){
        for model:BaseCollectionViewCellModel in self.getModel().adapter.dataSource {
            model.getCellView().registerOn(collectionView: collectionView)
        }
    }
    
    public func reloadData(){
        self.collectionView?.reloadData()
    }
    
    @objc func onTriggerRefresh(sender:UIRefreshControl){
        if(self.onRefresh != nil) {
            self.onRefresh!(sender)
            defer {
                if #available(iOS 10.0, *) {
                    self.collectionView?.refreshControl?.beginRefreshing()
                }
            }
        }
    }
    
    
    @discardableResult
    public func initTable(withAdapter:BaseCollectionAdapter,
                          layoutFlow:UICollectionViewFlowLayout,
                          onRefresh:((_ sender:UIRefreshControl)->Swift.Void)? = nil) -> UICollectionView!{
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layoutFlow)
        
        self.addSubview(collectionView)
        if #available(iOS 10.0, *) {
            if(onRefresh != nil){
                let refreshControl = UIRefreshControl()
                refreshControl.addTarget(self,
                                         action: #selector(self.onTriggerRefresh(sender:)),
                                         for: UIControlEvents.valueChanged)
                
                self.collectionView?.refreshControl = refreshControl
            }
        }
        
        self.onRefresh = onRefresh
        self.collectionView = collectionView
        self.collectionView?.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.collectionView?.backgroundColor = .clear
        self.collectionView?.showsVerticalScrollIndicator = false
        self.collectionView?.showsHorizontalScrollIndicator = false
        
        return collectionView
    }
    
    
    public override func getHeight() -> CGFloat {
        return self.getModel().height.value
    }
    
    public override func getModel() -> BaseCollectionViewModel{
        return self.viewModel as! BaseCollectionViewModel
    }
}

open class BaseCollectionAdapter : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    public private(set) var varDs :Variable<[BaseCollectionViewCellModel]>?
    public var baseCollectionView : BaseCollectionView?
    public var dataSource : [BaseCollectionViewCellModel] {
        return varDs?.value ?? []
    }
    
    public func reload(){
        self.baseCollectionView?.reloadData()
    }
    
    public convenience init(withDataSource: [BaseCollectionViewCellModel], disposeBag:DisposeBag) {
        self.init()
        self.varDs = Variable([])
        self.varDs?.value = withDataSource
        self.varDs?.asObservable()
            .subscribe(onNext: { [weak self] value in
                guard let _self = self else { return }
                guard let cell = _self.baseCollectionView else { return }
                cell.getModel()
                    .onRegisterCell!((cell.collectionView)!)
                _self.reload()
            })
            .disposed(by:disposeBag)
    }
    
    public func replaceSource(withNewSource newSource:[BaseCollectionViewCellModel]){
        self.varDs?.value.removeAll()
        self.varDs?.value = newSource
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let model = dataSource[row]
        var cell : BaseCollectionViewCell?
            = collectionView.dequeueReusableCell(withReuseIdentifier: model.getNibName()!, for: indexPath) as? BaseCollectionViewCell
        if(cell == nil){
            cell = model.getCellView()
            cell?.bind()
        }
        cell?.viewModel = model
        cell?.setupAccessibilityId()
        cell?.accessibilityIdentifier?.append(":\(row)")
        cell?.setupView()
        return cell!
    }
}
