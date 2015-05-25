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
    private var tweets: [Tweet]?
    
    private var replyToTweet: Tweet?
    private var hasOlderTweets: Bool = true
    
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
                self.hasOlderTweets = true
                self.tableView.reloadData()
            }
        })
    }
}

extension TweetsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if hasOlderTweets {
            return 2
        }
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tweets?.count ?? 0
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let tweet = tweets![indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
            
            cell.mode = .Compact
            cell.delegate = self
            cell.tweet = tweet
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("LoadingCell", forIndexPath: indexPath) as! UITableViewCell
            return cell
        }
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 || tweets == nil || !hasOlderTweets {
            return
        }
        
        // Displayed loading section, time to grab more tweets
        let oldestTweet = tweets![tweets!.count - 1]
        var params = Dictionary<String, AnyObject>()

        params["max_id"] = oldestTweet.id_int! - 1
        TwitterClient.sharedInstance.homeTimelineWithParams(params) { (tweets, error) -> () in
            if let error = error {
                NSLog("Error while loading moret tweets: %@", error)
                return
            }
            
            if let tweets = tweets {
                if tweets.count == 0 {
                    self.hasOlderTweets = false
                } else {
                    self.tweets = self.tweets! + tweets
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TweetCell

        self.performSegueWithIdentifier(tweetsToDetailSegue, sender: self)
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