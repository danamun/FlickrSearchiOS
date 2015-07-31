//
//  FlickrPhotosViewController.swift
//  FlickrSearch
//
//  Created by Da Y Mun on 7/30/15.
//  Copyright (c) 2015 danamun. All rights reserved.
//

/*Supplementary views: if you have something that is not a cell but you want it in your collection view
Decoration Views: use it to enhance the appearence of your collection view but don't really contain useful data.
UICollectionViewLayout: responsible for size, position and several other attributes of the content. Layouts can be swapped during runtime. This tutorial will use layout flow, which is already created by Apple. 

UICollectioViewDataSource: returns information about the number of items in the colletion view and their views.

UICollectionViewDelegate: is notified when events happen such as cells being selected, highlighted, or removed.

UICollectionViewFlowLayout: allows you to tweak the behaviour of the layout, configuring things like the cell spacing, scroll direction, and more.

UICollectionViewDelegateFlowLayout: methods on your view controller, so you are all set up to work with your collection view.
*/

import UIKit

class FlickrPhotosViewController: UICollectionViewController {
    private let reuseIdentifier = "FlickrCell" // Datasource will use this to dequeue or create new cells.
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    private var searches = [FlickrSearchResults]()
    private let flickr = Flickr()
    
    func photoForIndexPath(indexPath : NSIndexPath) -> FlickrPhoto {
        return searches[indexPath.section].searchResults[indexPath.row]
    }
}

extension FlickrPhotosViewController : UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        flickr.searchFlickrForTerm(textField.text) {
            results, error in
            activityIndicator.removeFromSuperview()
            if error != nil {
                println("Error searching : \(error)")
            }
            
            if results != nil {
                println("Found \(results!.searchResults.count) matching \(results!.searchTerm)")
                self.searches.insert(results!, atIndex: 0)
                self.collectionView?.reloadData()
            }
        }
        
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}

extension FlickrPhotosViewController : UICollectionViewDataSource {
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return searches.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches[section].searchResults.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FlickrPhotoCell
        let flickrPhoto = photoForIndexPath(indexPath)
        cell.backgroundColor = UIColor.blackColor()
        cell.imageView.image = flickrPhoto.thumbnail
        return cell
        
    }
}

extension FlickrPhotosViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let flickrPhoto = photoForIndexPath(indexPath)
        if var size = flickrPhoto.thumbnail?.size {
            size.width += 10
            size.height += 10
            return size
        }
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtInde section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
}