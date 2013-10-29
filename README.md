LoopnetIndoorNav
================

LoopnetIndoorNav

- DemoViewController is initial controller.  Hit Start on Navbar to begin.  
Beacons will be gathered into an array and connected. Upon connecting we'll attempt to read RSSI.  
Once it is read, that data is sent to GridView to draw.

- GridView is a custom view which draws out beacons grid and user location.

TODO:
- Better handling of downed beacons.
- Clean up some code.
- Try out another form of triangulation by doing quadrant splicing to see if that improves accuracy.
