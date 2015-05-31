//
//  ContainerViewController.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/30/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    @IBOutlet weak var hamburgerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var containerCenterConstraint: NSLayoutConstraint!
    
    private var originalContainerCenterX: CGFloat?
    
    private var profileVc: UINavigationController!
    private var homeNavigatorVc: UINavigationController!
    private var mentionsNavigatorVc: UINavigationController!
    
    private var homeDataSource: HomeTimelineDataSource!
    private var mentionsDataSource: MentionsTimelineDataSource!
    
    var activeViewController: UIViewController? {
        didSet(oldViewControllerOrNil) {
            if let oldVc = oldViewControllerOrNil {
                oldVc.willMoveToParentViewController(nil)
                oldVc.view.removeFromSuperview()
                oldVc.removeFromParentViewController()
            }
            if let newVc = activeViewController {
                self.addChildViewController(newVc)
                newVc.view.frame = self.contentView.bounds
                self.contentView.addSubview(newVc.view)
                newVc.didMoveToParentViewController(self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileVc = storyboard!.instantiateViewControllerWithIdentifier("NavProfileViewController") as! UINavigationController
        (profileVc.topViewController as! ProfileViewController).isFromHamburger = true
        
        homeDataSource = HomeTimelineDataSource()
        homeNavigatorVc = storyboard!.instantiateViewControllerWithIdentifier("TweetsNavViewController") as! UINavigationController
        (homeNavigatorVc.topViewController as! TweetsViewController).dataSource = homeDataSource
        
        mentionsDataSource = MentionsTimelineDataSource()
        mentionsNavigatorVc = storyboard!.instantiateViewControllerWithIdentifier("TweetsNavViewController") as! UINavigationController
        (mentionsNavigatorVc.topViewController as! TweetsViewController).dataSource = mentionsDataSource
        
        activeViewController = homeNavigatorVc
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func onPanContentView(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .Began:
            originalContainerCenterX = containerCenterConstraint.constant
        case .Changed:
            let delta = sender.translationInView(view)
            containerCenterConstraint.constant = originalContainerCenterX! - delta.x
//            if delta.x > 0 && delta.x <= hamburgerView.frame.width {
//            }
        case .Ended:
            let velocity = sender.velocityInView(self.view)

            if velocity.x > 0 {
                revealHamburgerAnimation()
            } else {
                hideHamburgerAnimation()
            }
        default:
            let foo = 1
        }
    }
    
    
    @IBAction func onSelectProfile(sender: AnyObject) {
        (profileVc.topViewController as! ProfileViewController).account = Account.currentAccount
        activeViewController = profileVc
        hideHamburgerAnimation()
    }
    
    @IBAction func onSelectHomeTimeline(sender: AnyObject) {
        homeNavigatorVc.popToRootViewControllerAnimated(true)
        activeViewController = homeNavigatorVc
        hideHamburgerAnimation()
    }
    
    @IBAction func onSelectMentions(sender: AnyObject) {
        homeNavigatorVc.popToRootViewControllerAnimated(true)
        activeViewController = mentionsNavigatorVc
        hideHamburgerAnimation()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    private func revealHamburgerAnimation() {
        slideAnimation() {
            self.containerCenterConstraint.constant = -1 * self.hamburgerView.frame.width
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideHamburgerAnimation() {
        slideAnimation() {
            self.containerCenterConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func slideAnimation(animations: () -> Void) {
        UIView.animateWithDuration(0.5,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: nil,
            animations: animations,
            completion: nil
        )

    }
}

class HomeTimelineDataSource: TweetsViewControllerDataSource {
    func tweetsViewController(sender: TweetsViewController, loadTweetsWithMaxId maxId: Int?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        if let maxId = maxId {
            var params = Dictionary<String, AnyObject>()
            params["max_id"] = maxId
            TwitterClient.sharedInstance.homeTimelineWithParams(params, completion: completion)
        } else {
            TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion: completion)
        }
    }
}

class MentionsTimelineDataSource: TweetsViewControllerDataSource {
    func tweetsViewController(sender: TweetsViewController, loadTweetsWithMaxId maxId: Int?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        if let maxId = maxId {
            var params = Dictionary<String, AnyObject>()
            params["max_id"] = maxId
            TwitterClient.sharedInstance.mentionsTimelineWithParams(params, completion: completion)
        } else {
            TwitterClient.sharedInstance.mentionsTimelineWithParams(nil, completion: completion)
        }
    }
}