//
//  HomeViewController.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/20/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

let tweetsToDetailSegue = "tweetsToDetailSegue"
let tweetsToComposeSegue = "tweetsToComposeSegue"
let homeToReplyComposeSegue = "homeToReplyComposeSegue"

class TweetsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    private var refreshControl: UIRefreshControl!
    var tweets: [Tweet]?
    
    var replyToTweet: Tweet?
    
    @IBAction func onLogout(sender: AnyObject) {
        Account.currentAccount?.logout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.redColor()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        onRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
            case tweetsToComposeSegue:
                let navigationController = segue.destinationViewController as! UINavigationController
                let composeTweetViewController = navigationController.topViewController as! ComposeTweetViewController
                composeTweetViewController.delegate = self
            
                if replyToTweet != nil {
                    composeTweetViewController.inReplyToTweet = replyToTweet
                    replyToTweet = nil
                }
            case tweetsToDetailSegue:
                if let indexPath = tableView.indexPathForSelectedRow() {
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as! TweetCell
                    let detailController = segue.destinationViewController as! DetailViewController
                    detailController.tweet = cell.tweet
                    detailController.parentCell = cell
                    detailController.delegate = self
                    
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                } else {
                    NSLog("Trying to segue to detail view without a selected tweet")
                }
            default:
                NSLog("aa")
        }
        
    }
    
    func onRefresh() {
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion: { (tweets, error) -> () in
            self.refreshControl.endRefreshing()

            if let error = error {
                NSLog("Error %@", error)
            } else {
                self.tweets = tweets
                self.tableView.reloadData()
            }
        })
    }
}

extension TweetsViewController: UITableViewDataSource, UITableViewDelegate {
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tweet = tweets![indexPath.row]
        
        let cellIdentifier: String
        if tweet.retweetedStatus != nil {
            cellIdentifier = "RetweetCell"
        } else {
            cellIdentifier = "TweetCell"
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TweetCell

        cell.tweet = tweet
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        cell.delegate = self
        
        return cell
    }

//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
////        return 0
//    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TweetCell

        self.performSegueWithIdentifier(tweetsToDetailSegue, sender: self)
        // tweetsToDetailSegue
    }
}

extension TweetsViewController: TweetCellProtocol {
    func tweetCell(tweetCell: TweetCell, didUpdateTweet: Tweet) {
//        tweet = didUpdateTweet
//        delegate?.detailViewController(self, didUpdateTweet: didUpdateTweet)
    }
    
    func tweetCell(tweetCell: TweetCell, replyToTweet: Tweet) {
        self.replyToTweet = replyToTweet
        performSegueWithIdentifier(tweetsToComposeSegue, sender: self)
    }
}

extension TweetsViewController: ComposeTweetViewControllerDelegate {
    func composeTweetViewController(composeTweetViewController: ComposeTweetViewController, didPublishTweet: Bool) {
        composeTweetViewController.dismissViewControllerAnimated(true, completion: nil)
        onRefresh()
    }
}

extension TweetsViewController: DetailViewControllerProtocol {
    func detailViewController(detailViewController: DetailViewController, didUpdateTweet: Tweet) {
        if tweets == nil {
            return
        }
        
        if let indexPath = tableView.indexPathForCell(detailViewController.parentCell) {
            tweets![indexPath.row] = didUpdateTweet
            detailViewController.parentCell.tweet = didUpdateTweet
        }
    }
}