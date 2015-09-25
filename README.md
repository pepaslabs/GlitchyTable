# GlitchyTable
An exploration of improving UITableView scrolling performance by using asynchronous cell population

## Abstract

In general, the key to keeping the iPhone UI responsive is to never block the main thread for an extended period of time.  In the case of `UITableViewController`, this boils down to keeping `tableView(_:cellForRowAtIndexPath:)` as responsive as possible.

However, sometimes it is simply not possible to marshall all of the data needed to fully populate a complex `UITableViewCell` without causing a drop in framerate.  In these cases, it is necessary to switch to an asynchronous strategy for populating `UITableViewCell`s.  In this article we explore a trivial example of using this technique.

## Demonstrating the problem

(draft: testing in-line code sample syntax highlighting)

```Swift
class GlitchyTableViewController: UITableViewController
{
    let model = GlitchyModel()
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 100
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
        cell.textLabel?.text = model.textForIndexPath(indexPath)
    }
}
```


(draft: including gifs inline)

[![gif 1](http://zippy.gfycat.com/ImpassionedBoilingCoyote.gif)](http://gfycat.com/ImpassionedBoilingCoyote)

[![gif 1](http://zippy.gfycat.com/OnlyAmusingCardinal.gif)](http://gfycat.com/OnlyAmusingCardinal)

[![gif 1](http://zippy.gfycat.com/PleasedConfusedBluejay.gif)](http://gfycat.com/PleasedConfusedBluejay)

[![gif 1](http://zippy.gfycat.com/LameComfortableGordonsetter.gif)](http://gfycat.com/LameComfortableGordonsetter)

[![gif 1](http://zippy.gfycat.com/HeavyEmbellishedIceblueredtopzebra.gif)](http://gfycat.com/HeavyEmbellishedIceblueredtopzebra)
