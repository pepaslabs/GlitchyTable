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

class GlitchyTableCell: UITableViewCell
{
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
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            let text = self.model.textForIndexPath(indexPath)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                cell.textLabel?.text = text
                
            })
        })
    }
}
