/*
Ernie Lee, CS 432, Project 2, Worked Alone
*/

/*Create sequence for logid in logs table*/
create sequence log_seq
			minvalue 10000
			maxvalue 99999
			start with 10000
			increment by 1;
/

/*Trigger that catches exceptions whenever the program inserts tuples into Transactions*/
create or replace trigger enrollemts_exceptions
before insert on Enrollments
for each row
	declare 
		sid2 char(4);
		classid2 char(5);
		bad_id exception;
		bad_enrollemnt exception;
		bad_enroll_type exception;
	begin
		select count(sid) into sid2 from Students where sid = :new.sid;
		select count(classid) into cid2 from classes where classid = :new.classid;
		/*If no sid exists then throw exception*/
		if sid2 <= 0 then
			raise bad_id;
		end if;
		/*If no classid exists then throw exception*/
		if classid2 <= 0 then
			raise bad_id;
		end if;
		if :new.transaction_type != 'Open' then
			count_num := count_num + 1;
		end if;
		if :new.transaction_type != 'Close' then
			count_num := count_num + 1;
		end if;
		if :new.transaction_type != 'Withdraw' then
			count_num := count_num + 1;
		end if;
		if :new.transaction_type != 'Deposit' then
			count_num := count_num + 1;
		end if;
		if :new.transaction_type != 'Balance' then
			count_num := count_num + 1;
		end if;
		/*If transaction_types does not equal any valid transaction_type then throw exception*/
		if count_num >= 5 then
			raise bad_trans_type;
		end if;
		/*If not enough funds for withdraw then throw exception*/
		if :new.transaction_type = 'Withdraw' then
			select balance into balance2 from Accounts where aid = :new.aid;
			if balance2 < :new.amount then
				raise no_funds;
			end if;
		end if;
	exception
		/*Exceptions*/
		when no_funds then
			raise_application_error(-20001, 'Invalid transaction: insufficient funds.');
		when bad_id then
			raise_application_error(-20001, 'the id is invalid.');
		when bad_trans_type then
			raise_application_error(-20001, 'invalid transaction type.');
	end;
/
/*Execute trigger when program inserts data into Customers*/
create or replace trigger add_cust_logging
after insert on Customers
for each row
	declare
		curr_time date;
	begin
		/*Get current time, then insert into logs with other data*/
		select to_char(sysdate, 'DD-MON-YYYY') current_time into curr_time from dual;
		insert into logs (logid, who, time, what) values (log_seq.nextval, 'elee21', curr_time, 'A customer is added to the customers 
table.');
	end;
/
/*Execute trigger when program deletes data from Customers*/
create or replace trigger delete_cust_logging
after delete on Customers
for each row
	declare
		curr_time date;
	begin
		/*Get current time, then insert into logs with other data*/
		select to_char(sysdate, 'DD-MON-YYYY') current_time into curr_time from dual;
		insert into logs (logid, who, time, what) values (log_seq.nextval, 'elee21', curr_time, 'A customer is deleted from the customers 
table.');
	end;
/
/*Execute trigger when program inserts data into Accounts*/
create or replace trigger add_acct_logging
after insert on Accounts
for each row
	declare
		curr_time date;
	begin
		/*Get current time, then insert into logs with other data*/
		select to_char(sysdate, 'DD-MON-YYYY') current_time into curr_time from dual;
		insert into logs (logid, who, time, what) values (log_seq.nextval, 'elee21', curr_time, 'An account is added to the Accounts 
table.');
	end;
/
/*Execute trigger when program deletes data from Accounts*/
create or replace trigger delete_acct_logging
after delete on Accounts
for each row
	declare
		curr_time date;
	begin
		/*Get current time, then insert into logs with other data*/
		select to_char(sysdate, 'DD-MON-YYYY') current_time into curr_time from dual;
		insert into logs (logid, who, time, what) values (log_seq.nextval, 'elee21', curr_time, 'An account is deleted from the Accounts 
table.');
	end;
/
/*Project2 specification*/
create or replace package project2 as
	type ref_cursor is ref cursor;
	function show_logs return ref_cursor;
	function show_students return ref_cursor;
	function show_courses return ref_cursor;
	function show_prerequisites return ref_cursor;
	function show_classes return ref_cursor;
	function show_enrollments return ref_cursor;

	procedure add_student(sid2 in Students.sid%type, sfname2 in Students.firstname%type, slname2 in Students.lastname%type, status2 in Students.status%type, sgpa2 in Students.gpa%type, semail2 in Students.email%type);
	function show_student_courses(sid2 in Students.sid%type) return ref_cursor;
	function show_prerequisite(cid2 in Classes.cid%type) return ref_cursor;
	procedure add_account(cid2 in Customers.cid%type, aid2 in Accounts.aid%type, account_type2 in Accounts.account_type%type, rate2 in 
Accounts.rate%type, balance2 in Accounts.balance%type, eid2 in Employees.eid%type, trans_num2 in Transactions.trans_num%type);
	procedure add_transaction(eid2 in Transactions.eid%type, cid2 in Transactions.cid%type, aid2 in Transactions.aid%type, amount2 in 
Transactions.amount%type, transaction_type2 in Transactions.transaction_type%type, trans_num2 in Transactions.trans_num%type);
end;
/
show errors

/*Project2 body*/
create or replace package body project2 as

	/*Function: shows all customer tuples
		Parameters: none
		Return: cursor pointer to select Customers query
	*/
	function show_customers return ref_cursor as
		rc ref_cursor;
		cid char(4);
		cname varchar2(20);
		city varchar2(10);
		cursor customers_table is
			select * from Customers;
			customers_tuple customers_table%rowtype;
		begin
			for customers_tuple in customers_table loop
				dbms_output.put_line(customers_tuple.cid || ', ' || customers_tuple.cname || ', ' || customers_tuple.city);
			end loop;
			begin
				/*Link cursor pointer to query and return it*/
				open rc for
					select * from Customers order by cid asc;
					return rc;
			end;
		end;
		
	/*Function: shows all employees tuples
		Parameters: none
		Return: cursor pointer to select Employees query
	*/
	function show_employees return ref_cursor as
		rc ref_cursor;
		eid char(4);
		ename varchar2(20);
		city varchar2(10);
		cursor employees_table is
			select * from Employees;
			employees_tuple employees_table%rowtype;
		begin
			for employees_tuple in employees_table loop
				dbms_output.put_line(employees_tuple.eid || ', ' || employees_tuple.ename || ', ' || employees_tuple.city);
			end loop;
			begin
				/*Link cursor pointer to query and return it*/
				open rc for
					select * from Employees order by eid asc;
					return rc;
			end;
		end;
	
	/*Function: shows all Accounts tuples
		Parameters: none
		Return: cursor pointer to select Accounts query
	*/
	function show_accounts return ref_cursor as
		rc ref_cursor;
		aid char(7);
		account_type varchar2(20);
		rate number(3,2);
		balance number(7);
		date_opened date;
		cursor accounts_table is
			select * from Accounts;
			accounts_tuple accounts_table%rowtype;
		begin
			for accounts_tuple in accounts_table loop
				dbms_output.put_line(accounts_tuple.aid || ', ' || accounts_tuple.account_type || ', ' || accounts_tuple.rate || ', ' 
|| accounts_tuple.balance || ', ' || accounts_tuple.date_opened);
			end loop;
			begin
				/*Link cursor pointer to query and return it*/
				open rc for
					select * from Accounts order by aid asc;
					return rc;
			end;
		end;
	
	/*Function: shows all Transactions tuples
		Parameters: none
		Return: cursor pointer to select Transactions query
	*/
	function show_transactions return ref_cursor as
		rc ref_cursor;
		trans_num char(7);
		eid char(4);
		cid char(4);
		aid char(6);
		amount number(7,2);
		transaction_type varchar2(8);
		date_trans date;
		cursor transactions_table is
			select * from Transactions;
			transactions_tuple transactions_table%rowtype;
		begin
			for transactions_tuple in transactions_table loop
				dbms_output.put_line(transactions_tuple.trans_num || ', ' || transactions_tuple.eid || ', ' || transactions_tuple.cid 
|| ', ' || transactions_tuple.aid || ', ' || transactions_tuple.transaction_type || ', ' || transactions_tuple.date_trans);
			end loop;
			begin
				/*Link cursor pointer to query and return it*/
				open rc for
					select * from Transactions order by trans_num asc;
					return rc;
			end;
		end;
		
	/*Procedure: add cid, cname, and city into Customers based on user input
		Parameters: cname, city
		Return: none
	*/
	procedure add_customer(cid2 in Customers.cid%type, cname2 in Customers.cname%type, city2 in Customers.city%type) is
		cid_next char(4);
		count_rows number(1);
		bad_cid exception;
		begin
			select count(cid) into count_rows from Customers where cid = cid2;
			/*If there is another cid primary key in table, throw exception*/
			if count_rows >= 1 then
				raise bad_cid;
			end if;
			begin
				insert into Customers (cid, cname, city) values (cid2, cname2, city2);
			end;
		exception
			when bad_cid then
				raise_application_error(-20001, 'Duplicate cid.');
		end;
		
	/*Function: Finds a customer in the customers table and then finds corresponding Accounts linked to that customer
		Parameters: cid
		Return: cursor pointer to select accounts table
	*/
	function find_customer(cid2 in Customers.cid%type) return ref_cursor as
		rc ref_cursor;
		name varchar2(20);
		no_aid_found exception;
		no_cid_found exception;
		cursor account_numbers is
			select aid, account_type, rate, balance, date_opened from Accounts where aid in (select distinct t.aid from Transactions t 
where t.cid = cid2 and t.transaction_type = 'Open');
			account_number account_numbers%rowtype;
		begin
			/*find cname of corresponding cid. If not found, throw exception*/
			select cname into name from Customers where cid = cid2;
			dbms_output.put_line('Customer - cid: ' || cid2 || ' cname: ' || name);
			begin
				if not account_numbers%isopen then
					open account_numbers;
				end if;
				fetch account_numbers into account_number;
				/*If customer has no accounts, throw exception*/
				if account_numbers%notfound then
					raise no_aid_found;
				end if;
				dbms_output.put_line('Account(s):');
				dbms_output.put_line('aid' || ', ' || 'account_type' || ', ' || 'rate' || ', ' || 'balance' || ', ' || 
'date_opened');
				while account_numbers%found loop
					dbms_output.put_line(account_number.aid || ', ' || account_number.account_type || ', ' || account_number.rate 
|| ', ' || account_number.balance || ', ' || account_number.date_opened);
					fetch account_numbers into account_number;
				end loop;
				begin
					/*Link cursor pointer to query and return it*/
					open rc for
						select * from Accounts where aid in (select distinct t.aid from Transactions t where t.cid = cid2 and 
t.transaction_type = 'Open');
						return rc;
				end;
			exception
				when no_aid_found then
					raise_application_error(-20001, 'The customer has no account.');
			end;
		exception
			when no_data_found then
				raise_application_error(-20001, 'The cid is invalid.');
		end;
		
	/*Function: Finds that account in the Accounts table based on aid parameter. Returns all transactions from that account
		Parameters: aid
		Return: cursor pointer to the select Transactions query
	*/
	function find_account(aid2 in Accounts.aid%type) return ref_cursor as
		rc ref_cursor;
		account_count number(2);
		no_aid_found exception;
		no_trans_found exception;
		cursor trans_table is
			select * from Transactions where aid = aid2;
			trans_tuple trans_table%rowtype;
		begin
			select count(*) into account_count from Accounts where aid = aid2;
			/*If aid does not exist, then throw exception*/
			if account_count <= 0 then
				raise no_aid_found;
			end if;
			dbms_output.put_line('Account - aid: ' || aid2);
			begin
				if not trans_table%isopen then
					open trans_table;
				end if;
				fetch trans_table into trans_tuple;
				/*If there are no tuples fetched from Transactions table, then throw exception*/
				if trans_table%notfound then
					raise no_trans_found;
				end if;
				dbms_output.put_line('Transaction(s):');
				dbms_output.put_line('trans_num' || ', ' || 'eid' || ', ' || 'cid' || ', ' || 'aid' || ', ' || 'amount' || ', ' || 
'transaction_type' || ', ' || 'date_trans');
				while trans_table%found loop
					dbms_output.put_line(trans_tuple.trans_num || ', ' || trans_tuple.eid || ', ' || trans_tuple.cid || ', ' || 
trans_tuple.aid || ', ' || trans_tuple.amount || ', ' || trans_tuple.transaction_type || ', ' || trans_tuple.date_trans);
					fetch trans_table into trans_tuple;
				end loop;
				begin
					/*Link cursor pointer to query and return it*/
					open rc for
						select * from Transactions where aid = aid2;
						return rc;
				end;
			exception
				when no_trans_found then
					raise_application_error(-20001, 'No transaction found.');
			end;
		exception
			when no_aid_found then
				raise_application_error(-20001, 'The aid is invalid.');
		end;
		
	/*Procedure: Adds an account to the accounts table, and inserts an OPEN transaction to transactions table
		Parameters: cid, aid, account_type, rate, balance, eid
		Return: none
	*/
	procedure add_account(cid2 in Customers.cid%type, aid2 in Accounts.aid%type, account_type2 in Accounts.account_type%type, rate2 in 
Accounts.rate%type, balance2 in Accounts.balance%type, eid2 in Employees.eid%type, trans_num2 in Transactions.trans_num%type) is
		last_trans_num char(7);
		customer_valid number(2);
		account_valid char(7);
		curr_time date;
		no_cid_found exception;
		duplicate_aid exception;
		count_rows number(10);
		begin
			select count(cid) into customer_valid from Customers where cid = cid2;
			/*If cid does not exist in Customers table, throw exception*/
			if customer_valid <= 0 then
				raise no_cid_found;
			end if;
			/*If there already exists the aid, throw exception*/
			select count(aid) into account_valid from Accounts where aid = aid2;
			if account_valid > 0 then
				raise duplicate_aid;
			end if;
			select to_char(sysdate, 'DD-MON-YYYY') current_time into curr_time from dual;
			insert into Accounts (aid, account_type, rate, balance, date_opened) values (aid2, account_type2, rate2, balance2, 
curr_time);
			
			insert into Transactions (trans_num, eid, cid, aid, amount, transaction_type, date_trans) values (trans_num2, eid2, cid2, 
aid2, balance2, 'Open', curr_time);
		exception
			when no_cid_found then
				raise_application_error(-20001, 'The cid is invalid.');
			when duplicate_aid then
				raise_application_error(-20001, 'Duplicate aid.');
		end;
		
	/*Procedure: Adds a transaction to the Transactions table and executes the transaction
		Parameters: eid, cid, aid, amount, transaction_type
		Return: none
	*/
	procedure add_transaction(eid2 in Transactions.eid%type, cid2 in Transactions.cid%type, aid2 in Transactions.aid%type, amount2 in 
Transactions.amount%type, transaction_type2 in Transactions.transaction_type%type, trans_num2 in Transactions.trans_num%type) is
		last_trans_num char(7);
		acc_type varchar2(20);
		curr_time date;
		count_rows number(10);
		begin
			/*Find current time*/
			select to_char(sysdate, 'DD-MON-YYYY') current_time into curr_time from dual;
			if transaction_type2 = 'Open' then
				if aid2 < 3000 then
					acc_type := 'Checking';
				elsif aid2 < 4000 then
					acc_type := 'Savings';
				else
					acc_type := 'CD';
				end if;
				insert into Accounts (aid, account_type, rate, balance, date_opened) values (aid2, acc_type, 0, amount2, curr_time);
			end if;
			insert into Transactions (trans_num, eid, cid, aid, amount, transaction_type, date_trans) values (trans_num2, eid2, cid2, 
aid2, amount2, transaction_type2, curr_time);
			/*Implement corresponding transaction_type*/
			if transaction_type2 = 'Deposit' then
				update Accounts a set a.balance = (a.balance + amount2) where a.aid = aid2;
			end if;
			if transaction_type2 = 'Withdraw' then
				update Accounts a set a.balance = (a.balance - amount2) where a.aid = aid2;
			end if;
		end;
		
	/*Function: Show logging information logged by triggers
		Parameters: eid, cid, aid, amount, transaction_type
		Return: none
	*/
	function show_logs return ref_cursor as
		rc ref_cursor;
		begin
			/*Link cursor pointer to query and return it*/
			open rc for
				select * from logs order by logid asc;
				return rc;
		end;
		
end;
/
show errors
