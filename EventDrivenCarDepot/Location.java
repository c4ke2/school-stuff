/**
* Location
*
* NOTE: I didn't write this class, it is as it was
* bundled with the assignment, but with added comments.
*
* This class contains info on a location on a 2D
* coordiante system.
*/
import java.util.Scanner;

public class Location 
{
    //INSTANCE VARIABLES
    private int x;
    private int y;
    
    //--------------------------------------------------------------------
    // Location (constructor)
    // initializes instance varibales
    //--------------------------------------------------------------------
    public Location(int x, int y) 
    {
        this.x = x;
        this.y = y;
    }
    
    //--------------------------------------------------------------------
    // toString
    // RETURNS: a string formatted as (x,y)
    //--------------------------------------------------------------------
    public String toString() 
    {
        return "("+x+","+y+")";
    }
    
    //--------------------------------------------------------------------
    // distance
    // gets the distance between two locations
    //
    // PARAMETERS: other - other location to find distance to.
    // RETURNS: euclidian distance between two locations (this and other)
    //--------------------------------------------------------------------
    public double distance(Location other) 
    {
        double xd = x - other.x;
        double yd = y - other.y;

        return Math.sqrt(xd * xd + yd * yd);
    }
}