//
//  TimelineView.swift
//  iTunes Timeline
//
//  Created by Yannick Cholette on 2014-10-13.
//  Copyright (c) 2014 El Choletto. All rights reserved.
//

import Cocoa

class TimelineView : NSView
{
    var _parser: XmlDbParser
    
    init( frame: CGRect, parser: XmlDbParser )
    {
        _parser = parser
        
        super.init( frame: frame )
        
        
        
        let line = NSView()
        line.wantsLayer = true
        line.layer?.backgroundColor = NSColor.lightGrayColor().CGColor
        addSubview( line )
        
        var curY = 16 as CGFloat
        let circleDiameter = 14 as CGFloat
        
        var dates = _parser._songsForDate.keys.array
        dates.sort{ $1 < $0 }
        
        for date in dates
        {
            let item = _parser._songsForDate[date]
            
            let songStr = makeSongString( item! )
            let detailLabel = NSTextField( frame: CGRect( x:      circleDiameter + 12,
                                                          y:      curY,
                                                          width:  10,
                                                          height: 10 ) )
            detailLabel.font = NSFont( name: "Helvetica", size: 12 )
            detailLabel.editable = false
            detailLabel.textColor = NSColor( red: 111/255, green: 111/255, blue: 111/255, alpha: 1 )
            detailLabel.stringValue = songStr
            detailLabel.bordered = false
            detailLabel.sizeToFit()
            addSubview( detailLabel )
            
            curY += detailLabel.frame.height
            
            let headerLabel = NSTextField( frame: CGRect( x:      circleDiameter + 12,
                                                        y:      curY,
                                                        width:  10,
                                                        height: 10 ) )
            headerLabel.drawsBackground = false;
            headerLabel.editable = false;
            headerLabel.font = NSFont( name: "Helvetica", size: 20 )
            headerLabel.textColor = NSColor(red: 0/255, green: 183/255, blue: 158/255, alpha: 1)
            headerLabel.stringValue = date
            headerLabel.bordered = false
            headerLabel.sizeToFit()
            addSubview( headerLabel )
            
            let circle = NSView( frame: NSRect( x:      10,
                                                y:      curY + 5,
                                                width:  circleDiameter,
                                                height: circleDiameter ) )
            circle.wantsLayer = true
            circle.layer?.backgroundColor = NSColor.whiteColor().CGColor
            circle.layer?.borderWidth = 2
            circle.layer?.borderColor = NSColor.lightGrayColor().CGColor
            circle.layer?.cornerRadius = circleDiameter / 2
            addSubview( circle )
            
            
            curY += max( headerLabel.frame.height + 10, circle.frame.height )
        }
        
        self.frame = CGRect( x: 0, y: 0, width: frame.width, height: curY  )
        line.frame = CGRect( x: 16, y: 0, width: 2, height: curY )
    }
    
    func makeSongString( songs: [(id: UInt64, time: String)] ) -> String
    {
        var str = ""
        
        var sortedSongs = songs
        sortedSongs.sort{ $0.time < $1.time }
        
        for song in sortedSongs
        {
            let songItem = _parser._songs[song.id]
            
            str += "(" + song.time + ") " + songItem!._artist + " - " + songItem!._name + "\n"
        }
        
        return str
    }
    
    required init( coder: NSCoder )
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var wantsDefaultClipping : Bool
    {
        return false
    }
    
    override func drawRect( dirtyRect: NSRect )
    {
        super.drawRect( dirtyRect )
    }
}
