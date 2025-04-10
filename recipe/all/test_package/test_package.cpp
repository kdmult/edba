#include <edba/edba.hpp>

#include <iostream>

using namespace edba;

int main()
{
    try 
    {
        // Use sqlite3 driver to open database connection with provided connection string
        session sess("sqlite3:db=test.db");

        // Execute query. Special once marker specify that edba should not prepare statement and cache it.
        // This is the best option for queries executed only once during application lifetime.
        sess.once() << "create temp table hello(id integer primary key autoincrement, txt text not null)" << exec;

        // Prepare, cache and execute query.
        statement st = sess << "insert into hello(txt) values(:txt)" << "Hello world" << exec; // execute statement

        // Select rows.
        // Query execution is done by implicitly converting to rowset<T>
        rowset<> rs = sess << "select * from hello";

        // Loop over rows in rowset
        for (const row& r : rs)
        {
            std::cout << "id: " << r.get<int>("id")
                << "\ttxt: " << r.get<std::string>("txt") 
                << std::endl;
        }
    }
    catch(std::exception& e)
    {
        std::cout << e.what() << std::endl;
    }

    return 0;
}
