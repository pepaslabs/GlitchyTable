//
//  GlitchyTableViewController.swift
//  GlitchyTable
//
//  Created by Jason Pepas on 9/2/15.
//  Copyright (c) 2015 Jason Pepas. All rights reserved.
//

import UIKit

class GlitchyModel
{
    func textForIndexPath(indexPath: NSIndexPath) -> String
    {
        NSThread.sleepForTimeInterval(1)
        return "\(indexPath.row)"
    }
}

class SerialOperationQueue: NSOperationQueue
{
    override init()
    {
        super.init()
        maxConcurrentOperationCount = 1
    }
}

class GlitchyTableCell: UITableViewCell
{
    let queue = SerialOperationQueue()

    override func prepareForReuse()
    {
        super.prepareForReuse()
        textLabel?.text = ""
    }
}

class GlitchyTableViewController: UITableViewController
{
    let model = GlitchyModel()
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 300
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell: GlitchyTableCell? = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier") as? GlitchyTableCell
        if cell == nil
        {
            cell = GlitchyTableCell(style:.Default, reuseIdentifier: "reuseIdentifier")
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if let cell = cell as? GlitchyTableCell
        {
            _configureCell(cell, atIndexPath: indexPath)
        }
    }
    
    private func _configureCell(cell: GlitchyTableCell, atIndexPath indexPath: NSIndexPath)
    {
        cell.queue.cancelAllOperations()
        
        let operation: NSBlockOperation = NSBlockOperation()
        operation.addExecutionBlock { [weak operation] () -> Void in
            
            let text = self.model.textForIndexPath(indexPath)
            
            dispatch_sync(dispatch_get_main_queue(), { [weak operation] () -> Void in
                
                if let operation = operation where operation.cancelled { return }
                
                cell.textLabel?.text = text
            })
        }
        
        cell.queue.addOperation(operation)
    }
}
