/**
* Renter
*
* This class contains info on a renter, such as
* rent time, location, wanted colour and name.
*/
import java.util.ArrayList;

public class Renter
{
    //INSTANCE VARIABLES
    String lastName;        //name of the renter
    String wantedColour;    //desired car colour of renter
    Location location;      //renter's location
    int rentStart, rentEnd; //start and end dates of renter (integers 0-11)
    
    //--------------------------------------------------------------------
    // Renter (contructor)
    // initializes instance variables
    //--------------------------------------------------------------------
    public Renter(String name, String colour,Location locale, int start, int end)
    {
        assert start <= end && start >= 0 && end < 12;
        assert colour != null && name != null && locale !=null;
        
        lastName = name;
        wantedColour = colour;
        location = locale;
        rentStart = start;
        rentEnd = end;
    }
    
    //--------------------------------------------------------------------
    // getLocation
    // returns the renter's location
    //--------------------------------------------------------------------
    public Location getLocation()
    {
        return location;
    }
    //--------------------------------------------------------------------
    // getStartMonth    &   getEndMonth
    // returns the start/end month of the renter (as an integer)
    //--------------------------------------------------------------------    
    public int getStartMonth()
    {
        return rentStart;
    }
    public int getEndMonth()
    {
        return rentEnd;
    }
    
    //--------------------------------------------------------------------
    // getName
    // returns the name of the renter
    //--------------------------------------------------------------------
    public String getName()
    {
        return lastName;
    }
        
    //--------------------------------------------------------------------
    // toString
    // RETURNS: a string with info about the renter
    //--------------------------------------------------------------------
    public String toString()
    {
        return lastName + " wants a "+wantedColour+" car from "+rentStart+" to "+rentEnd+". they are at "+location;
    }
    
    //--------------------------------------------------------------------
    // toReservationList
    // gives a string representation of the renter to put on the reservation
    // list.
    // RETURNS: a string in the format "lastname  start-end"
    //--------------------------------------------------------------------
    public String toReservationList()
    {
        assert lastName != null;
        String s = lastName;
        while(s.length()<10)
            s+=" ";
        s += rentStart+"-"+rentEnd;
        return s;
    }
    
    //--------------------------------------------------------------------
    // tryBookMe
    // tries to book this renter for their desired time.
    //
    // PARAMETERS:
    // parkades - depots to search for cars
    // event - if this is an event's renter
    //
    // RETURNS: true if booked, false if no cars of time/colour available
    //--------------------------------------------------------------------
    public boolean tryBookMe(AllDepots parkades, boolean event)
    {
        assert parkades != null;
        
        boolean booked = false;     //if booking was successful
        Car c = null;               //car to book
        ArrayList<Depot> closest = parkades.findCloseDepots(location);  //list of depots, closest to futhest from this renter
        
        int i = 0;  //counter
        while(c==null && i<closest.size())
        {
            //look through depots in order of closeness to find an available car of right colour
            c = closest.get(i).getCarOfColour(wantedColour,rentStart,rentEnd,event);
            i++;
        }
        
        if(c!=null)  //we found a car that should work, time to book it
            booked = c.bookCar(rentStart,rentEnd,this,event);
        
        return booked;
    }
}
