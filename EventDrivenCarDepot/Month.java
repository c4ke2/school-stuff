/**
* Month
*
* NOTE: I didn't write this enum, it is as it was
* bundled with the assignment, but with added comments.
*
* This enum deals represents months of the year.
*/
public enum Month 
{
    // this should probably use the Java Calendar class instead
    
    JAN, FEB, MAR, APR, MAY, JUN, JUL, AUG, SEP, OCT, NOV, DEC;

    private static final String[] NAMES = 
    {
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
    };

    //--------------------------------------------------------------------
    // toString
    // RETURNS: name of the month
    //--------------------------------------------------------------------
    public String toString() 
    {
        return NAMES[ordinal()];
    }
    
    //--------------------------------------------------------------------
    // fromInt
    // RETURNS: gets a month from a given int (0-11)
    //--------------------------------------------------------------------
    public static Month fromInt(int i) 
    {
        assert i >= 0 && i <= 11;
        return Month.values()[i];
    }
}
