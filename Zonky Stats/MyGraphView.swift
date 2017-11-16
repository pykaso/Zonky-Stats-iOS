//
//  MyGraphView.swift
//  Zonky Stats
//
//  Created by lgergel on 15/11/2017.
//  Copyright © 2017 Lukas Gergel. All rights reserved.
//

import Charts

class MyGraphView: LineChartView {
    
    
    var viewModel: ViewModel = ViewModel() {
        didSet {
            let line1 = LineChartDataSet(values: viewModel.loansData, label: "Pujcky")
            line1.colors = [NSUIColor.red]
            let line2 = LineChartDataSet(values: viewModel.coveredData, label: "Pokryte")
            line2.colors = [NSUIColor.blue]
            
            let f = BarChartFormatter()
            f.setLabels(labels: viewModel.labels)
            self.xAxis.valueFormatter = f
            
            let data = LineChartData()
            data.addDataSet(line1)
            data.addDataSet(line2)
            self.data = data;
        }
    }
}

extension MyGraphView {
    struct ViewModel {
        var loansData: [ChartDataEntry]
        var coveredData: [ChartDataEntry]
        var labels: [String]
    }
}

extension MyGraphView.ViewModel {
    init(stats: DataResponse) {
        loansData = stats.chartDataLoans
        coveredData = stats.chartDataCovered
        labels = stats.chartDataLabels
    }
    
    init() {
        loansData = [ChartDataEntry]()
        coveredData = [ChartDataEntry]()
        labels = [String]()
    }
}

extension DataResponse {
    
    var chartDataLoans: [ChartDataEntry] {
        var data = [ChartDataEntry]()
        if let loans = self.loans {
            for i in 0..<loans.count{
                let value = ChartDataEntry(x: Double(i), y: Double(loans[i].loans))
                data.append(value)
            }
        }
        return data;
    }
    
    var chartDataCovered: [ChartDataEntry] {
        var data = [ChartDataEntry]()
        if let loans = self.loans {
            for i in 0..<loans.count{
                let value = ChartDataEntry(x: Double(i), y: Double(loans[i].covered))
                data.append(value)
            }
        }
        return data;
    }
    
    var chartDataLabels: [String] {
        var data = [String]()
        if let loans = self.loans {
            for i in 0..<loans.count{
                data.append(String(loans[i].interval.prefix(7)))
            }
        }
        return data;
    }
}

@objc(BarChartFormatter)
public class BarChartFormatter: NSObject, IAxisValueFormatter{
    
    var labels: [String]!
    
    public func setLabels(labels: [String]) {
        self.labels = labels
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return labels[Int(value)]
    }
}
