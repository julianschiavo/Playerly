//
//  DocumentViewController.swift
//  Playerly
//
//  Created by Julian Schiavo on 14/12/2018.
//  Copyright © 2018 Julian Schiavo. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoViewController: UIViewController, UIGestureRecognizerDelegate, PullToDismissable, UIViewControllerTransitioningDelegate, ErrorThrower {
    var video: Video!
    var tapGestureRecognizer = UITapGestureRecognizer()
    
    var playerViewController: AVPlayerViewController!
    @IBOutlet weak var playerView: UIView!
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var switchButton: UIButton!
    
    override func viewDidLoad() {
        guard video != nil else {
            fatalError("A video is required to initialize this view controller.")
        }
        
        if let playerController = children.first as? AVPlayerViewController {
            playerViewController = playerController
        } else {
            fatalError("Failed to find the player view controller. Check the storyboard for the missing view controller.")
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            fatalError("Failed to set the AVAudioSession category `moviePlayback` to `active`.")
        }
        
        setupRounding()
        preparePreview()
        setupPlayer()
        
        switchButton.tintColor = .orange
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissVideoViewController))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        playerViewController.player?.pause()
        
//        ERROR: AVAudioSession.mm:1080:-[AVAudioSession setActive:withOptions:error:]: Deactivating an audio session that has running I/O. All I/O should be stopped or paused prior to deactivating the audio session.
        
//        do {
//            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
//        } catch {
//            print("Error: \(error.localizedDescription)")
//            fatalError("Failed to de-activate the AVAudioSession category `moviePlayback`.")
//        }
    }
    
    func setupRounding() {
        previewView.layer.masksToBounds = true
        previewView.layer.cornerRadius = 15
        
        previewImageView.layer.masksToBounds = true
        previewImageView.layer.cornerRadius = 10
        
        playerViewController.view.layer.masksToBounds = true
        playerViewController.view.layer.cornerRadius = 15
    }
    
    func preparePreview() {
        video.open(completionHandler: { (success) in
            guard success else {
                // TODO: Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
                return
            }
            
            self.nameLabel.text = self.video.fileURL.lastPathComponent
            
            let asset = AVAsset(url: self.video.fileURL)
            
            let durationInSeconds = asset.duration.seconds
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = durationInSeconds < 61 ? .abbreviated : .positional
            let duration = formatter.string(from: durationInSeconds)
            self.timeLabel.text = duration
            
            let generator = AVAssetImageGenerator(asset: asset)
            do {
                // Number of seconds into the video = Value/Timescale
                let cgImage = try generator.copyCGImage(at: CMTime(value: 3, timescale: 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                self.previewImageView.image = thumbnail
            } catch {
                self.throwError("There was an error when attemping to load the video.\n\n(\(error.localizedDescription)).")
            }
        })
    }
    
    func setupPlayer() {
        let player = AVPlayer(url: video!.fileURL)
        playerViewController.player = player
        playerViewController.exitsFullScreenWhenPlaybackEnds = true
    }
    
    @IBAction func dismissVideoViewController() {
        // Make sure the tap is not in the preview view
        let location = tapGestureRecognizer.location(in: view)
        guard !previewView.frame.contains(location) else { return }
        
        self.video.close(completionHandler: nil)
        playerViewController.player?.pause()
        
        if isPullToDismissEnabled {
            setPullToDismissEnabled(false)
        }
        
        dismiss(animated: true) {
            self.video.close(completionHandler: nil)
        }
    }
    
    // MARK: PullToDismissable
    lazy var pullToDismissTransition: PullToDismissTransition = PullToDismissTransition(viewController: self)
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        setupPullToDismiss()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupPullToDismiss()
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            guard isPullToDismissEnabled else { return nil }
            return pullToDismissTransition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
            guard isPullToDismissEnabled else { return nil }
            return pullToDismissTransition
    }

}
