/**
* Car
*
* This class contains info on a car and methods to
* assign it to a renter or event for a time.
*/
import java.util.ArrayList;

public class Car
{
    //CONSTANTS
    //rental states for a car per month
    private final short OPEN = 0;
    private final short RENTER = 1;
    private final short EVENT = 2;
    
    //INSTANCE VARIABLES
    private short[] used = new short[12]; //if in use each month.  0 is unused, 1 is renter, 2 is event
    private String colour;                //colour of the car
    private String id;                    //unique id of the car, made with the Depot ID and a number
    private Depot source;                 //depot the car is at
    private ArrayList<Renter> users;      //list of renters for this car
    
    //--------------------------------------------------------------------
    // Location (constructor)
    // initializes instance varibales
    //--------------------------------------------------------------------
    public Car(Depot depot, String col)
    {
        source = depot;
        colour = col;
        users = new ArrayList<>();
        
        //get the id from the source depot
        id = source.makeCarID();
    }
    
    //--------------------------------------------------------------------
    // getColour
    // returns the colour of this car
    //--------------------------------------------------------------------
    public String getColour()
    {
        return colour;
    }
    
    //--------------------------------------------------------------------
    // toString
    // RETURNS: a string with the car's id, and all its reservations
    //  if there are no reservations, it returns an empty string
    //--------------------------------------------------------------------
    public String toString()
    {
        String s = "";
        assert id != null;
        if (id != null)
        if(users.size()>0)
        {
            s += "---"+ id + "---\n";
        
            //add the renters
            for(Renter r: users)
            {
                s += r.toReservationList()+"\n";
            }
        }

        return s;
    }
    
    //--------------------------------------------------------------------
    // available
    // checks if a car is available during a window of time
    // DOES NOT BOOK THE CAR
    //
    // PARAMETERS:
    // start, end - time window car needs to be available in (ints 0-11)
    // event - if we're checking for an event, since multiple events can
    //  co-exist in the same month.
    // RETURNS: if car is available during the time
    //--------------------------------------------------------------------
    public boolean available(int start, int end, boolean event)
    {
        assert start <= end && start >= 0 && end < 12;
        boolean available = true;
        if(!event)
        {//ensure all spots are completely unbooked for a renter
            for(int i=start;i<=end;i++)
            if(used[i]!=OPEN)
                available = false;
        }
        else
        {//events can exist with each other but not with renters
            for(int i=start;i<=end;i++)
            if(used[i]==RENTER)
                available = false;
        }
              
        return available;
    }
    
    //--------------------------------------------------------------------
    // bookCar
    // books this car for a given renter for a time window, if it's available
    //
    // PARAMETERS:
    // start, end - time window car needs to be available in (ints 0-11)
    // user - renter to book this car for.
    // event - if we're checking for an event, since multiple events can
    //  co-exist in the same month.
    // no parameters are modified.
    // RETURNS: if the car was booked or not
    //--------------------------------------------------------------------
    public boolean bookCar(int start, int end, Renter user,boolean event)
    {
        assert start <= end && start >= 0 && end < 12;
        boolean canBook = available(start,end,event);   //ensure the car is available
        if(canBook)
        {
            //book the car for that time
            if(event)                
                for(int i = start; i<=end; i++)
                    used[i]=EVENT;
            else
                for(int i=start;i<=end;i++)
                    used[i]=RENTER;
            
            users.add(user);
        }
        if(!canBook)
            System.out.println("Couldn't book over the needed time for "+user.getName());
        
        return canBook;
    }
}
