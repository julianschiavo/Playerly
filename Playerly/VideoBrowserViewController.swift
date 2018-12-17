//
//  VideoBrowserViewController.swift
//  Playerly
//
//  Created by Julian Schiavo on 14/12/2018.
//  Copyright © 2018 Julian Schiavo. All rights reserved.
//

import UIKit
import MobileCoreServices

class VideoBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        allowsDocumentCreation = false
        allowsPickingMultipleItems = false
        
        browserUserInterfaceStyle = .dark
        view.tintColor = .orange
    }
    
    // MARK: Video Playback
    
    func playVideo(at videoURL: URL) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var videoViewController = storyBoard.instantiateViewController(withIdentifier: "VideoViewController") as! VideoViewController
        videoViewController.video = Video(fileURL: videoURL)
        videoViewController.isPullToDismissEnabled = true
        videoViewController.modalPresentationCapturesStatusBarAppearance = true

        present(videoViewController, animated: true, completion: nil)
    }
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        print("didPickDocumentsAt")
        guard let sourceURL = documentURLs.first else { return }
        // Play the video that was selected.
        playVideo(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Play the video.
        print("didImportDocumentAt:toDestinationURL:")
        playVideo(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
        print("failedToImportDocumentAt:error:")
        fatalError()
    }
}

