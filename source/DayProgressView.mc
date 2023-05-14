import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.Time.Gregorian;
using Toybox.Position; 
using Toybox.Time; 

class DayProgressView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Get and show the current time
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var timeLabel = View.findDrawableById("TimeLabel") as Text;
        timeLabel.setText(timeString);

        //Get and show the current date
        var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateLabel = View.findDrawableById("DateLabel") as Text;
        var weekdayIndex = (date.day_of_week+5)%7;
        var weekDayString = ["MO","TU","WE","TH","FR","SA","SU"][weekdayIndex];
        var dateString = weekDayString + " " + date.day;
        dateLabel.setText(dateString);
        dateLabel.setColor(secondaryColor);

        //drawSunset(dc);
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        //run our own update functions
        drawHourArc(dc);
        drawBattery(dc);
        drawSteps(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    //helper to convert to garmins degree units
    function degreesRotateAndClamp(degree){
        degree = 360-degree;
        degree += 90;
        if(degree > 260){
        	degree -= 360;
        }
        if(0 > degree){
        	degree += 360;
        }
    	return degree;
    }
    var primaryColor = 0xFFFFFF;
    var secondaryColor = 0x2669a3;

    //draw an arc on the outside, showing the progress of the day in 24hrs
    function drawHourArc(dc as Dc) as Void {
        
        var center = dc.getWidth()/2;

        dc.setPenWidth(3);
	    dc.setColor(secondaryColor, 0x000000);
        dc.drawArc(center, center, center-5, Toybox.Graphics.ARC_CLOCKWISE, 0, 360);

        var pwidth = 12;
        
    	var clockTime = System.getClockTime();
        var hours = clockTime.hour;
        var min = clockTime.min;
        
        var degrees = 360.0*hours/24.0;
        degrees += min*360.0/60.0/24.0;
        degrees = degreesRotateAndClamp(degrees);
        
        dc.setPenWidth(pwidth);
	    dc.setColor(0xFFFFFF, 0x000000);
	    dc.drawArc(center, center, center-pwidth/2, Toybox.Graphics.ARC_CLOCKWISE, 90, degrees);
        //Toybox.Graphics.FONT_SYSTEM_SMALL
    }

    var topMarginPercent = .39; //how far the icons will be from the top

    //draw a battery icon with the fill percentage
    function drawBattery(dc as Dc) as Void {
        var center = dc.getWidth()/2;

        var width = 34;
        var height = 18;
        var top = center*topMarginPercent;
        var left = center-41;

        //draw background, unfilled battery
        dc.setColor(secondaryColor, Graphics.COLOR_BLACK);
        dc.fillRectangle(left, top, width, height);
        //draw end knob of battery
        var endWidth = 3;
        var endHeight = 8;
        dc.fillRectangle(left+width, top+(height/2)-(endHeight/2), endWidth, endHeight);

        //get fill percentage
        var stats = System.getSystemStats(); 
        var pwr = stats.battery; 

        //draw filled part of battery
        dc.setColor(primaryColor, Graphics.COLOR_BLACK);
        dc.fillRectangle(left, top, width*pwr/100.0, height);
        
    }
    //draw a circle showing the steps goal
    function drawSteps(dc as Dc) as Void {
        var center = dc.getWidth()/2;

        var radius = 12;
        var top = center*topMarginPercent+9;
        var left = center+17+radius;

        //get step progress
        var activity = ActivityMonitor.getInfo();
        var stepPercent = 1.0*activity.steps/activity.stepGoal;

        //convert to degrees
        var degrees = 360.0*stepPercent+1; //+1 because we want 0 to draw a tiny amount, otherwise it would loop around to draw a full circle
        degrees = degreesRotateAndClamp(degrees);

        //draw background circle
        dc.setPenWidth(radius);
        dc.setColor(secondaryColor, Graphics.COLOR_BLACK);
	    dc.drawArc(left, top, radius/2, Toybox.Graphics.ARC_CLOCKWISE, 0, 360);
        //draw filled segment
        dc.setColor(primaryColor, Graphics.COLOR_BLACK);
	    dc.drawArc(left, top, radius/2, Toybox.Graphics.ARC_CLOCKWISE, 90, degrees);
        
    }
    /*function drawSunset(dc as Dc) as Void {
        var sunset = "n/a";
        var info = Activity.getActivityInfo();
        var pos = info.currentLocation;
        if (pos != null) {
            var sc = new SunCalc();
            var loc = pos.toRadians();
            var sunset_moment = sc.calculate(new Time.Moment(Time.now().value()), loc, SUNSET);
            sunset = sc.momentToString(sunset_moment, System.getDeviceSettings().is24Hour);
        }
        var dateLabel = View.findDrawableById("DateLabel") as Text;
        dateLabel.setText(sunset);
    }*/

}
