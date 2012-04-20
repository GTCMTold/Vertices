//
//  TouchTracker.m
//  Vertices
//
//  Created by James O'Neill on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TouchTracker.h"


@implementation TouchTracker

- (id)init {
    self = [super init];
    if (self) {
        for(int i = 0; i<MAX_TOUCHES; i+=1) 
			g_touchTracker[i].m_touchPointer = nil;
		
    }
    return self;
}


- (int) GetFingerTrackIDByTouch:(id)touch
{
	for (int i=0; i < MAX_TOUCHES; i+=1)
	{
		if (g_touchTracker[i].m_touchPointer == touch)
		{
			return i;
		}
	}
	
    //LogMsg("Can't locate fingerID by touch %d", touch);
    return -1;
}

- (int) AddNewTouch:(id)touch
{
	for (int i=0; i < MAX_TOUCHES; i++)
	{
		if (!g_touchTracker[i].m_touchPointer)
		{
			//hey, an empty slot, yay
			g_touchTracker[i].m_touchPointer = touch;
			return i;
		}
	}
	
    return -1;
}

- (int) GetTouchesActive {
	
	int count = 0;
    for (int i=0; i < MAX_TOUCHES; i++)
	{
		if (g_touchTracker[i].m_touchPointer)
		{
			count++;
		}
	}
	return count;
}

// Handles the start of a touch
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    // Enumerate through all the touch objects.
//	
//    for (UITouch *touch in touches)
//    {
//        //found a touch.  Is it already on our list?
//        int fingerID = GetFingerTrackIDByTouch:touch;
//		
//        if (fingerID == -1)
//        {
//            //add it to our list
//            fingerID = AddNewTouch(touch);
//        } else
//        {
//            //already on the list.  Don't send this
//            //LogMsg("Ignoring touch %d", fingerID);
//            continue;
//        }
//		
//        CGPoint pt =[touch locationInView:self];
//    }   
//	
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    // Enumerate through all the touch objects.
//    for (UITouch *touch in touches)
//    {
//        //found a touch.  Is it already on our list?
//        int fingerID = GetFingerTrackIDByTouch(touch);
//        if (fingerID != -1)
//        {
//            g_touchTracker[fingerID].m_touchPointer = NULL; //clear it
//        } else
//        {
//            //wasn't on our list
//            continue;
//        }
//		
//        CGPoint pt =[touch locationInView:self];
//        ConvertCoordinatesIfRequired(pt.x, pt.y);
//        GetMessageManager()->SendGUIEx(MESSAGE_TYPE_GUI_CLICK_END,pt.x, pt.y, fingerID);
//    }
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    // Enumerate through all the touch objects.
//    for (UITouch *touch in touches)
//    {
//        //found a touch.  Is it already on our list?
//        int fingerID = GetFingerTrackIDByTouch(touch);
//        if (fingerID != -1)
//        {
//            g_touchTracker[fingerID].m_touchPointer = NULL; //clear it
//        } else
//        {
//            //wasn't on our list
//            continue;
//        }
//		
//        CGPoint pt =[touch locationInView:self];
//        ConvertCoordinatesIfRequired(pt.x, pt.y);
//        GetMessageManager()->SendGUIEx(MESSAGE_TYPE_GUI_CLICK_END,pt.x, pt.y, fingerID);
//    }
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	// Enumerate through all the touch objects.
//    for (UITouch *touch in touches)
//    {
//		
//        //found a touch.  Is it already on our list?
//        int fingerID = GetFingerTrackIDByTouch(touch);
//        if (fingerID != -1)
//        {
//            //found it
//        } else
//        {
//            //wasn't on our list?!
//            continue;
//        }
//		
//        CGPoint pt =[touch locationInView:self];
//        ConvertCoordinatesIfRequired(pt.x, pt.y);
//        GetMessageManager()->SendGUIEx(MESSAGE_TYPE_GUI_CLICK_MOVE,pt.x, pt.y, fingerID);
//    }
//}
@end
