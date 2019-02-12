//
//  GraphView.swift
//  ISD196LunchroomApp
//
//  Created by Sam on 2/1/19.
//  Copyright © 2019 district196.org. All rights reserved.
//

import UIKit

@IBDesignable class GraphView: UIView {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var countStackView: UIStackView!

    @IBInspectable var startColor: UIColor = .white
    @IBInspectable var endColor: UIColor = .white
    @IBInspectable var lineColor: UIColor = UIColor(red:0.62, green:0.82, blue:0.32, alpha:1.0)
    @IBInspectable var textColor: UIColor = UIColor(red:0.33, green:0.37, blue:0.12, alpha:1.0)
    
    var graphPoints = [Int]()
    var days = [String]()
    var months = [String]()
    
    private struct Constants {
        
        static let cornerRadiusSize = CGSize(width: 16.0, height: 16.0)
        static let margin: CGFloat = 50
        static let topBorder: CGFloat = 20
        static let bottomBorder: CGFloat = 50
        static let colorAlpha: CGFloat = 0.3
        static let circleDiameter: CGFloat = 5.0
    }
    
    /*
    override init(frame: CGRect) {
        super.init(frame: frame)
        let bundle = Bundle(for: GraphView.self)
        bundle.loadNibNamed(String(describing: GraphView.self), owner: self, options: nil)
    }
     */
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        /*
        let bundle = Bundle(for: GraphView.self)
        bundle.loadNibNamed(String(describing: GraphView.self), owner: self, options: nil)
        */
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: Constants.cornerRadiusSize)
        path.addClip()
        
        let context = UIGraphicsGetCurrentContext()!
        let backgroundColors = [endColor.cgColor, endColor.cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: backgroundColors as CFArray, locations: colorLocations)
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: [])
        
        //calculate the x coordinates
        
        let margin = Constants.margin
        let graphWidth = width - margin * 2 - 4
        let columnXPoint = { (column: Int) -> CGFloat in
            //calculate spacing between points
            let spacing = graphWidth / CGFloat(self.graphPoints.count - 1)
            return CGFloat(column) * spacing + margin + 2
        }
        
        let maxValue = (100 * Int(round(Double(graphPoints.max()!) + 50.0) / 100))
        let minValue = (100 * Int(round(Double(graphPoints.min()!) - 50.0) / 100))
        let topBorder = Constants.topBorder
        let bottomBorder = Constants.bottomBorder
        let graphHeight = height - topBorder - bottomBorder
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
            let y = CGFloat(graphPoint - minValue) / CGFloat(maxValue - minValue) * graphHeight
            return (topBorder + graphHeight - y)
        }
        
        // Draw the horizontal graph lines on top of everything
        let linePath = UIBezierPath()
        
        // Top line
        linePath.move(to: CGPoint(x: margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: topBorder))
        
        let divisions = ((maxValue - minValue) / 100)
        for x in 1...(divisions - 1) {
            linePath.move(to: CGPoint(x: margin, y: graphHeight / CGFloat(divisions) * CGFloat(x) + topBorder))
            linePath.addLine(to: CGPoint(x: width - margin, y: graphHeight / CGFloat(divisions) * CGFloat(x) + topBorder))
        }
        
        // Bottom
        linePath.move(to: CGPoint(x: margin, y: height - bottomBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: height - bottomBorder))
        
        let color = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1.0)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
        
        // draw the line graph
        
        lineColor.setFill()
        lineColor.setStroke()
        
        // Set up the points line
        let graphPath = UIBezierPath()
        
        // go to the start of the line
        graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(graphPoints[0])))
        
        // add points for each item in the array
        for i in 1..<graphPoints.count {
            let nextPoint = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
            graphPath.addLine(to: nextPoint)
        }
        
        // create the clipping path for the graph gradient
        
        /*
        context.saveGState()
        
        let clippingPath = graphPath.copy() as! UIBezierPath
        
        clippingPath.addLine(to: CGPoint(x: columnXPoint(graphPoints.count - 1), y: height))
        clippingPath.addLine(to: CGPoint(x: columnXPoint(0), y: height))
        clippingPath.close()
        
        clippingPath.addClip()
        
        let highestYPoint = columnYPoint(maxValue)
        let graphStartPoint = CGPoint(x: margin, y: highestYPoint)
        let graphEndPoint = CGPoint(x: margin, y: bounds.height)
        
        let lineColors = [startColor.cgColor, endColor.cgColor]
        
        let lineGradient = CGGradient(colorsSpace: colorSpace, colors: lineColors as CFArray, locations: colorLocations)
        
        context.drawLinearGradient(lineGradient!, start: graphStartPoint, end: graphEndPoint, options: [])
        
        context.restoreGState()
        */
        
        graphPath.lineWidth = 2.0
        graphPath.stroke()
        
        // Draw the circles on top of the graph stroke
        for i in 0..<graphPoints.count {
            var point = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
            point.x -= Constants.circleDiameter / 2
            point.y -= Constants.circleDiameter / 2
            
            let circle = UIBezierPath(ovalIn: CGRect(origin: point, size: CGSize(width: Constants.circleDiameter, height: Constants.circleDiameter)))
            circle.fill()
        }
        
        setupGraphDisplay()
    }
    
    func setupGraphDisplay () {
        
        //setNeedsDisplay()
        let maxValue = (100 * Int(round(Double(graphPoints.max()!) + 50.0) / 100))
        let minValue = (100 * Int(round(Double(graphPoints.min()!) - 50.0) / 100))
        
        for i in 0...((maxValue - minValue) / 100) {
            
            let label = UILabel()
            label.text = "\(maxValue - (i * 100))"
            label.textColor = lineColor
            countStackView.addArrangedSubview(label)
        }
        
        for i in 0..<graphPoints.count {
           
            let label = UILabel()
            label.text = "\(months[i])/\(days[i])"
            label.textColor = lineColor
            stackView.addArrangedSubview(label)
            
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}