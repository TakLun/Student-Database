/*
 * Ernie Lee, CS 432, Project 2, Worked Alone
 * 
 */

import java.sql.*; 
import oracle.jdbc.*;
import java.math.*;
import java.io.*;
import java.awt.*;
import oracle.jdbc.pool.OracleDataSource;

public class project2 {

  public static void main (String args []) throws SQLException
  {
	  try
		{
		  	boolean continue_flag = true;
			while (continue_flag)
			{
		  	//Connect to Oracle server
			OracleDataSource ds = new oracle.jdbc.pool.OracleDataSource();
			ds.setURL("jdbc:oracle:thin:@grouchoIII.cc.binghamton.edu:1521:ACAD111");
			Connection conn = ds.getConnection("elee36", "DRK9275");

			//Menu
			System.out.println("\n\n__________________________________________________________");
		 	System.out.println("Menu Options:");
			
   			System.out.println("1. Show all students");
			System.out.println("2. Show all courses");
			System.out.println("3. Show all prerequisites");
			System.out.println("4. Show all classes");
      			System.out.println("5. Show all enrollments");
      
			System.out.println("6. Add Student");
			System.out.println("7. Show student's courses");
			System.out.println("8. Show prerequisite");
      			System.out.println("9. Show students in class");
			System.out.println("10. Enroll student");
			System.out.println("11. Drop student");
      			System.out.println("12. Delete student");
      
			System.out.println("14. See logs");
			System.out.println("15. Exit");
			
			System.out.println("Type in the number of your selection and press ENTER");
			System.out.println("_________________________________________________________");

			//Read data
			BufferedReader readOption;
			String option_number;
			int number;
			readOption = new BufferedReader(new InputStreamReader(System.in));
			option_number = readOption.readLine();
			number = Integer.parseInt(option_number);
			
			CallableStatement cs;
			ResultSet rs;
			Statement stmt;
			
			//Parition to approporate section
			switch (number)
			{
				case 1:

			      //Close connections
					rs.close();
					cs.close();
					break;
				case 2:

					//Close connections
					rs.close();
					cs.close();
					break;
				case 3:

			        //Close connections
					rs.close();
					cs.close();
					break;
				case 4:

			        //Close connections
					rs.close();
					cs.close();
					break;
				case 5:

					//Close connections
					cs.close();
					
					System.out.println("\nThe customer has been successfully added to the database.");
					break;
				case 6:

				        //Close connections
						rs.close();
						cs.close();
						stmt.close();
					break;
				case 7:

				        //Close connections
						rs.close();
						cs.close();
					break;
				case 8:

					//Close connections
					cs.close();
					
					System.out.println("\nThe account has been successfully added to the database.");
					break;
				case 9:
	
					//Close connections
					cs.close();
					
					System.out.println("\nThe transaction has been successfully added to the database.");
					break;
				case 10:
					//Call show_logs, return cursor pointer
			        cs = conn.prepareCall("begin ? := project2.show_logs(); end;");
			        //register the out parameter (the first parameter)
			        cs.registerOutParameter(1, OracleTypes.CURSOR);
			        
			        
			        //Execute PL/SQL code
			        cs.execute();
			        rs = (ResultSet)cs.getObject(1);

			        System.out.println("\nlogid\twho\ttime\twhat");
			        //Print tuples
			        while (rs.next()) {
			            System.out.println(rs.getString(1) + "\t" +
			                rs.getString(2) + "\t" + rs.getString(3) + 
			                "\t" + rs.getString(4));
			        }

			        //Close connections
					rs.close();
					cs.close();
					break;
				case 11:
					continue_flag = false;
					break;
				default:
					System.out.println("\nNot a valid option. Try again.");
					break;
			}	
		//Close connection to Oracle server
		conn.close();
		}
		}
		catch (SQLException ex) { System.out.println ("\n*** SQLException caught ***\n"); System.out.println(ex.getMessage());}
		catch (Exception e) {System.out.println ("\n*** other Exception caught ***\n");}
  }
} 
