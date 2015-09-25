# GlitchyTable
An exploration of improving `UITableView` scrolling performance by using an asynchronous `UITableViewCell` population technique.

## Abstract

In general, the key to keeping the iPhone UI responsive is to never block the main thread for an extended period of time.  In the case of `UITableViewController`, this boils down to keeping `tableView(_:cellForRowAtIndexPath:)` as responsive as possible.

However, sometimes it is simply not possible to marshall all of the data needed to fully populate a complex `UITableViewCell` without causing a drop in framerate.  In these cases, it is necessary to switch to an asynchronous strategy for populating `UITableViewCells`.  In this article we explore a trivial example of using this technique.

## Demonstrating the problem

[Here](https://github.com/pepaslabs/GlitchyTable/blob/master/1%20The%20Problem/GlitchyTable/GlitchyTable/GlitchyTableViewController.swift) is a simple Xcode project which demonstrates the problem of a slow model leading to laggy scrolling performance.

We start with a model which blocks for 100ms.  This simulates the lag induced excessive disk access, complex `CoreData` interactions, etc:

```Swift
class GlitchyModel
{
    func textForIndexPath(indexPath: NSIndexPath) -> String
    {
        NSThread.sleepForTimeInterval(0.1)
        return "\(indexPath.row)"
    }
}
```

We then hook that model up with some typical boilerplate code in our `GlitchyTableViewController` implementation:

```Swift
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
```

For context, the full source of the implementation is available [here](https://github.com/pepaslabs/GlitchyTable/blob/master/1%20The%20Problem/GlitchyTable/GlitchyTable/GlitchyTableViewController.swift).

The result is a `UITableView` with terrible scrolling performance, as shown in this [video](http://gfycat.com/ImpassionedBoilingCoyote):

[![gif 1](http://zippy.gfycat.com/ImpassionedBoilingCoyote.gif)](http://gfycat.com/ImpassionedBoilingCoyote)


(draft: including gifs inline)


[![gif 1](http://zippy.gfycat.com/OnlyAmusingCardinal.gif)](http://gfycat.com/OnlyAmusingCardinal)

[![gif 1](http://zippy.gfycat.com/PleasedConfusedBluejay.gif)](http://gfycat.com/PleasedConfusedBluejay)

[![gif 1](http://zippy.gfycat.com/LameComfortableGordonsetter.gif)](http://gfycat.com/LameComfortableGordonsetter)

[![gif 1](http://zippy.gfycat.com/HeavyEmbellishedIceblueredtopzebra.gif)](http://gfycat.com/HeavyEmbellishedIceblueredtopzebra)
