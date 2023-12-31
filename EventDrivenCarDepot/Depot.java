/**
* Depot
*
* This class contains info on one Depot,
* such as a list of its cars and id.
* It contains methods to look for cars.
*/
import java.util.ArrayList;
import java.io.BufferedWriter;

public class Depot
{
    //INSTANCE VARIABLES
    private Location location;              //location of the depot
    private char id;                        //identifying character to put in the car ids

    private int totNumCars;                 //total number of cars at this depot
    private ArrayList<Car> cars;            //list of cars at this depot
    
    //CLASS VARIABLES
    private static int numDepots = 0;       //how many depots exist (used for setting id)
    private static int nextCarID = 1;       //number id of the next car, static between all depots
    
    //--------------------------------------------------------------------
    // Depot (contructor)
    // initializes instance variables
    //--------------------------------------------------------------------
    public Depot()
    {
        // initialise instance variables
        id = (char)('A' + numDepots);
        numDepots++;
        totNumCars = 0;
        cars = new ArrayList<>();
    }
    
    //--------------------------------------------------------------------
    // getNumDepots
    // returns number of depots
    //--------------------------------------------------------------------
    public static int getNumDepots()
    {
        return numDepots;
    }
    
    //--------------------------------------------------------------------
    // addLocation
    // sets location of this depot
    //--------------------------------------------------------------------
    public void addLocation(Location l)
    {
        location = l;
    }
    
    //--------------------------------------------------------------------
    // getLocation
    // returns the location
    //--------------------------------------------------------------------
    public Location getLocation()
    {
        return location;
    }
    
    //--------------------------------------------------------------------
    // equals
    // determines if two depots are the same.
    //
    // RETURNS: true if two depots' id's match
    //--------------------------------------------------------------------
    public boolean equals(Depot other)
    {
        return this.id == other.id;
    }
    
    //--------------------------------------------------------------------
    // toString
    // makes a string with information about the depot.
    //
    // RETURNS: string with information about this depot.
    //--------------------------------------------------------------------
    public String toString()
    {
        return "Depot with id "+id+" has "+totNumCars+" cars. It is at "+location.toString()+"\n";
    }
    
    //--------------------------------------------------------------------
    // printAllCars
    // prints out all cars at the depot to the output file
    // PARAMETERS:
    // out - bufferedwriter to write to file with
    //--------------------------------------------------------------------
    public void printAllCars(BufferedWriter out) throws Exception
    {
        assert out != null;
        if(out != null)
            for(Car c : cars)
                if(!c.toString().equals(""))    
                {
                    out.write(c.toString());
                    out.write("\n");
                }
    }
    
    //--------------------------------------------------------------------
    // makeCarID
    // crafts the id for a new car using depot id and # of cars so far.
    // spaces consistantly with leading zeros, assumes there are never more
    // than four digt's worth of cars.
    //
    //RETURNS:
    // returns the crafted car ID as a string.
    //--------------------------------------------------------------------
    public String makeCarID()
    {
        String s = ""+id;
        
        //leading 0's
        if(nextCarID<0)
            s+="000"+nextCarID;
        else if(nextCarID<100)
            s+="00"+nextCarID;
        else if(nextCarID<1000)
            s+="0"+nextCarID;
        else
            s+=""+nextCarID;
            
        nextCarID++;    //increment for next time, so all ID's are unique
        return s;
    }
    
    //--------------------------------------------------------------------
    // addCarsOfColour
    // create num cars of a given colour for this depot.
    //
    // PARAMETERS:
    // colour - the colour of car we're making
    // num - how many cars to make
    //--------------------------------------------------------------------
    public void addCarsOfColour(String colour, int num)
    {
        assert num > 0 && colour != null;
        for(int i=0;i<num;i++)
        {
            //make the cars and add them to the depot
            Car newCar = new Car(this, colour);
            cars.add(newCar);
        }
        totNumCars+=num;
    }
    
    //--------------------------------------------------------------------
    // getCarOfColour
    // finds a car in depot that is in the wanted colour and available during
    // the needed time.
    //
    // PARAMETERS:
    // colour - car colour to look for
    // start, end - start and end months to rent (integers 0-11)
    // event - if we're looking for an event, in which case it can be booked
    //   along with other events
    // RETURNS:
    //  a car that is available during the wanted time of the wanted colour,
    //  or null if no such car is at this depot.
    //--------------------------------------------------------------------
    public Car getCarOfColour(String colour, int start, int end, boolean event)
    {
        //looks for a single car of colour in the depot
        assert start <= end && start >= 0 && end < 12;
        
        Car car = null;
        boolean found = false;
        int i = 0;
        while(!found && i<totNumCars)
        {
            //check each car
            if(cars.get(i).getColour().equals(colour))
            {
                //got car of the colour, check available
                found = cars.get(i).available(start,end,event);
            }
            
            if(!found)
                i++;
            else
                car = cars.get(i);
        }
        
        return car;
    }
    
    //--------------------------------------------------------------------
    // getCarsOfColour
    // finds cars in in the depot that are in the wanted colour and available during
    // the needed time.
    //
    // PARAMETERS:
    // colour - car colour to look for
    // start, end - start and end months to rent (integers 0-11)
    // num - number of cars to find of needed colour/availability
    //
    // RETURNS:
    //  list of cars that meet the colour/time requirements, up tp num cars.
    //--------------------------------------------------------------------
    public ArrayList getCarsOfColour(String colour, int start, int end, int num)
    {
        //looks for a num cars of colour in the depot, returns however many it found
        assert start <= end && start >= 0 && end < 12;
        assert num > 0 && colour != null;
        
        ArrayList<Car> found = new ArrayList<>();   //list of cars that meet the requirements
        int got = 0;                                //how many cars found so far    
        int i = 0;  //counter
        
        while(got<num && i<totNumCars)
        {
            //check each car
            if(cars.get(i).getColour().equals(colour))
            {
                //got car of the colour, check available
                if(cars.get(i).available(start,end,true))
                {
                    found.add(cars.get(i));
                    got++;
                }
            }
            i++;
        }
        
        return found;
    }
}
