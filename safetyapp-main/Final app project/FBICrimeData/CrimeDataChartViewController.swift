import UIKit
import Charts

class CrimeDataChartViewController: UIViewController, ChartViewDelegate {
    
    var barChartView: BarChartView!
    
    var urlStr: String?
    var crimeDataArray = [CrimeData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Crime Data Chart"
        setupBarChartView()
        fetchData()
        self.hideKeyboardWhenTappedAround()
    }
    
    // For fetching data from the FBI API
    func fetchData() {
        guard let urlStr = urlStr, let url = URL(string: urlStr) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Data Task Error: \(error)")
                return
            }

            guard let data = data else {
                print("Data Task Error: No data to decode")
                return
            }
            
            // Decoding part is similar to the one in CrimeDataViewController
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode([CrimeData].self, from: data)
                self.crimeDataArray = decodedData
                
                // DispatchQueue is used to update the UI on the main thread for chart set up
                DispatchQueue.main.async {
                    self.setupChartData()
                }
            } catch {
                print("Decoding Error: \(error)")
            }
        }.resume()
    }
    
    // For setting up the swift chart view
    
    func setupChartData() {
        var dataEntries: [BarChartDataEntry] = []
        
        // For each year, add a data entry for the violent crime
        for i in 0..<crimeDataArray.count {
            if let violentCrime = Double(crimeDataArray[i].violent_crime) {
                let dataEntry = BarChartDataEntry(x: Double(crimeDataArray[i].year), y: violentCrime)
                dataEntries.append(dataEntry)
            }
        }
        
        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Violent Crimes")
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData
        
        barChartView.xAxis.labelPosition = .bottom
        chartDataSet.colors = ChartColorTemplates.colorful()
        
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:crimeDataArray.map { String($0.year) }) // Casting from int to String for x-axis labels
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.labelRotationAngle = -90
        
        // Zoom and scroll settings
        barChartView.scaleYEnabled = false // disable vertical zooming
        barChartView.scaleXEnabled = true // enable horizontal zooming
        barChartView.pinchZoomEnabled = false // disable pinch zooming
        barChartView.doubleTapToZoomEnabled = false // disable zooming on double tap
        barChartView.dragEnabled = true // enable scrolling
        
        barChartView.zoom(scaleX: CGFloat(crimeDataArray.count) / 10.0, scaleY: 1, x: 0, y: 0) // initial zoom level
    }


    func setupBarChartView() {
        barChartView = BarChartView()
        view.addSubview(barChartView)
        
        // Constraints
        barChartView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            barChartView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            barChartView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            barChartView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            barChartView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    // Prompt alert for error notifying users
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
