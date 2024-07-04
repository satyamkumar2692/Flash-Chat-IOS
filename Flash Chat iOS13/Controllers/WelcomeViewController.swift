
import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        titleLabel.text=""
//       let titleText="⚡️FlashChat"
//        var counter=0.0;
//        for letter in titleText{
//            Timer.scheduledTimer(withTimeInterval: 0.1*counter, repeats: false) { timer in
//                self.titleLabel.text?.append(letter)
//            }
//            counter+=1
//        }
        titleLabel.text=K.title
       
    }
    

}
