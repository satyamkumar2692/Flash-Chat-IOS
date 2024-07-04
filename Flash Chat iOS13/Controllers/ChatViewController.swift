import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    let db = Firestore.firestore()
    var messages:[Message]=[]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title="⚡️FlashChat"
        navigationItem.hidesBackButton=true
        tableView.dataSource=self
        tableView.delegate=self
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessages()
    }
    
    func loadMessages(){
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener{ (querySnapshot, error)in
            self.messages=[]
            if let e=error {
                print("Error getting Messages:\(e)")
            }
            else{
                if let querySnapshotDocuments = querySnapshot?.documents{
                    for doc in querySnapshotDocuments{
                        let newMsg=Message(sender:doc.data()[K.FStore.senderField] as! String, body: doc.data()[K.FStore.bodyField] as! String)
                        self.messages.append(newMsg)
                        DispatchQueue.main.async {
                             self.tableView.reloadData()
                            let indexPath=IndexPath(row: self.messages.count-1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        }
    }
     
    @IBAction func LogoutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
                                        let dialogMessage = UIAlertController(title: "Attention", message:signOutError.localizedDescription, preferredStyle: .alert)
                                        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                                            print("Ok button tapped") })
                                        dialogMessage.addAction(ok)
                                    self.present(dialogMessage, animated: true, completion: nil)
        }}
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody=messageTextfield.text,let sender=Auth.auth().currentUser?.email{
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.bodyField:messageBody,
                    K.FStore.senderField:sender,
                K.FStore.dateField:Date().timeIntervalSince1970])
            { error in
                if let e=error{
                    print("There was an issue saving data to firestore\(e)")}
                else {print("Successfully saved data")}
                DispatchQueue.main.async {
                    self.messageTextfield.text=""
                }}}}
    
}


extension ChatViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text=messages[indexPath.row].body
        if(messages[indexPath.row].sender==Auth.auth().currentUser?.email){
            cell.leftImgaeView.isHidden=true
            cell.rightImageView.isHidden=false
            cell.messageBubble.backgroundColor=UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor=UIColor(named: K.BrandColors.purple)
        }
        else{
            cell.rightImageView.isHidden=true
            cell.leftImgaeView.isHidden=false
            cell.messageBubble.backgroundColor=UIColor(named: K.BrandColors.purple)
            cell.label.textColor=UIColor(named: K.BrandColors.lightPurple)
        }
        return cell
    }
}

extension ChatViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dialogMessage = UIAlertController(title: "Sender", message: messages[indexPath.row].sender, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("Ok button tapped")
         })
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

}
