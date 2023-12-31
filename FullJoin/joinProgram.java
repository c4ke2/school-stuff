// this program simulates an sql full join using two formatted text files.
// no libraries or any short cuts were allowed.  Modified from the left join.

import java.io.*;
import java.util.ArrayList;

public class joinProgram
{
    public static void main(String args[])
    {
        if(args.length==3)
        {
            try
            {
                //test augments for my IDE: {"file1.txt","file2.txt","A,B"}
                
                FileReader fr = new FileReader(args[0]);
                FileReader sr = new FileReader(args[1]);
                BufferedReader file1 = new BufferedReader(fr);
                BufferedReader file2 = new BufferedReader(sr);
                
                //break the third arg into the names we are looking for
                String[] joinOn = args[2].split(",");
                
                join(file1,file2,joinOn);
                
                file1.close();
                file2.close();
                fr.close();
                sr.close();
            }
            catch(IOException e)
            {
                System.out.println("There was a problem opening a file.  Ensure the files "+args[0]+" and "+args[1]+" exist.");
            }
        }
        else
        {
            System.out.println("<!> Augments incorrect. Please execute program with augments of format:");
            System.out.println("java joinProgram File1.txt File2.txt A,B");
        }
    }
    
    private static void join(BufferedReader file1, BufferedReader file2, String[] joinOn)
    {
        //read the stuff in
        try
        {
            String[] headers1 = file1.readLine().split(",");
            String[] headers2 = file2.readLine().split(",");
            int[] headInd1 = new int[joinOn.length];
            int[] headInd2 = new int[joinOn.length];
            int lineLength1 = headers1.length;
            int lineLength2 = headers2.length;
            boolean error = false;
            
            ArrayList<String>[] result = new ArrayList[headers1.length+headers2.length];
            
            for(int i=0;i<joinOn.length;i++)
            {
                //ensure the join condition actually exists in both headers, save the index of each if it exists
                headInd1[i] = indexFromString(headers1,joinOn[i]);
                headInd2[i] = indexFromString(headers2,joinOn[i]);
                if (headInd1[i]==-1 || headInd2[i]==-1)
                    error = true;
            }
            
            if(!error)
            {
                ArrayList<String>[] table1 = readTable(file1,lineLength1);
                ArrayList<String>[] table2 = readTable(file2,lineLength2);
                
                boolean[] usedTab2Tuple = new boolean[table2[0].size()];
                for(int i=0;i<usedTab2Tuple.length;i++)
                    usedTab2Tuple[i]=false;
                     
                for(int i=0;i<result.length;i++)
                {                    
                    result[i] = new ArrayList<String>();
                    //put the headers in
                    if(i<headers1.length)
                        result[i].add(headers1[i]);
                    else
                        result[i].add(headers2[i-headers1.length]);
                }

                //find tuples in table 2 that match table 1, looking only at the joinOn coloums
                for(int i=0;i<table1[0].size();i++)
                {//for each tuple of numbers in table 1
                    String[] tuple = new String[joinOn.length];

                    for(int j=0;j<headInd1.length;j++)
                    {//for each value of a join attribute in that row
                       tuple[j] = table1[headInd1[j]].get(i);
                    }
                    
                    boolean tupleMatch = false;

                    //compare tuple to every tuple in table 2 to look for matches (accounts for multiple of same tuple)
                    for(int i2=0;i2<table2[0].size();i2++)
                    {//for each tuple of numbers in table 2
                        boolean match = true;
                        for(int j2=0;j2<headInd2.length;j2++)
                        {//for each value of a join attribute in that row
                           if(!(tuple[j2].equals(table2[headInd2[j2]].get(i2))))
                            {//if any part doesn't match, it's not a match                                
                                match = false;
                            }
                        }
                        
                        if(match)
                        {//we found something, shove some data into the result table
                            tupleMatch=true;
                            usedTab2Tuple[i2]=true;
                            //i2 is row in table2
                            //i is row in table1
                            for(int k=0;k<result.length;k++)
                            {
                                //make the tables kiss
                                if(k<table1.length)
                                {
                                    result[k].add(table1[k].get(i));
                                }
                                else
                                {
                                    result[k].add(table2[k-table1.length].get(i2));
                                }
                            }
                        }
                    }
                    
                    if(!tupleMatch)
                    {
                        //tuple in table 1 has no match
                        for(int k=0;k<result.length;k++)
                        {
                            //make the tables kiss with nulls for table 2
                            if(k<table1.length)
                            {
                                result[k].add(table1[k].get(i));
                            }
                            else
                            {
                                result[k].add("null");
                            }
                        }
                    }
                }
                
                //add unused tuples from table 2
                for(int i=0;i<usedTab2Tuple.length;i++)
                {
                    if(!usedTab2Tuple[i])
                    {//for an unused tuple in table 2
                        for(int k=0;k<result.length;k++)
                        {
                            if(k<table1.length)
                            {
                                result[k].add("null");
                            }
                            else
                            {
                                result[k].add(table2[k-table1.length].get(i));
                            }
                        }
                    }
                }
                
                System.out.println("Result: ");
                printTable(result);
            }
            else
                System.out.println("Cannot join on given values, as one or both files don't have them.");
        }
        catch (IOException e)
        {
            System.out.println("There was a problem reading a file.");
        }
    }
    
    private static int indexFromString(String[] headers,String target)
    {
        boolean found = false;
        int i=0;
        while(!found && i<headers.length)
        {
            if(headers[i].equals(target))
                found = true;
            else
            i++;
        }
        if(!found)
            i = -1;
        return i;
    }
    
    private static void printTable(ArrayList[] table)
    {
        for (int i = 0; i < table[0].size(); i++)
        {//for a row in the table (tuple)
            for (int j = 0; j < table.length; j++) 
            {
               System.out.print(table[j].get(i) + " ");
            }
            System.out.println();
        }
    }
    
    private static ArrayList<String>[] readTable(BufferedReader file, int length)
    {
        ArrayList<String>[] table = new ArrayList[length];
        for(int i=0;i<length;i++)
            table[i] = new ArrayList<String>();
        String[] parts;
        try
        {
            String line = file.readLine();
            while(line!=null)
            {
                parts = line.split(",");
                
                for(int i=0;i<parts.length;i++)
                {
                    table[i].add(parts[i]);
                }

                line = file.readLine();
            }
        }
        catch(IOException e)
        {
            System.out.println("There was a problem reading a file in.");
        }
        return table;
    }
}
