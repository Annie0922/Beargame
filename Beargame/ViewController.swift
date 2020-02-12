//
//  ViewController.swift
//  Beargame
//
//  Created by Anan on 2020/2/2.
//  Copyright © 2020 Anan. All rights reserved.
//

import UIKit
import GameplayKit


class ViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet var bearButtons: [UIButton]!
    @IBOutlet weak var movesMade: UILabel!

    var count = 0
    var bears = [Bear]()
    var selectedBears = [Int]()
    var moves = 0
    var pairsFound = 0
    var time: Timer?
    var seconds = 60
    var isPlaying = false
    var stopTapped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gameInit()
    }
    
    struct Bear {
        var name: String?
        var image: UIImage?
        var isFlipped: Bool = false
        var isAlive: Bool = true
        var timeoutHolding = false
    }
    
    func gameInit() -> Void {
        bears.removeAll()
        bears = [
            Bear(name: "bear1", image: UIImage(named: "bear1")),
            Bear(name: "bear3", image: UIImage(named: "bear3")),
            Bear(name: "bear4", image: UIImage(named: "bear4")),
            Bear(name: "bear4", image: UIImage(named: "bear4")),
            Bear(name: "bear5", image: UIImage(named: "bear5")),
            Bear(name: "bear6", image: UIImage(named: "bear6")),
            Bear(name: "bear7", image: UIImage(named: "bear7")),
            Bear(name: "bear3", image: UIImage(named: "bear3")),
            Bear(name: "bear5", image: UIImage(named: "bear5")),
            Bear(name: "bear6", image: UIImage(named: "bear6")),
            Bear(name: "bear7", image: UIImage(named: "bear7")),
            Bear(name: "bear2", image: UIImage(named: "bear2")),
            Bear(name: "bear8", image: UIImage(named: "bear8")),
            Bear(name: "bear2", image: UIImage(named: "bear2")),
            Bear(name: "bear8", image: UIImage(named: "bear8")),
            Bear(name: "bear1", image: UIImage(named: "bear1"))]
        bears.shuffle()
        selectedBears.removeAll()
        moves = 0
        displayBears()
    }

    //翻牌(是否相同）
    func disAbleBear(index: Int) -> Void {
        bears[index].isAlive = false
        bearButtons[index].alpha = 0.4
        UIView.transition(with: bearButtons[index], duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
    
    func displayBears() -> Void {
        for (i,_) in bearButtons.enumerated() {
            if bears[i].isAlive == true{
                if bears[i].isFlipped == true {
                    bearButtons[i].setImage(bears[i].image, for: .normal)
                }else{
                    bearButtons[i].setImage(UIImage(named: "Back.png"), for: .normal)
                }
            }else{
                bearButtons[i].setImage(bears[i].image, for: .normal)
                bearButtons[i].alpha = 0.4
            }
        }
    }
    //翻牌動作
    @IBAction func flipBear(_ sender: UIButton) {
        
        func flipBearIndex(index: Int) -> Void {
            if bears[index].isFlipped == true {
                bearButtons[index].setImage(UIImage(named: "Back.png"), for: .normal)
                UIView.transition(with: bearButtons[index], duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
                bears[index].isFlipped = false
            } else {
                bearButtons[index].setImage(bears[index].image, for: .normal)
                UIView.transition(with: bearButtons[index], duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
                bears[index].isFlipped = true
            }
        }
        if time == nil{
            time = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.UpdateTimer), userInfo: nil, repeats: true)
        }
        if let bearIndex = bearButtons.firstIndex(of: sender){
            if bears[bearIndex].isAlive == false{
                return
            }
            if selectedBears.count == 0 {
                selectedBears.append(bearIndex)
                flipBearIndex(index: bearIndex)
            }else if selectedBears.count == 1 {
                moves += 1
                movesMade.text = String(moves)
                if selectedBears.contains(bearIndex) {
                    flipBearIndex(index: bearIndex)
                    selectedBears.removeAll()
                }else{
                    selectedBears.append(bearIndex)
                    flipBearIndex(index: bearIndex)
                    if bears[selectedBears[0]].name == bears[selectedBears[1]].name{
                        //disable
                        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false){ (_) in
                        for (_,num) in self.selectedBears.enumerated() {
                            self.disAbleBear(index: num)
                        }
                            self.selectedBears.removeAll()
                            self.pairsFound += 1
                            if self.pairsFound == 8 {
                                self.time?.invalidate()
                                //在時間內完成，會跳出視窗訊息視窗，按下ok會直接重新開始
                                let controller = UIAlertController(title: "挑戰成功", message: "再來一場！！", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                                    self.restartAction()
                                }
                                controller.addAction(okAction)
                                //在時間內結束時間也會跟著暫停
                                self.present(controller, animated: true, completion: nil)
                                print("game end")
                                
                            }
                        }
                    }else{
                        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) {
                            (_) in for(_,num) in self.selectedBears.enumerated() {
                                flipBearIndex(index: num)
                            }
                            self.selectedBears.removeAll()
                            
                        }
                    }
                }
            }
        }
    }
    
   //未在時間內完成遊戲，而會跳出警告訊息，按下ok則會重新開始
    @objc func UpdateTimer() {
        seconds = seconds - 1
        if seconds == 0{
            time?.invalidate()
            time = nil
            isPlaying = false
            let controller = UIAlertController(title: "挑戰失敗", message: "回家練練再來吧！", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.restartAction()
            }
            controller.addAction(okAction)
            present(controller, animated: true, completion: nil)
        }
        timeLabel.text = String(seconds)
    }
    
    //重新開始的動作
    @IBAction func restart(_ sender: Any) {
        restartAction()
    }
    
    func restartAction() {
        gameInit()
        movesMade.text = String(moves)
        pairsFound = 0
        seconds = 60
        isPlaying = false
        time?.invalidate()
        time = nil
        timeLabel.text = String(seconds)
        for (i,_) in bearButtons.enumerated() {
            bearButtons[i].alpha = 1
        }
    }
}



