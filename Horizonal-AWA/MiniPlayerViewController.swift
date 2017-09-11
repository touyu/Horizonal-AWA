//
//  MiniPlayerViewController.swift
//  Horizonal-AWA
//
//  Created by Yuto Akiba on 2017/09/11.
//  Copyright © 2017年 Yuto Akiba. All rights reserved.
//

import UIKit

class MiniPlayerViewController: UIViewController {
    
    private var musicManager = MusicManager.shared
    private var miniPlayer = UIView()
    
    private var jacketImageView = UIImageView()
    private var titleLabel = UILabel()
    private var playButton = UIButton()
    private var nextButton = UIButton()
    
    override func loadView() {
        super.loadView()
        
        let view = MiniPlayerView()
        self.view = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        makeMiniPlayer()
        
        if musicManager.queue.count > 0 {
            showMiniPlayer(animated: false)
        } else {
            dismissMiniPlayer(animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        update()
    }
    
    private func makeMiniPlayer() {
        miniPlayer = UIView(frame: CGRect(origin: CGPoint(x: 16, y: view.bounds.height - 68 - 16),
                                              size: CGSize(width: 264, height: 68)))
        miniPlayer.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        miniPlayer.layer.masksToBounds = true
        miniPlayer.layer.cornerRadius = 8
        miniPlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedJacketImageView)))
        miniPlayer.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(pannedMiniPlayer(_:))))
        view.addSubview(miniPlayer)
        
        jacketImageView = UIImageView(frame: CGRect(x: 16, y: 16, width: 36, height: 36))
//        jacketImageView.image = musicManager.playingMusic.jacketImage
        jacketImageView.contentMode = .scaleAspectFill
        jacketImageView.layer.masksToBounds = true
        jacketImageView.layer.cornerRadius = 2
//        jacketImageView.isUserInteractionEnabled = true
//        jacketImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedJacketImageView)))
        miniPlayer.addSubview(jacketImageView)
        
        titleLabel = UILabel(frame: CGRect(x: 16 + 36 + 16, y: 0, width: 100, height: 12))
        titleLabel.center.y = jacketImageView.center.y
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightBold)
        miniPlayer.addSubview(titleLabel)
        
        playButton = UIButton(frame: CGRect(origin: CGPoint(x: titleLabel.frame.origin4.x + 8, y: 0),
                                                size: CGSize(width: 32, height: 32)))
        playButton.center.y = titleLabel.center.y
        playButton.addTarget(self, action: #selector(tappedPlayButton), for: .touchUpInside)
        miniPlayer.addSubview(playButton)
        
        nextButton = UIButton(frame: CGRect(origin: CGPoint(x: playButton.frame.origin4.x + 8, y: 0),
                                            size: CGSize(width: 32, height: 32)))
        nextButton.center.y = titleLabel.center.y
        nextButton.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
        nextButton.setImage(#imageLiteral(resourceName: "next2"), for: .normal)
        miniPlayer.addSubview(nextButton)
    }
    
    func dismissMiniPlayer(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.miniPlayer.frame.origin.x = -self!.miniPlayer.bounds.width
            })
            
            UIView.animate(withDuration: 0.2,animations: { [weak self] in
                self?.miniPlayer.frame.origin.x = -self!.miniPlayer.bounds.width
                }, completion: { [weak self]  _ in
                    self?.miniPlayer.alpha = 1
            })
        } else {
            miniPlayer.frame.origin.x = -miniPlayer.bounds.width
        }
    }
    
    func showMiniPlayer(animated: Bool) {
        // 更新
        update()
        
        if animated {
            
            // 隠れている場合のみアニメーションして表示させる
            if miniPlayer.frame.origin.x == -miniPlayer.bounds.width {
                UIView.animate(withDuration: 0.2, animations: { [weak self] _ in
                    self?.miniPlayer.frame.origin.x = 16
                })
            }
        } else {
            miniPlayer.frame.origin.x = 16
        }
    }
    
    func tappedPlayButton() {
        if musicManager.audioPlayer.isPlaying {
            playButton.setImage(#imageLiteral(resourceName: "playing2"), for: .normal)
            musicManager.pause()
        } else {
            playButton.setImage(#imageLiteral(resourceName: "pause2"), for: .normal)
            musicManager.play()
        }
    }
    
    func tappedNextButton() {
        musicManager.next()
        update()
    }
    
    func tappedJacketImageView() {
        let playMusicNC = PlayMusicNavigationController.instantiate(withStoryboard: "Main")
        show(playMusicNC, sender: self)
    }
    
    private func update() {
        if musicManager.queue.count == 0 {
            return
        }
        
        jacketImageView.image = musicManager.playingMusic.jacketImage
        jacketImageView.layer.add(CATransition(), forKey: nil)
        titleLabel.text = musicManager.playingMusic.title
        titleLabel.layer.add(CATransition(), forKey: nil)
        let buttonImage = musicManager.audioPlayer.isPlaying ? #imageLiteral(resourceName: "pause2") : #imageLiteral(resourceName: "playing2")
        playButton.setImage(buttonImage, for: .normal)
    }
    
    func pannedMiniPlayer(_ gesture: UIPanGestureRecognizer) {
//        if gesture.state == .ended {
//            // タップ開始地点からの移動量を取得
//            let position = gesture.translation(in: view)
//            tapEndPosX = position.x
//            tapEndPosY = -position.y
//        }
        let point = gesture.translation(in: view)
        let newPointX = gesture.view!.frame.origin.x + point.x
        let newPointY = gesture.view!.frame.origin.y + point.y
        
        if newPointX < -miniPlayer.bounds.width/3 {
            miniPlayer.alpha = 0.6
            if gesture.state == .ended {
                dismissMiniPlayer(animated: true)
                return
            }
        } else {
            miniPlayer.alpha = 1
        }
        
        gesture.view!.frame.origin.x = newPointX
        gesture.view!.frame.origin.y = newPointY
        gesture.setTranslation(.zero, in: view)
//        let newPointX = sender.view!.center.x + point.x
//        let convertedPointX = view.convert(CGPoint(x: newPointX, y: 0), to: sequenceBar).x
//        // 行き過ぎを防ぐ
//        
//        if convertedPointX < 0 {
//            musicManager.audioPlayer.currentTime = 0
//            sender.setTranslation(.zero, in: sequenceBar)
//            return
//        }
//        
//        if convertedPointX > sequenceBar.bounds.width-1 {
//            musicManager.audioPlayer.currentTime = musicManager.audioPlayer.duration-1
//            sender.setTranslation(.zero, in: sequenceBar)
//            return
//        }
//        
//        sender.view!.center.x = newPointX
//        let (index, y) = calculatePlayButtonY(x: sender.view!.center.x)
//        sender.view!.center.y = y
//        if sender.state == .ended {
//            musicManager.audioPlayer.currentTime = musicManager.audioPlayer.duration * TimeInterval(index) / TimeInterval(100)
//            if musicManager.audioPlayer.isPlaying {
//                animatePlayButton(count: index)
//            }
//        }
    }
}

class MiniPlayerView: UIView {
    
    convenience init() {
        self.init(frame: UIScreen.main.bounds)
        backgroundColor = .clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            return nil
        } else {
            return view
        }
    }
}
