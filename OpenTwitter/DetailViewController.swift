//
//  DetailViewController.swift
//  OpenTwitter
//
//  Created by Benjamin Tsai on 5/23/15.
//  Copyright (c) 2015 Benjamin Tsai. All rights reserved.
//

import UIKit

let detailToComposeSegue = "detailToComposeSegue"
let detailToProfileSegue = "detailToProfileSegue"

protocol DetailViewControllerProtocol: class {
    func detailViewController(detailViewController: DetailViewController, didUpdateTweet: Tweet)
}

class DetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var tweet: Tweet!
    var parentCell: TweetCell!
    
    weak var delegate: DetailViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case detailToComposeSegue:
            let navigationController = segue.destinationViewController as! UINavigationController
            let composeTweetViewController = navigationController.topViewController as! ComposeTweetViewController
            composeTweetViewController.delegate = self
            composeTweetViewController.inReplyToTweet = tweet
        case detailToProfileSegue:
            let profileVc = segue.destinationViewController as! ProfileViewController
            let tweetForView = tweet.retweetedStatus ?? tweet!
            profileVc.account = tweetForView.account!
        default:
            NSLog("Unknown segue: \(segue.identifier)")
        }
    }
    
    @IBAction func onReply(sender: AnyObject) {
        performSegueWithIdentifier(detailToComposeSegue, sender: self)
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetDetailCell", forIndexPath: indexPath) as! TweetCell
        
        cell.delegate = self
        cell.mode = .Detail
        cell.tweet = tweet
        
        return cell
    }
}

extension DetailViewController: ComposeTweetViewControllerDelegate {
    func composeTweetViewController(composeTweetViewController: ComposeTweetViewController, didPublishTweet: Bool) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension DetailViewController: TweetCellProtocol {
    func tweetCell(tweetCell: TweetCell, didUpdateTweet: Tweet) {
        tweet = didUpdateTweet
        delegate?.detailViewController(self, didUpdateTweet: didUpdateTweet)
    }
    
    func tweetCell(tweetCell: TweetCell, replyToTweet: Tweet) {
        performSegueWithIdentifier(detailToComposeSegue, sender: self)
    }
    
    func tweetCell(tweetCell: TweetCell, didTapProfileForTweet: Tweet) {
        performSegueWithIdentifier(detailToProfileSegue, sender: self)
    }
}