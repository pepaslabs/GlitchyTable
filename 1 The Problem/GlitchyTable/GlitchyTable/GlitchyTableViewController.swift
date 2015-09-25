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
        NSThread.sleepForTimeInterval(0.1)
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
        return 100
    }

    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
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
        cell.textLabel?.text = model.textForIndexPath(indexPath)
    }
}
