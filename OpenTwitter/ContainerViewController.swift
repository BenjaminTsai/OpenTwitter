//
//  ContainerViewController.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/30/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

enum MenuEnum {
    case Profile, Home, Mention
    
    static func fromRow(row: Int) -> MenuEnum {
        switch row {
        case 0:
            return .Profile
        case 1:
            return .Home
        case 2:
            return .Mention
        default:
            NSLog("Unexpected row \(row)")
            return .Home
        }
    }
}

class ContainerViewController: UIViewController {
    
    @IBOutlet weak var hamburgerView: UIView!
    @IBOutlet weak var hamburgerTableView: UITableView!
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
        
        homeDataSource = HomeTimelineDataSource()
        homeNavigatorVc = storyboard!.instantiateViewControllerWithIdentifier("TweetsNavViewController") as! UINavigationController
        (homeNavigatorVc.topViewController as! TweetsViewController).dataSource = homeDataSource
        
        mentionsDataSource = MentionsTimelineDataSource()
        mentionsNavigatorVc = storyboard!.instantiateViewControllerWithIdentifier("TweetsNavViewController") as! UINavigationController
        (mentionsNavigatorVc.topViewController as! TweetsViewController).dataSource = mentionsDataSource
        
        hamburgerTableView.delegate = self
        hamburgerTableView.dataSource = self
        hamburgerTableView.rowHeight = UITableViewAutomaticDimension
        hamburgerTableView.estimatedRowHeight = 120

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

extension ContainerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if .Profile == MenuEnum.fromRow(indexPath.row) {
            let cell = tableView.dequeueReusableCellWithIdentifier("MenuProfileCell", forIndexPath: indexPath) as! MenuProfileCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuCell
        cell.menu = MenuEnum.fromRow(indexPath.row)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        switch MenuEnum.fromRow(indexPath.row) {
        case .Profile:
            (profileVc.topViewController as! ProfileViewController).account = Account.currentAccount
            activeViewController = profileVc
        case .Home:
            homeNavigatorVc.popToRootViewControllerAnimated(true)
            activeViewController = homeNavigatorVc
        case .Mention:
            homeNavigatorVc.popToRootViewControllerAnimated(true)
            activeViewController = mentionsNavigatorVc
        }

        hideHamburgerAnimation()
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