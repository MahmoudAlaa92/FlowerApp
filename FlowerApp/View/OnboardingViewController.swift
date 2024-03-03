//
//  OnboardingViewController.swift
//  FlowerApp
//
//  Created by mahmoud on 09/02/2024.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var colllectionView: UICollectionView!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var slides = [OnboardingSlide]()
    
    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == slides.count-1 {
                nextButton.setTitle("Get Stated", for: .normal)
            }else{
                nextButton.setTitle("Next", for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        colllectionView.delegate = self
        colllectionView.dataSource = self
        
        slides = [
            OnboardingSlide(title: "Send flower and send a smile!", description: "Dicover freash flowers online,gift baskets,and florist-designed arrangements", image: UIImage(named:"image3")!), OnboardingSlide(title: "Find your favorite flowers", description: "You can find any type of your favorite flower in this application", image: UIImage(named:"image2")!),OnboardingSlide(title: "Welcome To Our Flowers App ", description: "Beauty flower", image: UIImage(named:"image1")!)
        ]
    }
    @IBAction func nextclicked(_ sender: UIButton) {
        if currentPage == slides.count - 1 {
            
            UserDefaults.standard.setValue(true, forKey: "mainPageState")
            
            let nvcontroller = storyboard?.instantiateViewController(identifier: "homeNV") as! UINavigationController
            
            nvcontroller.modalPresentationStyle = .fullScreen
            nvcontroller.modalTransitionStyle = .flipHorizontal
            
            present(nvcontroller,animated: true)
            
        }else{
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            colllectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
}

extension OnboardingViewController: UICollectionViewDelegate ,UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.dentifier, for: indexPath) as! OnboardingCollectionViewCell
        
        cell.setup(slides[indexPath.row])
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
    
}
