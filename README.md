# Populating `UITableViewCells` Asynchronously to Maintain Scolling Performance

## Abstract

In general, the key to keeping the iPhone UI responsive is to avoid block the main thread for an extended period of time.  In the case of `UITableViewController`, this boils down to keeping `tableView(_:cellForRowAtIndexPath:)` as responsive as possible.

However, sometimes it is simply not possible to marshall all of the data needed to fully populate a complex `UITableViewCell` without causing a drop in framerate.  In these cases, it is necessary to switch to an asynchronous strategy for populating `UITableViewCells`.  In this article we explore a trivial example of using this technique.

## Demonstrating the Problem

Our first task is to create a simple Xcode project which demonstrates the problem of a slow model leading to laggy scrolling performance.

We start with a model which blocks for 100ms.  This simulates the lag induced by excessive disk access, complex `CoreData` interactions, etc:

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

(For additional context, see the [Xcode project](https://github.com/pepaslabs/GlitchyTable/tree/master/1%20The%20Problem/GlitchyTable) and [source code](https://github.com/pepaslabs/GlitchyTable/blob/master/1%20The%20Problem/GlitchyTable/GlitchyTable/GlitchyTableViewController.swift) of this solution).

The result is a `UITableView` with terrible scrolling performance, as shown in this [video](http://gfycat.com/ImpassionedBoilingCoyote):

[![gif 1](http://zippy.gfycat.com/ImpassionedBoilingCoyote.gif)](http://gfycat.com/ImpassionedBoilingCoyote)

(Note: It is difficult to demonstrate the problem in the above in-line gif due to its low framerate.  Please click the gif or follow the [video link](http://gfycat.com/ImpassionedBoilingCoyote) to see an HTML5 video, full framerate demonstration of the problem).

## Populating `UITableViewCell` Asynchronously

Our first attempt at solving this problem is to rewrite `_configureCell(_,atIndexPath)` to grab the data from the model on a background thread, then jump back to the main thread to populate the `UITableViewCell`:

```Swift
private func _configureCell(cell: GlitchyTableCell, atIndexPath indexPath: NSIndexPath)
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
        
        let text = self.model.textForIndexPath(indexPath)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            cell.textLabel?.text = text
            
        })
    })
}
```

(See also the [Xcode project](https://github.com/pepaslabs/GlitchyTable/tree/master/2%20Buggy%20Solution/GlitchyTable) and [source code](https://github.com/pepaslabs/GlitchyTable/blob/master/2%20Buggy%20Solution/GlitchyTable/GlitchyTable/GlitchyTableViewController.swift) of this solution).

This change is enough to solve the laggy scrolling performance (as seen in this [video](http://gfycat.com/OnlyAmusingCardinal)):

[![gif 1](http://zippy.gfycat.com/OnlyAmusingCardinal.gif)](http://gfycat.com/OnlyAmusingCardinal)

However, we have introduced a bug.  If a `UITableViewCell` scrolls all the way off-screen and gets re-used before the first asynchronous `_configureCell` call has completed, a second `_configureCell` call will be queued up in the distpatch queue.

In the case where you have both an extremely laggy model and a user whom is scrolling very aggressively, this can result in many such calls getting queued up.  The result is that when the `UITableView` stops scrolling, the user will see the content of the cells cycle through all of the queued up populate operations.

To demonstrate this, we increase the simulated lag in `GlitchyModel` to 1000ms and scroll very quickly, as seen in this [video](http://gfycat.com/PleasedConfusedBluejay):

[![gif 1](http://zippy.gfycat.com/PleasedConfusedBluejay.gif)](http://gfycat.com/PleasedConfusedBluejay)

## Fixing the Queued `UITableViewCell` Population Bug

To solve this problem, we need to ensure that multiple populate operations aren't allowed to queue up.  We can accomplish this by using a serial queue to manage our `UITableViewCell` populate operations, and ensuring that any outstanding operations are cancelled before we queue up the next operation.

We create a trivial serial queue:

```Swift
class SerialOperationQueue: NSOperationQueue
{
    override init()
    {
        super.init()
        maxConcurrentOperationCount = 1
    }
}
```

We then add such a queue to each of our `UITableViewCell` instances:

```Swift
class GlitchyTableCell: UITableViewCell
{
    let queue = SerialOperationQueue()
}
```

Finally, we update our `_configureCell` implementation to use the operation queue:

```Swift
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
```

(See also the [Xcode project](https://github.com/pepaslabs/GlitchyTable/tree/master/3%20Correct%20Solution/GlitchyTable) and [source code](https://github.com/pepaslabs/GlitchyTable/blob/master/3%20Correct%20Solution/GlitchyTable/GlitchyTable/GlitchyTableViewController.swift) of this solution).

Now, we revisit our extremely problematic model (which simulates 1000ms lag) and verify that it behaves correctly (as seen in this [video](http://gfycat.com/LameComfortableGordonsetter)):

[![gif 1](http://zippy.gfycat.com/LameComfortableGordonsetter.gif)](http://gfycat.com/LameComfortableGordonsetter)

Finally, we dial back the simulated lag to 100ms to get a sense of what this would look like in a real-world scenario (as seen in this [video](http://gfycat.com/HeavyEmbellishedIceblueredtopzebra)):

[![gif 1](http://zippy.gfycat.com/HeavyEmbellishedIceblueredtopzebra.gif)](http://gfycat.com/HeavyEmbellishedIceblueredtopzebra)

## Conclusion

Populating `UITableViewCells` asynchronously ensures that your `UITableView` scrolling performance is decoupled from your data model performance.
