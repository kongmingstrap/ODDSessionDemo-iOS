//
//  MasterViewController.swift
//  ODDSessionDemo
//

import UIKit
import CoreData

enum TableIndex: Int {
    case API1, API2
    
    static let tableTitles = [API1: "api.tiqav.com", API2: "webapi.yanoshin.jp"]
    
    func tableTitle() -> String {
        if let tableTitle = TableIndex.tableTitles[self] {
            return tableTitle
        } else {
            return "no title"
        }
    }
}

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = controllers[controllers.count - 1].topViewController as? DetailViewController
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // do nothing
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tableIndex = TableIndex(rawValue: indexPath.row)!
        switch tableIndex {
        case .API1:
            let session = ODDSession()
            session.requestURL = NSURL(string: "http://api.tiqav.com/search/random.json")
            let task: ODDSessionTask = session.getTaskWithAdditionalHeaders(nil, parameters: nil, completionHandler: { (data, response, error) -> Void in
                let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
                println(json)
            })
            task.resume()
        case .API2:
            let session = ODDSession()
            session.requestURL = NSURL(string: "http://webapi.yanoshin.jp/webapi/tdnet/list/today.json")
            session.queue = NSOperationQueue()
            let task: ODDSessionTask = session.getTaskWithAdditionalHeaders(nil, parameters: ["limit": 1], completionHandler: { (data, response, error) -> Void in
                let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
                println(json)
            })
            task.resume()
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        if let tableIndex = TableIndex(rawValue: indexPath.row) {
            cell.textLabel?.text = tableIndex.tableTitle()
        }
        return cell
    }

}

