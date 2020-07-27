//  Created by Michael Kucinski on 7/22/20.
//  Copyright © 2020 Michael Kucinski. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    class func imageWithLabel(label: UILabel) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageHere = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageHere!
    }
}

public extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}


public class LitFuseBasicViewController: UIViewController, UITextViewDelegate {
    
    var poolOfEmittersAlreadyCreated = false
    public var arrayOfEmitters = [CAEmitterLayer]()
    var arrayOfCells = [CAEmitterCell]()
    
    let emojiLengthPerSide : Int = 100
    
    var lastChosenEmissionLongitude : CGFloat = 2 * CGFloat.pi
    var lastChosenEmissionLatitude : CGFloat = 2 * CGFloat.pi
    var lastChosenEmissionRange : CGFloat = 2 * CGFloat.pi
    var lastChosenAutoReverses : Bool = false
    var lastChosenIsEnabled : Bool = true
    var continuoslyBurnFuseEnable : Bool = false
    var totalFramesSinceStarting = 0
    var frameWhenWeChangeCellImages = 0
    var changeCellImagesEnabled = false
    var litFuseEffectEnabled = false
    var singlePassInUseAndValid = false
    var continuousFuseEffectEnabled = false
    var indexIntoArrayOfStrings = 0
    var arrayOfStringsForCycling = [String]()
    var cycleTime : CGFloat = 0
    var framesBetweenCycles : Int = 1
    var startIndexForCycling = 0
    var endIndexForCycling = 0
    var savedFuseStartIndex : Int = 0
    var savedFuseEndIndex : Int = 0
    var savedFuseStepsPerFrame : Int = 1
    var repeatingLastLitFuseEnabled = false
    var numberOfFramesBetweenRepeatedLitFuseDisplays = 2
    var countDownForRepeatingLitFuse = 2
    var scaleSyncedToLifetime : Bool = false
    var alphaSyncedToLifetime : Bool = false
    var lastStartIndexForVisibleEmitters = 0
    var lastEndIndexForVisibleEmitters = 0
    
    var combingEmittersInProgress : Bool = false
    
    // saved parameters from last call to createLitFuseEffectForDesiredRangeOfEmitters
  
    var prior_initialTint : UIColor = .white
    var prior_fuseBurningTint : UIColor = .white
    var prior_endingTint : UIColor = .white

    var prior_startIndex : Int = 1
    var prior_endIndex : Int = 2
    var prior_initialVelocity : CGFloat = 300
    var prior_initialVelocityRange : CGFloat = 0
    var prior_endingVelocity : CGFloat = 0
    var prior_endingVelocityRange : CGFloat = 0
    var prior_endingAlphaSpeed : CGFloat = 0
    var prior_endingAlphaRange : CGFloat = 0
    var prior_initialScale : CGFloat = 0.5
    var prior_initialScaleSpeed : CGFloat = 0
    var prior_initialScaleRange : CGFloat = 0
    var prior_initialSpin : CGFloat = 0
    var prior_initialSpinRange : CGFloat = 0
    var prior_initialAcceleration_X : CGFloat = 0
    var prior_initialAcceleration_Y : CGFloat = 0
    var prior_initialAlphaSpeed : CGFloat = 0
    var prior_initialAlphaRange : CGFloat = 0
    var prior_fuseBurningScale : CGFloat = 1
    var prior_fuseBurningScaleSpeed : CGFloat = 0
    var prior_fuseBurningScaleRange : CGFloat = 0
    var prior_fuseBurningSpin : CGFloat = 0
    var prior_fuseBurningSpinRange : CGFloat = 0
    var prior_fuseBurningVelocity : CGFloat = 300
    var prior_fuseBurningVelocityRange : CGFloat = 0

    var prior_fuseBurningAcceleration_X : CGFloat = 0
    var prior_fuseBurningAcceleration_Y : CGFloat = 0
    var prior_fuseBurningAlphaSpeed : CGFloat = 0
    var prior_fuseBurningAlphaRange : CGFloat = 0


    var prior_endingScale : CGFloat = 0
    var prior_endingScaleSpeed : CGFloat = 0
    var prior_endingScaleRange : CGFloat = 0
    var prior_endingSpin : CGFloat = 0
    var prior_endingSpinRange : CGFloat = 0
    var prior_endingAcceleration_X : CGFloat = 0
    var prior_endingAcceleration_Y : CGFloat = 0
    var prior_stepsPerFrame : Int = 1
    var prior_initialBirthRate : CGFloat = 41
    var prior_fuseBurningBirthRate : CGFloat = 100
    var prior_endingBirthRate : CGFloat = 1
    
    var prior_initialCellLifetime : CGFloat = 0.5
    var prior_initialCellLifetimeRange : CGFloat = 0
    var prior_fuseBurningCellLifetime : CGFloat = 0.5
    var prior_fuseBurningCellLifetimeRange : CGFloat = 0
    var prior_endingCellLifetime : CGFloat = 0.5
    var prior_endingCellLifetimeRange : CGFloat = 0

    
    var prior_continuousFuseDesired : Bool = false
    var prior_repeatingFuseDesired : Bool = false
    var prior_timeBetweenRepeatsInSeconds : CGFloat = 30
    var transitionToFuseBurningVelocityIndex = 0
    var transitionToEndingVelocityIndex = 0
    var transitionToEndingVelocityIndexHasBegun : Bool = false
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        
        var localTimer = Timer()
        
        if localTimer.isValid
        {
            // This blank if statement gets rid of a nuisance warning about never reading the timer.
        }
        
        // start the timer
        localTimer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(handleTimerEvent), userInfo: nil, repeats: true)
    }
    
    // starts handleTimer...
    @objc func handleTimerEvent()
    {
        totalFramesSinceStarting += 1
        
        if changeCellImagesEnabled
        {
            if totalFramesSinceStarting >= frameWhenWeChangeCellImages
            {
                frameWhenWeChangeCellImages += framesBetweenCycles
                
                // Get next string
                
                let newStringToImage = arrayOfStringsForCycling[indexIntoArrayOfStrings]
                
                setCellImageFromTextStringForDesiredRangeOfEmitters(desiredImageAsText: newStringToImage, startIndex: startIndexForCycling, endIndex: endIndexForCycling)
                
                indexIntoArrayOfStrings += 1
                if indexIntoArrayOfStrings >= arrayOfStringsForCycling.count
                {
                    indexIntoArrayOfStrings = 0
                }
            }
        }
        
        if litFuseEffectEnabled && !combingEmittersInProgress
        {
            if continuousFuseEffectEnabled
            {
                for _ in 1...savedFuseStepsPerFrame
                {
                    // Transition this emitter to fuse burning velocity
                    let thisCell = arrayOfCells[transitionToFuseBurningVelocityIndex]
                    let thisEmitter = arrayOfEmitters[transitionToFuseBurningVelocityIndex]
                    
                    thisEmitter.beginTime = CACurrentMediaTime()
                    
                    let aCell = makeCellBasedOnFuseBurning(thisEmitter: thisEmitter, oldCell: thisCell)

                    if scaleSyncedToLifetime
                    {
                        aCell.scaleSpeed = -1 * aCell.scale / CGFloat(aCell.lifetime)
                    }
                    if alphaSyncedToLifetime
                    {
                        aCell.alphaSpeed = -1 / aCell.lifetime                        
                    }

                    thisEmitter.emitterCells = [aCell]
                    
                    // Update the array
                    arrayOfCells[transitionToFuseBurningVelocityIndex] = aCell

                    transitionToFuseBurningVelocityIndex += 1
                    
                    let tempsavedFuseStepsPerFrame : Int = Int(savedFuseStepsPerFrame)
                    
                    if transitionToFuseBurningVelocityIndex >  tempsavedFuseStepsPerFrame
                    {
                        transitionToEndingVelocityIndexHasBegun = true
                    }
                    
                    if transitionToFuseBurningVelocityIndex >= arrayOfEmitters.count
                    {
                        transitionToFuseBurningVelocityIndex = 0
                    }
                }
                if transitionToEndingVelocityIndexHasBegun
                {
                    for _ in 1...savedFuseStepsPerFrame
                    {
                        // Transition this emitter to ending velocity
                        
                        let thisCell = arrayOfCells[transitionToEndingVelocityIndex]
                        let thisEmitter = arrayOfEmitters[transitionToEndingVelocityIndex]
                        
                        thisEmitter.beginTime = CACurrentMediaTime()

                        thisEmitter.beginTime = CACurrentMediaTime()
                        
                        let aCell = makeCellBasedOnEndingState(thisEmitter: thisEmitter, oldCell: thisCell)
                        if scaleSyncedToLifetime
                        {
                            aCell.scaleSpeed = -1 * aCell.scale / CGFloat(aCell.lifetime)
                        }
                        if alphaSyncedToLifetime
                        {
                            aCell.alphaSpeed = -1 / aCell.lifetime
                        }

                        thisEmitter.emitterCells = [aCell]
                        
                        // Update the array
                        arrayOfCells[transitionToEndingVelocityIndex] = aCell

                        transitionToEndingVelocityIndex += 1
                        
                        if transitionToEndingVelocityIndex >= arrayOfEmitters.count
                        {
                            transitionToEndingVelocityIndex = 0
                        }
                    }
                }
            }
            else // continuousFuseEffectEnabled is false
            {
                if singlePassInUseAndValid
                {
                    for _ in 1...savedFuseStepsPerFrame
                    {
                        // Transition this emitter to fuse burning velocity
                        let thisCell = arrayOfCells[transitionToFuseBurningVelocityIndex]
                        let thisEmitter = arrayOfEmitters[transitionToFuseBurningVelocityIndex]
                                                
                        thisEmitter.beginTime = CACurrentMediaTime()
                        
                        let aCell = makeCellBasedOnFuseBurning(thisEmitter: thisEmitter, oldCell: thisCell)
                        
                        if scaleSyncedToLifetime
                        {
                            aCell.scaleSpeed = -1 * aCell.scale / CGFloat(aCell.lifetime)
                        }
                        if alphaSyncedToLifetime
                        {
                            aCell.alphaSpeed = -1 / aCell.lifetime
                        }

                        thisEmitter.emitterCells = [aCell]
                        
                        // Update the array
                        arrayOfCells[transitionToFuseBurningVelocityIndex] = aCell

                        transitionToFuseBurningVelocityIndex += 1
                        
                        let tempsavedFuseStepsPerFrame : Int = Int(savedFuseStepsPerFrame)
                        
                        if transitionToFuseBurningVelocityIndex >  tempsavedFuseStepsPerFrame
                        {
                            transitionToEndingVelocityIndexHasBegun = true
                        }
                        
                        if transitionToFuseBurningVelocityIndex >= arrayOfEmitters.count
                        {
                            // stop the fuse burning
                            singlePassInUseAndValid = false
                            
                            // break out of the loop
                            break
                        }
                    }
                }
                
                if transitionToEndingVelocityIndexHasBegun
                {
                    for _ in 1...savedFuseStepsPerFrame
                    {
                        // Transition this emitter to ending velocity
                        
                        let thisCell = arrayOfCells[transitionToEndingVelocityIndex]
                        let thisEmitter = arrayOfEmitters[transitionToEndingVelocityIndex]
                        
                        thisEmitter.beginTime = CACurrentMediaTime()
                        
                        thisEmitter.beginTime = CACurrentMediaTime()
                        
                        let aCell = makeCellBasedOnEndingState(thisEmitter: thisEmitter, oldCell: thisCell)
                        if scaleSyncedToLifetime
                        {
                            aCell.scaleSpeed = -1 * aCell.scale / CGFloat(aCell.lifetime)
                        }
                        if alphaSyncedToLifetime
                        {
                            aCell.alphaSpeed = -1 / aCell.lifetime
                        }

                        thisEmitter.emitterCells = [aCell]
                        
                        // Update the array
                        arrayOfCells[transitionToEndingVelocityIndex] = aCell
                        
                        transitionToEndingVelocityIndex += 1
                        
                        if transitionToEndingVelocityIndex >= arrayOfEmitters.count
                        {
                            // stop the fuse ending velocity
                            transitionToEndingVelocityIndexHasBegun = false
                            
                            // and start the countdown if needed
                            
                            countDownForRepeatingLitFuse = numberOfFramesBetweenRepeatedLitFuseDisplays
                            
                            // break out of the loop
                            break
                        }
                    }
                }
            }
            
        } // ends if litFuseEffectEnabled
        
        if repeatingLastLitFuseEnabled  && !combingEmittersInProgress
        {
            if countDownForRepeatingLitFuse == numberOfFramesBetweenRepeatedLitFuseDisplays / 2
            {
                hideAllEmittersButPreserveRepeating()
            }
            if countDownForRepeatingLitFuse == 0
            {
                createLitFuseEffectForDesiredRangeOfEmitters(
                    startIndex                  : prior_startIndex,
                    endIndex                    : prior_endIndex,
                    initialVelocity             : prior_initialVelocity,
                    initialVelocityRange        : prior_initialVelocityRange,
                    initialBirthRate            : prior_initialBirthRate,
                    initialScale                : prior_initialScale,
                    initialScaleSpeed           : prior_initialScaleSpeed,
                    initialScaleRange           : prior_initialScaleRange,
                    initialSpin                 : prior_initialSpin,
                    initialSpinRange            : prior_initialSpinRange,
                    initialAcceleration_X       : prior_initialAcceleration_X,
                    initialAcceleration_Y       : prior_initialAcceleration_Y,
                    initialAlphaSpeed           : prior_initialAlphaSpeed,
                    initialAlphaRange           : prior_initialAlphaRange,
                    initialTint                 : prior_initialTint,
                    fuseBurningVelocity         : prior_fuseBurningVelocity,
                    fuseBurningVelocityRange    : prior_fuseBurningVelocityRange,
                    fuseBurningBirthRate        : prior_fuseBurningBirthRate,
                    fuseBurningScale            : prior_fuseBurningScale,
                    fuseBurningScaleSpeed       : prior_fuseBurningScaleSpeed,
                    fuseBurningScaleRange       : prior_fuseBurningScaleRange,
                    fuseBurningSpin             : prior_fuseBurningSpin,
                    fuseBurningSpinRange        : prior_fuseBurningSpinRange,
                    fuseBurningAcceleration_X   : prior_fuseBurningAcceleration_X,
                    fuseBurningAcceleration_Y   : prior_fuseBurningAcceleration_Y,
                    fuseBurningAlphaSpeed       : prior_fuseBurningAlphaSpeed,
                    fuseBurningAlphaRange       : prior_fuseBurningAlphaRange,
                    fuseBurningTint             : prior_fuseBurningTint,
                    endingVelocity              : prior_endingVelocity,
                    endingVelocityRange         : prior_endingVelocityRange,
                    endingBirthRate             : prior_endingBirthRate,
                    endingScale                 : prior_endingScale,
                    endingScaleSpeed            : prior_endingScaleSpeed,
                    endingScaleRange            : prior_endingScaleRange,
                    endingSpin                  : prior_endingSpin,
                    endingSpinRange             : prior_endingSpinRange,
                    endingAcceleration_X        : prior_endingAcceleration_X,
                    endingAcceleration_Y        : prior_endingAcceleration_Y,
                    endingAlphaRange            : prior_endingAlphaRange,
                    endingAlphaSpeed            : prior_endingAlphaSpeed,
                    endingTint                  : prior_endingTint,
                    stepsPerFrame               : prior_stepsPerFrame,
                    initialCellLifetime         : prior_initialCellLifetime,
                    initialCellLifetimeRange    : prior_initialCellLifetimeRange,
                    fuseBurningCellLifetime      : prior_fuseBurningCellLifetime,
                    fuseBurningCellLifetimeRange : prior_fuseBurningCellLifetimeRange,
                    endingCellLifetime         : prior_endingCellLifetime,
                    endingCellLifetimeRange    : prior_endingCellLifetimeRange,
                    continuousFuseDesired       : prior_continuousFuseDesired,
                    repeatingFuseDesired        : prior_repeatingFuseDesired,
                    timeBetweenRepeatsInSeconds  : prior_timeBetweenRepeatsInSeconds)
            }
            
        } // ends if repeatingLastLitFuseEnabled
        
        countDownForRepeatingLitFuse -= 1
        
    } // ends handleTimerEvent
    
    public func createPoolOfEmitters(
        maxCountOfEmitters : Int,
        someEmojiCharacter : String)
    {
        if poolOfEmittersAlreadyCreated
        {
            return
        }
        
        var seedCurrent = 0
        
        let emojiString = someEmojiCharacter
        let textOrEmojiToUIImage = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        textOrEmojiToUIImage.textColor = UIColor.red
        textOrEmojiToUIImage.backgroundColor = UIColor.clear
        
        textOrEmojiToUIImage.text = emojiString
        textOrEmojiToUIImage.sizeToFit()
        
        for _ in 1...maxCountOfEmitters {
            
            let thisEmitter = CAEmitterLayer()
            
            thisEmitter.isHidden = false
            thisEmitter.emitterPosition = CGPoint(x: -1000, y: 0)
            
            thisEmitter.emitterShape = .point
            thisEmitter.emitterSize = CGSize(width: 50, height: 50)
            thisEmitter.renderMode = CAEmitterLayerRenderMode.oldestFirst
            
            let emojiString = someEmojiCharacter
            let textOrEmojiToUIImage = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            
            textOrEmojiToUIImage.text = emojiString
            textOrEmojiToUIImage.sizeToFit()
            
            let tempImageToUseWhenChangingCellImages  =  UIImage.imageWithLabel(label: textOrEmojiToUIImage)
            
            let aCell = makeCell(thisEmitter: thisEmitter, newColor: .white, contentImage: tempImageToUseWhenChangingCellImages)
            
            thisEmitter.emitterCells = [aCell]
            
            seedCurrent += 1
            thisEmitter.seed = UInt32(seedCurrent)
            
            arrayOfEmitters.append(thisEmitter)
            arrayOfCells.append(aCell)
        }
        
        hideAllEmitters()
        
        poolOfEmittersAlreadyCreated = true
        
    } // ends createPoolOfEmitters
    
    func makeCell(
        thisEmitter     : CAEmitterLayer,
        newColor        : UIColor,
        contentImage    : UIImage) -> CAEmitterCell
    {
        let cell = CAEmitterCell()
        
        cell.birthRate          = Float(prior_initialBirthRate)
        cell.lifetime           = Float(prior_initialCellLifetime)
        cell.lifetimeRange      = Float(prior_initialCellLifetimeRange)
        cell.color              = newColor.cgColor
        cell.emissionLongitude  = lastChosenEmissionLongitude
        cell.emissionLatitude   = lastChosenEmissionLatitude
        cell.emissionRange      = lastChosenEmissionRange
        cell.spin               = prior_initialSpin
        cell.spinRange          = prior_initialSpinRange
        cell.scale              = prior_initialScale
        cell.scaleRange         = prior_initialScaleRange
        cell.scaleSpeed         = prior_initialScaleSpeed
        cell.alphaSpeed         = Float(prior_initialAlphaSpeed)
        cell.alphaRange         = Float(prior_initialAlphaRange)
        cell.autoreverses       = lastChosenAutoReverses
        cell.isEnabled          = lastChosenIsEnabled
        cell.velocity           = prior_initialVelocity
        cell.velocityRange      = prior_initialVelocityRange
        cell.xAcceleration      = prior_initialAcceleration_X
        cell.yAcceleration      = prior_initialAcceleration_Y
        cell.zAcceleration      = 0
        cell.contents           = contentImage.cgImage
        cell.name               = "myCellName"
        
        // cell.beginTime .. https://stackoverflow.com/questions/51271868/what-is-the-proper-way-to-end-a-caemitterlayer-in-swift You can set the emitterLayer.lifetime to something other than 0. You'll also potentially want to set  emitterLayer.beginTime = CACurrentMediaTime() when starting it up again, otherwise sprites may appear where you wouldn't expect them. – Dave Y May 2 at 14:21
        
        return cell
        
    } // ends makeCell
    
    func makeCellBasedOnPreviousCell(
        thisEmitter : CAEmitterLayer,
        oldCell     : CAEmitterCell) -> CAEmitterCell
    {
        let cell = CAEmitterCell()
        
        cell.birthRate              = oldCell.birthRate
        cell.lifetime               = oldCell.lifetime
        cell.lifetimeRange          = oldCell.lifetimeRange
        cell.color                  = oldCell.color
        cell.emissionLongitude      = oldCell.emissionLongitude
        cell.emissionLatitude       = oldCell.emissionLatitude
        cell.emissionRange          = oldCell.emissionRange
        cell.spin                   = oldCell.spin
        cell.spinRange              = oldCell.spinRange
        cell.scale                  = oldCell.scale
        cell.scaleRange             = oldCell.scaleRange
        cell.scaleSpeed             = oldCell.scaleSpeed
        cell.alphaSpeed             = oldCell.alphaSpeed
        cell.alphaRange             = oldCell.alphaRange
        cell.autoreverses           = oldCell.autoreverses
        cell.isEnabled              = oldCell.isEnabled
        cell.velocity               = oldCell.velocity
        cell.velocityRange          = oldCell.velocityRange
        cell.xAcceleration          = oldCell.xAcceleration
        cell.yAcceleration          = oldCell.yAcceleration
        cell.zAcceleration          = oldCell.zAcceleration
        cell.name                   = oldCell.name
        cell.contents               = oldCell.contents
        
        return cell
        
    } // ends makeCellBasedOnPreviousCell
    
    func makeCellBasedOnInitialState(
        thisEmitter : CAEmitterLayer,
        oldCell     : CAEmitterCell) -> CAEmitterCell
    {
        let cell = CAEmitterCell()
                
        cell.birthRate              = Float(prior_initialBirthRate)
        cell.lifetime               = Float(prior_initialCellLifetime)
        cell.lifetimeRange          = Float(prior_initialCellLifetimeRange)
        cell.color                  = prior_initialTint.cgColor
        cell.emissionLongitude      = oldCell.emissionLongitude
        cell.emissionLatitude       = oldCell.emissionLatitude
        cell.emissionRange          = oldCell.emissionRange
        cell.spin                   = prior_initialSpin
        cell.spinRange              = prior_initialSpinRange
        cell.scale                  = prior_initialScale
        cell.scaleRange             = prior_initialScaleRange
        cell.scaleSpeed             = prior_initialScaleSpeed
        cell.alphaSpeed             = Float(prior_initialAlphaSpeed)
        cell.alphaRange             = Float(prior_initialAlphaRange)
        cell.autoreverses           = oldCell.autoreverses
        cell.isEnabled              = oldCell.isEnabled
        cell.velocity               = prior_initialVelocity
        cell.velocityRange          = prior_initialVelocityRange
        cell.xAcceleration          = prior_initialAcceleration_X
        cell.yAcceleration          = prior_initialAcceleration_Y
        cell.zAcceleration          = oldCell.zAcceleration
        cell.name                   = oldCell.name
        cell.contents               = oldCell.contents
        
        return cell
        
    } // ends makeCellBasedOnInitialState
    
    func makeCellBasedOnFuseBurning(
        thisEmitter : CAEmitterLayer,
        oldCell     : CAEmitterCell) -> CAEmitterCell
    {
        let cell = CAEmitterCell()
        
        cell.birthRate              = Float(prior_fuseBurningBirthRate)
        cell.lifetime               = Float(prior_fuseBurningCellLifetime)
        cell.lifetimeRange          = Float(prior_fuseBurningCellLifetimeRange)
        cell.color                  = prior_fuseBurningTint.cgColor
        cell.emissionLongitude      = oldCell.emissionLongitude
        cell.emissionLatitude       = oldCell.emissionLatitude
        cell.emissionRange          = oldCell.emissionRange
        cell.spin                   = prior_fuseBurningSpin
        cell.spinRange              = prior_fuseBurningSpinRange
        cell.scale                  = prior_fuseBurningScale
        cell.scaleRange             = prior_fuseBurningScaleRange
        cell.scaleSpeed             = prior_fuseBurningScaleSpeed
        cell.alphaSpeed             = Float(prior_fuseBurningAlphaSpeed)
        cell.alphaRange             = Float(prior_fuseBurningAlphaRange)
        cell.autoreverses           = oldCell.autoreverses
        cell.isEnabled              = oldCell.isEnabled
        cell.velocity               = prior_fuseBurningVelocity
        cell.velocityRange          = prior_fuseBurningVelocityRange
        cell.xAcceleration          = prior_fuseBurningAcceleration_X
        cell.yAcceleration          = prior_fuseBurningAcceleration_Y
        cell.zAcceleration          = oldCell.zAcceleration
        cell.name                   = oldCell.name
        cell.contents               = oldCell.contents
        
        return cell
        
    } // ends makeCellBasedOnFuseBurning

    func makeCellBasedOnEndingState(
        thisEmitter : CAEmitterLayer,
        oldCell     : CAEmitterCell) -> CAEmitterCell
    {
        let cell = CAEmitterCell()
        
        cell.birthRate              = Float(prior_endingBirthRate)
        cell.lifetime               = Float(prior_endingCellLifetime)
        cell.lifetimeRange          = Float(prior_endingCellLifetimeRange)
        cell.color                  = prior_endingTint.cgColor
        cell.emissionLongitude      = oldCell.emissionLongitude
        cell.emissionLatitude       = oldCell.emissionLatitude
        cell.emissionRange          = oldCell.emissionRange
        cell.spin                   = prior_endingSpin
        cell.spinRange              = prior_endingSpinRange
        cell.scale                  = prior_endingScale
        cell.scaleRange             = prior_endingScaleRange
        cell.scaleSpeed             = prior_endingScaleSpeed
        cell.alphaSpeed             = Float(prior_endingAlphaSpeed)
        cell.alphaRange             = Float(prior_endingAlphaRange)
        cell.autoreverses           = oldCell.autoreverses
        cell.isEnabled              = oldCell.isEnabled
        cell.velocity               = prior_endingVelocity
        cell.velocityRange          = prior_endingVelocityRange
        cell.xAcceleration          = prior_endingAcceleration_X
        cell.yAcceleration          = prior_endingAcceleration_Y
        cell.zAcceleration          = oldCell.zAcceleration
        cell.name                   = oldCell.name
        cell.contents               = oldCell.contents
        
        return cell
        
    } // ends makeCellBasedOnEndingState
    
    
    public func placeEmittersOnSpecifiedCircleOrArc(
        thisCircleCenter        : CGPoint,
        thisCircleRadius        : CGFloat,
        thisCircleArcFactor     : CGFloat = 1.0,
        startIndex              : Int,
        endIndex                : Int,
        offsetAngleInDegrees    : CGFloat = 0,
        scaleFactor             : CGFloat = 1.0)
    {
        let angleBetweenEmitters : CGFloat = 360.0 / CGFloat(endIndex - startIndex + 1) * thisCircleArcFactor
        var currentSumOfAngles : CGFloat = 0
        
        if !indicesAreGood(startIndex: startIndex, endIndex: endIndex)
        {
            return
        }

        
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: thisCircleCenter.x + scaleFactor * thisCircleRadius * sin(currentSumOfAngles.degreesToRadians + offsetAngleInDegrees.degreesToRadians), y: thisCircleCenter.y + scaleFactor * thisCircleRadius * cos(currentSumOfAngles.degreesToRadians + offsetAngleInDegrees.degreesToRadians))
            
            currentSumOfAngles += angleBetweenEmitters
        }
        
    } // ends placeEmittersOnSpecifiedCircleOrArc
    
    public func placeEmittersOnSpecifiedLine(
        startingPoint   : CGPoint,
        endingPoint     : CGPoint,
        startIndex      : Int,
        endIndex        : Int)
    {
        if !indicesAreGood(startIndex: startIndex, endIndex: endIndex)
        {
            return
        }

        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        var lastPosition_X : CGFloat = startingPoint.x
        var lastPosition_Y : CGFloat = startingPoint.y
        
        let horizontalDistanceToCoverPerPlacement : CGFloat = (endingPoint.x - startingPoint.x) / CGFloat((endIndex - startIndex))
        
        let verticalDistanceToCoverPerPlacement : CGFloat = (endingPoint.y - startingPoint.y) / CGFloat((endIndex - startIndex))
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: lastPosition_X, y: lastPosition_Y)
            
            lastPosition_X += horizontalDistanceToCoverPerPlacement
            lastPosition_Y += verticalDistanceToCoverPerPlacement
        }
        
    } // ends placeEmittersOnSpecifiedLine
    
    public func placeEmittersOnSpecifiedRectangle(
        thisRectangle   : CGRect,
        startIndex      : Int,
        endIndex        : Int,
        scaleFactor     : CGFloat = 1.0,
        counterClockwiseDesired : Bool = false)
    {
        if !indicesAreGood(startIndex: startIndex, endIndex: endIndex)
        {
            return
        }

        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        // Rectange must be level with no offsetting angle.
        
        // This version places an equal number of emitters on all 4 sides if possible, but 3 sides may have one less emitter.
        
        // Figure out how many emitters per side
        let emittersPerSide : Int = ((endIndex - startIndex + 1) / 4)
        
        var emittersTopSide : Int = emittersPerSide
        var emittersRightSide : Int = emittersPerSide
        var emittersBottomSide : Int = emittersPerSide
        let emittersLeftSide : Int = emittersPerSide
        
        if (endIndex - startIndex + 1) % 4 != 0
        {
            emittersTopSide += 1
        }
        if (endIndex - startIndex + 1) % 4 == 2
        {
            emittersRightSide += 1
        }
        if (endIndex - startIndex + 1) % 4 == 3
        {
            emittersRightSide += 1
            emittersBottomSide += 1
        }
        
        var countOfEmittersPlacedSoFar : Int = 0
        var countOfHorizontalEmittersPlacedForThisSide : CGFloat = 0
        var countOfVerticalEmittersPlacedForThisSide : CGFloat = 0
        
        var horizontalDistanceToCoverPerPlacement : CGFloat = scaleFactor  * thisRectangle.width / 4
        var verticalDistanceToCoverPerPlacement : CGFloat = scaleFactor * thisRectangle.height / 4
        
        let origin_X_AdjustmentDueToScaleFactor = -(thisRectangle.width * scaleFactor - thisRectangle.width) / 2
        let origin_Y_AdjustmentDueToScaleFactor = -(thisRectangle.height * scaleFactor - thisRectangle.height) / 2
        
        var lastPosition_X : CGFloat = thisRectangle.origin.x + origin_X_AdjustmentDueToScaleFactor
        var lastPosition_Y : CGFloat = thisRectangle.origin.y + origin_Y_AdjustmentDueToScaleFactor
        
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            if counterClockwiseDesired
            {
                if countOfEmittersPlacedSoFar < emittersTopSide
                {
                    verticalDistanceToCoverPerPlacement = scaleFactor * thisRectangle.height /  CGFloat(emittersLeftSide)
                    
                    arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: lastPosition_X, y: lastPosition_Y)
                    
                    lastPosition_Y = lastPosition_Y + verticalDistanceToCoverPerPlacement
                    
                    countOfVerticalEmittersPlacedForThisSide += 1
                }
                else if countOfEmittersPlacedSoFar < emittersLeftSide + emittersBottomSide
                {
                    horizontalDistanceToCoverPerPlacement = thisRectangle.width /  CGFloat(emittersBottomSide) * scaleFactor
                    
                    arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: lastPosition_X, y: lastPosition_Y)
                    
                    lastPosition_X = lastPosition_X + horizontalDistanceToCoverPerPlacement
                    
                    countOfHorizontalEmittersPlacedForThisSide += 1
                    countOfVerticalEmittersPlacedForThisSide = 0
                }
                else if countOfEmittersPlacedSoFar < emittersLeftSide + emittersBottomSide + emittersRightSide
                {
                    verticalDistanceToCoverPerPlacement = thisRectangle.height /  CGFloat(emittersRightSide) * scaleFactor
                    
                    arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: lastPosition_X, y: lastPosition_Y)
                    
                    lastPosition_Y = lastPosition_Y - verticalDistanceToCoverPerPlacement
                    
                    countOfVerticalEmittersPlacedForThisSide += 1
                    countOfHorizontalEmittersPlacedForThisSide = 0
                }
                else
                {
                    horizontalDistanceToCoverPerPlacement = thisRectangle.width /  CGFloat(emittersTopSide) * scaleFactor
                    
                    arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: lastPosition_X, y: lastPosition_Y)
                    
                    lastPosition_X = lastPosition_X - horizontalDistanceToCoverPerPlacement
                    
                    countOfHorizontalEmittersPlacedForThisSide += 1
                    countOfVerticalEmittersPlacedForThisSide = 0
                }
                
                countOfEmittersPlacedSoFar += 1
                
            }
            else
            {
                if countOfEmittersPlacedSoFar < emittersTopSide
                {
                    horizontalDistanceToCoverPerPlacement = scaleFactor * thisRectangle.width /  CGFloat(emittersTopSide)
                    
                    arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: lastPosition_X, y: lastPosition_Y)
                    
                    lastPosition_X = lastPosition_X + horizontalDistanceToCoverPerPlacement
                    
                    
                    countOfHorizontalEmittersPlacedForThisSide += 1
                }
                else if countOfEmittersPlacedSoFar < emittersTopSide + emittersRightSide
                {
                    verticalDistanceToCoverPerPlacement = thisRectangle.height /  CGFloat(emittersRightSide) * scaleFactor
                    
                    arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: lastPosition_X, y: lastPosition_Y)
                    
                    lastPosition_Y = lastPosition_Y + verticalDistanceToCoverPerPlacement
                    
                    countOfVerticalEmittersPlacedForThisSide += 1
                    countOfHorizontalEmittersPlacedForThisSide = 0
                }
                else if countOfEmittersPlacedSoFar < emittersTopSide + emittersRightSide + emittersBottomSide
                {
                    horizontalDistanceToCoverPerPlacement = thisRectangle.width /  CGFloat(emittersBottomSide) * scaleFactor
                    
                    arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: lastPosition_X, y: lastPosition_Y)
                    
                    lastPosition_X = lastPosition_X - horizontalDistanceToCoverPerPlacement
                    
                    countOfHorizontalEmittersPlacedForThisSide += 1
                    countOfVerticalEmittersPlacedForThisSide = 0
                }
                else
                {
                    verticalDistanceToCoverPerPlacement = thisRectangle.height /  CGFloat(emittersLeftSide) * scaleFactor
                    
                    arrayOfEmitters[thisIndex].emitterPosition = CGPoint(x: lastPosition_X, y: lastPosition_Y)
                    
                    lastPosition_Y = lastPosition_Y - verticalDistanceToCoverPerPlacement
                    
                    countOfVerticalEmittersPlacedForThisSide += 1
                    countOfHorizontalEmittersPlacedForThisSide = 0
                }
                
                countOfEmittersPlacedSoFar += 1            }
            
        }
        
    } // ends placeEmittersOnSpecifiedRectangle
    
    public func desiredRangeOfVisibleEmitters(
        startIndex  : Int,
        endIndex    : Int)
    {
        if !indicesAreGood(startIndex: startIndex, endIndex: endIndex)
        {
            return
        }

        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        lastStartIndexForVisibleEmitters = startIndex
        lastEndIndexForVisibleEmitters = endIndex
        
        for (thisIndex, _) in arrayOfEmitters.enumerated()
        {
            if thisIndex < adjustedStartIndex || thisIndex > adjustedEndIndex
            {
                arrayOfEmitters[thisIndex].isHidden = true
            }
            else
            {
                arrayOfEmitters[thisIndex].isHidden = false
            }
        }
        
    } // ends desiredRangeOfVisibleEmitters
    
    func hideAllEmittersButPreserveRepeating()
    {
        hideAllEmitters()
        repeatingLastLitFuseEnabled = true
    }
    
    public func hideAllEmitters()
    {
        litFuseEffectEnabled = false
        repeatingLastLitFuseEnabled = false
        continuoslyBurnFuseEnable = false
        
        for thisIndex in 0...arrayOfEmitters.count - 1
        {
            let thisCell = arrayOfCells[thisIndex]
            let thisEmitter = arrayOfEmitters[thisIndex]
            
            thisCell.lifetime = 0
            thisCell.lifetimeRange = 0
            thisCell.scale = 0
            //thisEmitter.emitterPosition = CGPoint(x: -2020, y: -2020)
            
            thisEmitter.beginTime = CACurrentMediaTime()
            thisEmitter.isHidden = true
            
            let aCell = makeCellBasedOnPreviousCell(thisEmitter: thisEmitter, oldCell: thisCell)
            
            thisEmitter.emitterCells = [aCell]
            
            // Update the array
            arrayOfCells[thisIndex] = aCell
        }
        
    } // ends hideAllEmitters
    
    public func setCellImageFromTextStringForDesiredRangeOfEmitters(
        desiredImageAsText  : String,
        startIndex          : Int,
        endIndex            : Int)
    {
        if !indicesAreGood(startIndex: startIndex, endIndex: endIndex)
        {
            return
        }

        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        let textOrEmojiToUIImage = UILabel(frame: CGRect(x: 0, y: 0, width: emojiLengthPerSide, height: emojiLengthPerSide))
        
        textOrEmojiToUIImage.text = desiredImageAsText
        textOrEmojiToUIImage.sizeToFit()
        
        let tempImageToUseWhenChangingCellImages  =  UIImage.imageWithLabel(label: textOrEmojiToUIImage)
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            let thisCell = arrayOfCells[thisIndex]
            let thisEmitter = arrayOfEmitters[thisIndex]
            
            thisCell.contents = tempImageToUseWhenChangingCellImages.cgImage
            
            let aCell = makeCellBasedOnPreviousCell(thisEmitter: thisEmitter, oldCell: thisCell)
            
            thisEmitter.emitterCells = [aCell]

            // Update the array
            arrayOfCells[thisIndex] = aCell
        }
        
    } // ends setCellImageFromTextStringForDesiredRangeOfEmitters
    
    public func setEmitterCellDirectionOutwardsForRangeOfEmittersOnCircle(
        offsetAngle         : CGFloat = 0,
        startIndex          : Int,
        endIndex            : Int,
        twistAngleAddition  : CGFloat = 0)
    {
        if !indicesAreGood(startIndex: startIndex, endIndex: endIndex)
        {
            return
        }

        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        var currentTwistValue = twistAngleAddition
        
        var cummulativeAngle : CGFloat = -90 + offsetAngle
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            let thisCell = arrayOfCells[thisIndex]
            
            thisCell.emissionLongitude = -cummulativeAngle.degreesToRadians
            thisCell.emissionLatitude = 0
            thisCell.emissionRange = 0
            
            cummulativeAngle += currentTwistValue
            
            currentTwistValue += twistAngleAddition
        }
    } // ends setEmitterCellDirectionOutwardsForRangeOfEmittersOnCircle
    
    public func setEmitterCellDirectionToSpecifiedAngle(
        specifiedAngle  : CGFloat,
        startIndex      : Int,
        endIndex        : Int)
    {
        if !indicesAreGood(startIndex: startIndex, endIndex: endIndex)
        {
            return
        }

        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            let thisCell = arrayOfCells[thisIndex]
            
            thisCell.emissionLongitude = specifiedAngle.degreesToRadians
            thisCell.emissionLatitude = 0
            thisCell.emissionRange = 0
        }
    } // ends setEmitterCellDirectionToSpecifiedAngle
    
    public func cycleToNewCellImageFromTextStringForDesiredRangeOfEmittersAtDesiredRate(
        desiredArrayAsText  : [String],
        startIndex          : Int,
        endIndex            : Int,
        timeBetweenChanges  : CGFloat)
    {
        if !indicesAreGood(startIndex: startIndex, endIndex: endIndex)
        {
            return
        }

        arrayOfStringsForCycling = desiredArrayAsText
        cycleTime = timeBetweenChanges
        framesBetweenCycles = Int(cycleTime * 60.0)
        frameWhenWeChangeCellImages = totalFramesSinceStarting
        startIndexForCycling = startIndex
        endIndexForCycling = endIndex
        
        indexIntoArrayOfStrings = 0
        
        changeCellImagesEnabled = true
        
    } // ends cycleToNewCellImageFromTextStringForDesiredRangeOfEmittersAtDesiredRate
    
    public func alternateImageContentsWithGivenArrayOfEmojiOrTextForDesiredRangeOfEmitters(
        desiredArrayAsText  : [String],
        startIndex          : Int,
        endIndex            : Int)
    {
        if !indicesAreGood(startIndex: startIndex, endIndex: endIndex)
        {
            return
        }

        
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        var indexIntoArray = 0
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            let thisCell = arrayOfCells[thisIndex]
            let thisEmitter = arrayOfEmitters[thisIndex]
            
            let newStringToImage = desiredArrayAsText[indexIntoArray]
            let textOrEmojiToUIImage = UILabel(frame: CGRect(x: 0, y: 0, width: emojiLengthPerSide, height: emojiLengthPerSide))
            
            textOrEmojiToUIImage.text = newStringToImage
            textOrEmojiToUIImage.sizeToFit()
            
            let tempImageToUseWhenChangingCellImages  =  UIImage.imageWithLabel(label: textOrEmojiToUIImage)
            
            indexIntoArray += 1
            
            if indexIntoArray >= desiredArrayAsText.count
            {
                indexIntoArray = 0
            }
            
            thisCell.contents = tempImageToUseWhenChangingCellImages.cgImage
            
            let aCell = makeCellBasedOnPreviousCell(thisEmitter: thisEmitter, oldCell: thisCell)
            
            thisEmitter.emitterCells = [aCell]

            // Update the array
            arrayOfCells[thisIndex] = aCell
        }
        
    } // ends alternateImageContentsWithGivenArrayOfEmojiOrTextForDesiredRangeOfEmitters
    
    public func useSpecifiedImageAsContentsForDesiredRangeOfEmitters(
        specifiedImage  : UIImage,
        startIndex          : Int,
        endIndex            : Int)
    {
        if !indicesAreGood(startIndex: startIndex, endIndex: endIndex)
        {
            return
        }

        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
                
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            let thisCell = arrayOfCells[thisIndex]
            let thisEmitter = arrayOfEmitters[thisIndex]
            
            thisCell.contents = specifiedImage.cgImage
            
            let aCell = makeCellBasedOnPreviousCell(thisEmitter: thisEmitter, oldCell: thisCell)
            
            thisEmitter.emitterCells = [aCell]

            // Update the array
            arrayOfCells[thisIndex] = aCell
        }
        
    } // ends useSpecifiedImageAsContentsForDesiredRangeOfEmitters
    
    public func createLitFuseEffectForDesiredRangeOfEmitters(
        startIndex                  : Int,
        endIndex                    : Int,
        initialVelocity             : CGFloat = 0,
        initialVelocityRange        : CGFloat = 0,
        initialBirthRate            : CGFloat = 1,
        initialScale                : CGFloat = 0,
        initialScaleSpeed           : CGFloat = 0,
        initialScaleRange           : CGFloat = 0,
        initialSpin                 : CGFloat = 0,
        initialSpinRange            : CGFloat = 0,
        initialAcceleration_X       : CGFloat = 0,
        initialAcceleration_Y       : CGFloat = 0,
        initialAlphaSpeed           : CGFloat = 0,
        initialAlphaRange           : CGFloat = 0,
        initialTint                 : UIColor = .white,
        fuseBurningVelocity         : CGFloat = 300,
        fuseBurningVelocityRange    : CGFloat = 0,
        fuseBurningBirthRate        : CGFloat = 100,
        fuseBurningScale            : CGFloat = 1,
        fuseBurningScaleSpeed       : CGFloat = 0,
        fuseBurningScaleRange       : CGFloat = 0,
        fuseBurningSpin             : CGFloat = 0,
        fuseBurningSpinRange        : CGFloat = 0,
        fuseBurningAcceleration_X   : CGFloat = 0,
        fuseBurningAcceleration_Y   : CGFloat = 0,
        fuseBurningAlphaSpeed       : CGFloat = 0,
        fuseBurningAlphaRange       : CGFloat = 0,
        fuseBurningTint             : UIColor = .white,
        endingVelocity              : CGFloat = 0,
        endingVelocityRange         : CGFloat = 0,
        endingBirthRate             : CGFloat = 1,
        endingScale                 : CGFloat = 0,
        endingScaleSpeed            : CGFloat = 0,
        endingScaleRange            : CGFloat = 0,
        endingSpin                  : CGFloat = 0,
        endingSpinRange             : CGFloat = 0,
        endingAcceleration_X        : CGFloat = 0,
        endingAcceleration_Y        : CGFloat = 0,
        endingAlphaRange            : CGFloat = 0,
        endingAlphaSpeed            : CGFloat = 0,
        endingTint                  : UIColor = .white,
        stepsPerFrame               : Int = 1,
        initialCellLifetime         : CGFloat, // all lifetimes expressed in seconds
        initialCellLifetimeRange    : CGFloat = 0,
        fuseBurningCellLifetime     : CGFloat,
        fuseBurningCellLifetimeRange  : CGFloat = 0,
        endingCellLifetime          : CGFloat ,
        endingCellLifetimeRange     : CGFloat = 0,
        continuousFuseDesired       : Bool = false,
        repeatingFuseDesired        : Bool = false,
        timeBetweenRepeatsInSeconds : CGFloat = 0.5)
    {
        prior_startIndex                    = startIndex
        prior_endIndex                      = endIndex
        prior_initialVelocity               = initialVelocity
        prior_initialVelocityRange          = initialVelocityRange
        prior_initialBirthRate              = initialBirthRate
        prior_initialScale                  = initialScale
        prior_initialScaleSpeed             = initialScaleSpeed
        prior_initialScaleRange             = initialScaleRange
        prior_initialSpin                   = initialSpin
        prior_initialSpinRange              = initialSpinRange
        prior_initialAcceleration_X         = initialAcceleration_X
        prior_initialAcceleration_Y         = initialAcceleration_Y
        prior_initialAlphaSpeed             = initialAlphaSpeed
        prior_initialAlphaRange             = initialAlphaRange
        prior_initialTint                   = initialTint
        
        prior_fuseBurningVelocity           = fuseBurningVelocity
        prior_fuseBurningVelocityRange      = fuseBurningVelocityRange
        prior_fuseBurningAlphaRange         = fuseBurningAlphaRange
        prior_fuseBurningAlphaSpeed         = fuseBurningAlphaSpeed
        prior_fuseBurningBirthRate          = fuseBurningBirthRate
        prior_fuseBurningScale              = fuseBurningScale
        prior_fuseBurningScaleSpeed         = fuseBurningScaleSpeed
        prior_fuseBurningScaleRange         = fuseBurningScaleRange
        prior_fuseBurningSpin               = fuseBurningSpin
        prior_fuseBurningSpinRange          = fuseBurningSpinRange
        prior_fuseBurningAcceleration_X     = fuseBurningAcceleration_X
        prior_fuseBurningAcceleration_Y     = fuseBurningAcceleration_Y
        prior_fuseBurningTint               = fuseBurningTint
        
    
        prior_endingVelocity           = endingVelocity
        prior_endingVelocityRange      = endingVelocityRange
        prior_endingAlphaRange         = endingAlphaRange
        prior_endingAlphaSpeed         = endingAlphaSpeed
        prior_endingBirthRate          = endingBirthRate
        prior_endingScale              = endingScale
        prior_endingScaleSpeed         = endingScaleSpeed
        prior_endingScaleRange         = endingScaleRange
        prior_endingSpin               = endingSpin
        prior_endingSpinRange          = endingSpinRange
        prior_endingAcceleration_X     = endingAcceleration_X
        prior_endingAcceleration_Y     = endingAcceleration_Y
        prior_endingTint               = endingTint

        
        prior_stepsPerFrame                 = stepsPerFrame
        prior_initialCellLifetime           = initialCellLifetime
        prior_initialCellLifetimeRange      = initialCellLifetimeRange
        prior_fuseBurningCellLifetime       = fuseBurningCellLifetime
        prior_fuseBurningCellLifetimeRange  = fuseBurningCellLifetimeRange
        prior_endingCellLifetime            = endingCellLifetime
        prior_endingCellLifetimeRange       = endingCellLifetimeRange
        prior_continuousFuseDesired         = continuousFuseDesired
        prior_repeatingFuseDesired          = repeatingFuseDesired
        prior_timeBetweenRepeatsInSeconds    = timeBetweenRepeatsInSeconds
        
        if !indicesAreGood(startIndex: startIndex, endIndex: endIndex)
        {
            return
        }

        desiredRangeOfVisibleEmitters(startIndex: startIndex, endIndex: endIndex)
        
        litFuseEffectEnabled = true
        
        if continuousFuseDesired
        {
            continuousFuseEffectEnabled = true
            repeatingLastLitFuseEnabled = false
                        
            transitionToEndingVelocityIndex = 0
            transitionToEndingVelocityIndexHasBegun = false
            transitionToFuseBurningVelocityIndex = 0
        }
        else if repeatingFuseDesired
        {
            repeatingLastLitFuseEnabled = true
            continuousFuseEffectEnabled = false
            numberOfFramesBetweenRepeatedLitFuseDisplays = Int((timeBetweenRepeatsInSeconds * 60))
            singlePassInUseAndValid = true
            transitionToFuseBurningVelocityIndex = 0
            transitionToEndingVelocityIndex = 0
            transitionToEndingVelocityIndexHasBegun = false
        }
        else
        {
            continuousFuseEffectEnabled = false
            repeatingLastLitFuseEnabled = false
            singlePassInUseAndValid = true
            transitionToFuseBurningVelocityIndex = 0
            transitionToEndingVelocityIndex = 0
            transitionToEndingVelocityIndexHasBegun = false
        }
        
        // Save the values for later
        savedFuseStartIndex = startIndex - 1
        savedFuseEndIndex = endIndex - 1
        savedFuseStepsPerFrame = stepsPerFrame
        if savedFuseStepsPerFrame < 1
        {
            savedFuseStepsPerFrame = 1
        }
        if savedFuseStepsPerFrame > 80
        {
            savedFuseStepsPerFrame = 80
        }
        
        // set all emitters in the range to the initial velocity
        
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            let thisCell = arrayOfCells[thisIndex]
            let thisEmitter = arrayOfEmitters[thisIndex]
            
            thisCell.velocity = initialVelocity
            thisCell.velocityRange = initialVelocityRange
            thisCell.scale = initialScale
            thisCell.scaleSpeed = initialScaleSpeed
            thisCell.scaleRange = initialScaleRange
            thisCell.spin = initialSpin
            thisCell.spinRange = initialSpinRange
            thisCell.xAcceleration = initialAcceleration_X
            thisCell.yAcceleration = initialAcceleration_Y
            thisCell.alphaSpeed = Float(initialAlphaSpeed)
            thisCell.alphaRange = Float(initialAlphaRange)
            thisCell.lifetime = Float(initialCellLifetime)
            thisCell.lifetimeRange = Float(initialCellLifetimeRange)
            
            thisEmitter.beginTime = CACurrentMediaTime()
            
            let aCell = makeCellBasedOnInitialState(thisEmitter: thisEmitter, oldCell: thisCell)
            
            if scaleSyncedToLifetime
            {
                aCell.scaleSpeed = -1 * aCell.scale / CGFloat(aCell.lifetime)
            }
            if alphaSyncedToLifetime
            {
                aCell.alphaSpeed = -1 / aCell.lifetime
            }
            thisEmitter.emitterCells = [aCell]

            // Update the array
            arrayOfCells[thisIndex] = aCell
        }
        
    } // ends createLitFuseEffectForDesiredRangeOfEmitters
    
    public func syncScaleSpeedToShrinkOverLifetimeDesired(
        syncDesired : Bool)
    {
        scaleSyncedToLifetime = syncDesired
        
    } // ends syncScaleSpeedToShrinkOverLifetimeDesired
    
    public func syncAlphaSpeedToFadeOverLifetimeDesired(
        syncDesired : Bool)
    {
        alphaSyncedToLifetime = syncDesired
        
    } // ends syncAlphaSpeedToFadeOverLifetimeDesired
    
    public func setFuseEmitterPhases(
        onlyUseInitialPlacementLogic : Bool = false)
    {
        combingEmittersInProgress = onlyUseInitialPlacementLogic
        
    } // ends setFuseEmitterPhases
    
    public func stopCombingTheEmitters(
        startIndex          : Int,
        endIndex            : Int)
    {
        if !indicesAreGood(startIndex: startIndex, endIndex: endIndex)
        {
            return
        }
                
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            // randomize them
            let thisCell = arrayOfCells[thisIndex]
            let thisEmitter = arrayOfEmitters[thisIndex]
            
            let aCell = makeCellBasedOnFuseBurning(thisEmitter: thisEmitter, oldCell: thisCell)
            
            aCell.emissionRange = 2 * CGFloat.pi
            aCell.emissionLatitude = 2 * CGFloat.pi
            aCell.emissionLongitude = 2 * CGFloat.pi
                        
            thisEmitter.emitterCells = [aCell]
            
            // Update the array
            arrayOfCells[thisIndex] = aCell
        }
        
    } // ends stopCombingTheEmitters
    
    func indicesAreGood(startIndex : Int, endIndex : Int) -> Bool
    {
        if startIndex - 1 < 0
        {
            return false
        }
        if endIndex - 1 > arrayOfEmitters.count
        {
            return false
        }
        if endIndex - 1 < 0
        {
            return false
        }
        if startIndex - 1 > arrayOfEmitters.count
        {
            return false
        }
        if startIndex > endIndex
        {
            return false
        }
        return true
    } // ends indicesAreGood
    
    
    public func combCircularEmittersToPointInDesiredDirections(
        desiredOffsetAngleForCellFlow  : CGFloat = 0,
        desiredOffsetAngleForShape  : CGFloat = 0,
        coneWideningFactorNormallyZero     : CGFloat,
        combArcFactor       : CGFloat = 0,
        startIndex          : Int,
        endIndex            : Int)
    {
        if !indicesAreGood(startIndex: startIndex, endIndex: endIndex)
        {
            return
        }
                
        var currentAngleForEmissions : CGFloat = desiredOffsetAngleForCellFlow + 90 - desiredOffsetAngleForShape

        // How many?
        let countOfThem = endIndex - startIndex + 1
        
        let AngleIncrementPerCount : CGFloat = combArcFactor * CGFloat(360.0 / Double(countOfThem))
        
        var tempAngle : CGFloat
        
        tempAngle = currentAngleForEmissions.degreesToRadians
        
        let adjustedStartIndex = startIndex - 1
        let adjustedEndIndex = endIndex - 1
        
        for thisIndex in adjustedStartIndex...adjustedEndIndex
        {
            // comb them
            let thisCell = arrayOfCells[thisIndex]
            let thisEmitter = arrayOfEmitters[thisIndex]
            
            let aCell = makeCellBasedOnFuseBurning(thisEmitter: thisEmitter, oldCell: thisCell)
            
            aCell.emissionRange = 2 * CGFloat.pi * coneWideningFactorNormallyZero
            aCell.emissionLatitude = 0
            
            tempAngle = currentAngleForEmissions.degreesToRadians

            aCell.emissionLongitude = tempAngle

            thisEmitter.emitterCells = [aCell]
            
            // Update the array
            arrayOfCells[thisIndex] = aCell

            currentAngleForEmissions -= AngleIncrementPerCount
        }
        
    } // ends combCircularEmittersToPointInDesiredDirections
    

    
} // ends file
