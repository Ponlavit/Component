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
    
    public func getHeighByRatio(_ width:CGFloat) -> CGFloat {
        return self.getWHRatio() * width
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
    public func getTableView() -> UICollectionView? {
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
    public override func setupView() {
        super.setupView()
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
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.frame = self.bounds
        collectionView.isPagingEnabled = self.getModel().isPageEnable
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = withAdapter
        collectionView.dataSource = withAdapter
        withAdapter.baseCollectionView = self
        for model:BaseCollectionViewCellModel in withAdapter.dataSource {
            model.getCellView().registerOn(collectionView: collectionView)
        }
        self.onRefresh = onRefresh
        if #available(iOS 10.0, *) {
            if(onRefresh != nil){
                let refreshControl = UIRefreshControl()
                refreshControl.addTarget(self,
                                         action: #selector(self.onTriggerRefresh(sender:)),
                                         for: UIControlEvents.valueChanged)
                
                collectionView.refreshControl = refreshControl
            }
        }
        self.addSubview(collectionView)
        self.collectionView = collectionView
        return collectionView
    }
    
    
    public override func getHeight() -> CGFloat {
        return self.getModel().height.value
    }
    
    public override func getModel() -> BaseCollectionViewModel{
        return self.viewModel as! BaseCollectionViewModel
    }
}

public class BaseCollectionAdapter : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
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
            .subscribe(onNext: { [unowned self] value in
                self.reload()
            })
            .disposed(by:disposeBag)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let model = dataSource[row]
        print(" 🌈 rendering cell at \(row) with model \(model)")
        var cell : BaseCollectionViewCell?
            = collectionView.dequeueReusableCell(withReuseIdentifier: model.getNibName()!, for: indexPath) as? BaseCollectionViewCell
        if(cell == nil){
            print(" 🌈 not found reusable cell init")
            cell = model.getCellView()
            cell?.bind()
        }
        cell?.viewModel = model
        cell?.setupView()
        return cell!
    }
}
