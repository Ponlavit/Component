//
//  DrawerManager.swift
//  Base
//
//  Created by poniavit on 5/6/2561 BE.
//

import Foundation
import Base
import KWDrawerController

public class Drawer {
    private static let drawerController = DrawerController()
    public static func build(_ target:BaseScreen,
                      withLeftDrawer leftDrawer:BaseScreen? = nil,
                      andRightDrawer rightDrawer:BaseScreen? = nil) -> UINavigationController{
        let mainBaseNavigationController =
            UINavigationController(rootViewController: Base.build(target))
        drawerController.setViewController(mainBaseNavigationController, for: .none)
        if(leftDrawer != nil) {
            drawerController.setViewController(Base.build(leftDrawer!), for: .left)
        }
        if(rightDrawer != nil) {
            drawerController.setViewController(Base.build(rightDrawer!), for: .right)
        }
        return mainBaseNavigationController
    }
}
