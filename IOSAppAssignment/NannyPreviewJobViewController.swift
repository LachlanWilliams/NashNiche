//
//  NannyPreviewJobViewController.swift
//  IOSAppAssignment
//
//  Created by Lachlan J Williams on 12/4/2024.
//

import UIKit

class NannyPreviewJobViewController: UIViewController {

    var job: Job?
    
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let job = job {
            titleLabel.text = job.title
            dateTimeLabel.text = job.dateTime
            locationLabel.text = job.location
            durationLabel.text = job.duration
            descLabel.text = job.desc
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
