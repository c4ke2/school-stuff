/**
* This program simulates a car rental service that
* rents cars out to renters and events provided by
* a formatted input file.
* outputs to output.txt
*
* Note: this program has some unused functions in some of the other classes
* due to the assignment description being non-specific on how output should look.
* these functions would have provided another style of output.
*/

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.util.ArrayList;
import java.util.Scanner;

public class A1Q1 
{    

 //CONSTANTS
 private static final String OUTPUT_NAME = "output.txt";    //name of the output file

//--------------------------------------------------------------------
// main
// drives the program
//
// PARAMETERS:
// args - if left empty, the input file will default to input.txt
//  otherwise, the first given arg will be used as the name of the input
//  file.
//
// RETURNS: nothing
//--------------------------------------------------------------------
 public static void main(String[] args) 
 {
  AllDepots parkades;                              //list of all our depots
  ArrayList<Event> eventDays = new ArrayList<>();  //list of our event days
  String line;                                     //line read from input file

  try 
  {
       //open the scanner
       Scanner in = new Scanner(new FileInputStream(args.length == 0 ? "input.txt" : args[0]));
   
       //make the depots
       parkades = new AllDepots();
       readDepots(parkades,in);
       
       //read through and book our renters and events
       readRentals(parkades, eventDays, in);
       
       //output to .txt file
       try
       {
           BufferedWriter out = new BufferedWriter(new FileWriter(OUTPUT_NAME));
           
           parkades.printCarScheduale(out);
           System.out.println("Wrote car scheduale to "+OUTPUT_NAME);
           
           out.close();
       }
       catch(Exception e)
       {
            System.out.println("Problem with output file: "+e.getMessage());
       }
        
       in.close();
   
       System.out.println("\nProgram ended normally.  Made by Alyssa Gregorash.");
  }
  catch (FileNotFoundException fnfe) 
  {
   System.out.println("File not found: " + fnfe.getMessage());
  }
 }
  
//--------------------------------------------------------------------
// readDepots
// creates all the depots in the simulation by reading from the input
// file and creating objects based on the formatted information.
//
// PARAMETERS:
// parkades - the AllDepots we are reading the depots for.
// in - the scanner we're using to read the file
//
// RETURNS: nothing
//--------------------------------------------------------------------
 private static void readDepots(AllDepots parkades, Scanner in)
 {
     String line;   //line from in
     assert in != null;
     assert parkades != null;
     
     try
     {
         //read in # of depots
         int numDepots = in.nextInt();
         
         //read in each depot
         for(int i=0;i<numDepots;i++)
         {
             Depot newDepot = new Depot();
             
             //get number of car colors             
             int numCarType = in.nextInt();
             for(int j=0;j<numCarType;j++)
             {
                 line = in.nextLine();
                 String[] splitted = line.split(",");
                 while(splitted.length == 1)    //if we have an empty space
                 {
                     line = in.nextLine();
                     splitted = line.split(",");
                 }
                 
                 int numOfColour = Integer.parseInt(splitted[1]);
                 //make that many cars of that color for the depot
                 newDepot.addCarsOfColour(splitted[0],numOfColour);
             }
             
             //get the location
             line = in.nextLine();
             String[] splitted = line.split(",");
             while(splitted.length == 1)    //if we have an empty space
             {
                line = in.nextLine();
                splitted = line.split(",");
             }
             Location locale = new Location(Integer.parseInt(splitted[0]), Integer.parseInt(splitted[1]));
             newDepot.addLocation(locale);
             
             //add newDepot to parkades
             parkades.addDepot(newDepot);
         }
     }
     catch (Exception e)
     {
         System.out.println("There was an exception while trying to load depots: "+e.getMessage() + "| Ensure there are no garabage characters at the start of the input file.");
     }
 }
 
//--------------------------------------------------------------------
// readRentals
// reads in all the lines for renters and events, calling to parse as
// it decides if each line is an event or a renter.
// Exits early if an entry cannot be booked.
//
// PARAMETERS:
// parkades - all the depots, so we can look through them when booking
//    a rental in the helper functions
// eventDays - list of events
// in - scanner to read the file with
//
// RETURNS: nothing
//--------------------------------------------------------------------
 private static void readRentals(AllDepots parkades, ArrayList<Event> eventDays, Scanner in)
 {
     //reads list for all renters and events
     String line;           //line from in
     boolean exit = false;  //if we're exiting early due to inability to book
     while(in.hasNextLine()&&!exit)
     {
         line = in.nextLine();

        if(line.trim().isEmpty())   //check if event
             exit = !readEvent(parkades,in,eventDays);
         else   //no blank space, it's a renter
             exit = !readRenter(parkades,in,line);
     }
 }
 
//--------------------------------------------------------------------
// readRenter
// Reads in a renter from the input file, stores them as a Renter and
// tries to book them.  States if renter can't be booked anywhere.
//
// PARAMETERS:
// parkades - all the depots, so we can look through them when booking
// in - scanner to read the file with
// line - line from the input file containing info about a renter
//
// RETURNS: true if the renter was booked, false if they couldn't be
//--------------------------------------------------------------------
 private static boolean readRenter(AllDepots parkades,Scanner in, String line)
 {     
     assert parkades != null;
     assert in != null;
     assert line != null;
     
     String[] parts = line.split(",");
     boolean booked = false;
     //assert parts.length == 6;

     if(parts.length==6)
     {
         try
         {
             Location locale = new Location(Integer.parseInt(parts[2]),Integer.parseInt(parts[3]));
             Renter newRenter = new Renter(parts[0],parts[1],locale,Integer.parseInt(parts[4]),Integer.parseInt(parts[5]));
         
             parkades.addRenter(newRenter);
     
             //see if we can book the renter
             booked = newRenter.tryBookMe(parkades, false);
     
             if(!booked)
                 System.out.println("Renter couldn't book a car, stopping process: "+newRenter);
         }
         catch (Exception e)
         {
             System.out.println("Trying to get input from line '"+line +"' did not work as expected.  Is it formatted correctly?");
         }
    }
    else
        System.out.println("Trying to get input from line '"+line +"' did not work as expected.  Is it formatted correctly?");
     
    return booked;
 }

//--------------------------------------------------------------------
// readEvent
// Reads in an event from the input file, stores it as an Event and
// tries to book it.  States if it can't be booked anywhere.
//
// PARAMETERS:
// parkades - all the depots, so we can look through them when booking
//    a rental in the helper functions
// in - scanner to read the file with
// eventDays - list of events to add the new event to
//
// RETURNS: true if event could be booked, false otherwise
//--------------------------------------------------------------------
 private static boolean readEvent(AllDepots parkades,Scanner in, ArrayList<Event> eventDays)
 {
     assert eventDays != null;
     assert in != null;
     assert parkades != null;

     boolean booked = false;
     Event newEvent = null;
     
     if((in.hasNextLine()))
     {
         String line = in.nextLine();
         String[] parts = line.split(",");
         assert parts.length == 6;
         
         if(parts.length == 6)
         {
             try
             {
                 newEvent = new Event(Integer.parseInt(parts[5]),Integer.parseInt(parts[3]),parts[4],new Location(Integer.parseInt(parts[1]),Integer.parseInt(parts[2])),parts[0]);
                 eventDays.add(newEvent);
         
                 booked = newEvent.tryBookEvent(parkades);
         
                 if(in.hasNextLine())
                     in.nextLine(); //skip the following empty line
            }
            catch (Exception e)
            {
                System.out.println("Trying to get input from line '"+line +"' did not work as expected.  Is it formatted correctly?");
            }
        }
        else
            System.out.println("Trying to get input from line '"+line +"' did not work as expected.  Is it formatted correctly?");
     }
     
     if(!booked)
         System.out.println("Event couldn't book needed cars, stopping process: "+newEvent);
     
     return booked;
 }
   
//--------------------------------------------------------------------
// printReservationsList
// Prints all renters at a depot during the given month
//
// PARAMETERS:
// parkades - the list of all depots to get the renters from.
//      it is not modified.
// month - the month we want to print for.  It isn't modified.
//
// RETURNS: nothing
//--------------------------------------------------------------------
 public static void printReservationList(AllDepots parkades, Month month) 
 {
      assert parkades != null;
      ArrayList<Renter> parkers = parkades.getRentersByMonth(month);

      System.out.println("\nReservation List: (" + month +")");
      //sort the list
      parkers.sort((p1,p2)-> p1.getName().compareTo(p2.getName()));
      
      //print the list
      for (Renter p: parkers) 
      {
        System.out.println(p.toReservationList());
      }
 }

}
