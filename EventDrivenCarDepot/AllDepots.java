/**
* AllDepots
* 
* This class contains all Depots that
* the rentals can draw from
* and methods to work with them.
*/
import java.util.ArrayList;
import java.io.BufferedWriter;

public class AllDepots
{
    //INSTANCE VARIABLES
    private ArrayList<Depot> depots;    //list of all our depots
    private ArrayList<Renter> users;    //list of renters using the depots
    
    //--------------------------------------------------------------------
    // AllDepots (contructor)
    // initializes arraylists to be empty
    //--------------------------------------------------------------------
    public AllDepots()
    {
        depots = new ArrayList<>();
        users = new ArrayList<>();
    }
      
    //--------------------------------------------------------------------
    // getDepots
    // returns the arraylist of all the depots
    //--------------------------------------------------------------------
    public ArrayList<Depot> getDepots()
    {
        return depots;
    }
    
    //--------------------------------------------------------------------
    // getDepot
    // returns the depot with given index i in the class' arraylist
    //--------------------------------------------------------------------
    public Depot getDepot(int i)
    {
        Depot depot = null;
        assert i < depots.size();
        if(i<depots.size())
            depot = depots.get(i);
            
        return depot;
    }
    
    //--------------------------------------------------------------------
    // getRenter
    // returns the renter with given index i in the class' arraylist
    //--------------------------------------------------------------------
    public Renter getRenter(int i)
    {
        Renter user = null;
        assert i < users.size();
        if(i<users.size())
            user = users.get(i);
            
        return user;
    }

    //--------------------------------------------------------------------
    // addDepot
    // adds given depot d to the class' arraylist
    //--------------------------------------------------------------------
    public void addDepot(Depot d)
    {
        assert d != null;
        if(d!=null)
            depots.add(d);
    }
    
    //--------------------------------------------------------------------
    // addRenter
    // adds given renter r to the class' arraylist
    //--------------------------------------------------------------------
    public void addRenter(Renter r)
    {
        assert r != null;
        if(r!=null)
            users.add(r);
    }
        
    //--------------------------------------------------------------------
    // toString
    // makes a string with information about all the depots
    //
    // RETURNS: string with information about all the depots.
    //--------------------------------------------------------------------
    public String toString()
    {
        String s = "ALL DEPOTS:\n";
        for(Depot d : depots)
            s+=d;
        return s;
    }
    
    //--------------------------------------------------------------------
    // printCarScheduale
    // calls to each depot for them to write out the schedualed bookings
    // for all their cars.
    //
    // PARAMETERS:
    // out - bufferedwriter to pass to the depots for writing. not modified.
    //--------------------------------------------------------------------
    public void printCarScheduale(BufferedWriter out) throws Exception
    {
        assert out != null;
        if(out != null)
        for(Depot d : depots)
            d.printAllCars(out);
    }
    
    //--------------------------------------------------------------------
    // findCloseDepots
    // looks through all users and adds the ones who were booked during a
    // desired month to a list, then returns that list.
    //
    // PARAMETERS:
    // locale - location to organize depots around.  the closest depot to this
    //   will be first on the returned list, the furthest will be last.
    //   not modified.
    // RETURNS:
    //  ArrayList of the depots, organized closest to futherest from locale.
    //--------------------------------------------------------------------
    public ArrayList findCloseDepots(Location locale)
    {
        assert locale != null;
        int numDepots = Depot.getNumDepots();
       
        //copy the list
        ArrayList<Depot> closeOrder = new ArrayList<>();
        for(Depot d: depots)
            closeOrder.add(d);
            
        //sort the order by distance
        closeOrder.sort((d1,d2) -> Double.compare(locale.distance(d1.getLocation()), locale.distance(d2.getLocation())));
        
        return closeOrder;
    }
    
    //--------------------------------------------------------------------
    // getRentersByMonth
    // looks through all users and adds the ones who were booked during a
    // desired month to a list, then returns that list.
    //
    // PARAMETERS:
    // month - month to look for renters in. not modified.
    //
    // RETURNS: ArrayList of renters who were using the depots in that month.
    //--------------------------------------------------------------------
    public ArrayList getRentersByMonth(Month month)
    {
        ArrayList<Renter> monthRenters = new ArrayList();   //list will hold all renters in that month
        
        int monthInt = month.ordinal();
        
        //check each renter if they're booked for that month
        for(Renter r: users)
        {
            if((monthInt>=r.getStartMonth() && monthInt<=r.getEndMonth()))
            {
                    monthRenters.add(r);
            }
        }
        
        return monthRenters;
    }
}
