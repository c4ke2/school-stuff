/**
* Event
*
* This class contains info on an event, such as
* wanted colour and quantity of cars
*/
import java.util.ArrayList;

public class Event
{
    //INSTANCE VARIABLES
    private Renter eventRenter;     //a renter to represent part of the event and hold some of its information, like location.  Bookings for the event are done in the name of this 'renter'
    private String name;            //name of the event
    private int month;              //month the event is on
    private int numCars;            //number of cars the event needs
    private String colour;          //colour of cars the event needs
    private ArrayList<Car> cars;    //cars used by the event
    
    //--------------------------------------------------------------------
    // Event (contructor)
    // initializes instance variables, makes the renter for the event
    //--------------------------------------------------------------------
    public Event(int numCars, int month, String colour, Location locale,String name)
    {
        assert numCars > 0;
        assert month >= 0 && month < 12;
        assert colour != null && name != null;
        
        this.numCars = numCars;
        this.month = month;
        this.colour = colour;
        this.name = name;
        eventRenter = new Renter("Event",colour,locale,month,month);
        cars = new ArrayList<>();
    }
    
    //--------------------------------------------------------------------
    // getEventRenter
    // returns the eventRenter for this event
    //--------------------------------------------------------------------
    public Renter getEventRenter()
    {
        return eventRenter;
    }
    
    //--------------------------------------------------------------------
    // toString
    // RETURNS: a string with info about the event
    //--------------------------------------------------------------------
    public String toString()
    {
        assert month >= 0 && month < 12;
        return name + " is in " + Month.fromInt(month) + ". They need "+numCars+" "+colour+" cars.  Located at "+eventRenter.getLocation();
    }
    
    //--------------------------------------------------------------------
    // tryBookEvent
    // tries to book this event for their desired time.
    //
    // PARAMETERS:
    // parkades - depots to search for cars
    //
    // RETURNS: true if booked, false if not enough cars of time/colour available
    //--------------------------------------------------------------------
    public boolean tryBookEvent(AllDepots parkades)
    {
        boolean booked = false;  //if booked yet
        int reserved = 0;        //how many we have so far
        
        //we need numCars available cars for the event in a certain colour, can take from mult. depots.
        ArrayList<Depot> closest = parkades.findCloseDepots(eventRenter.getLocation());
        assert closest != null;
        int i = 0;  //counter
        
        while(reserved<numCars && i<closest.size())
        {
            //get as many cars as we can of the colour from that depot
            cars.addAll(closest.get(i).getCarsOfColour(colour, month, month,numCars-reserved));
            reserved = cars.size();
            i++;
        }
        
        if(reserved==numCars)
        {//reserve those cars
            for(Car c : cars)
            {
                c.bookCar(month,month,eventRenter,true);
            }
            parkades.addRenter(eventRenter);
            booked = true;
        }
        
        return booked;
    }
}
