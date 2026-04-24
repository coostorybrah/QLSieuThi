using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

public class DatabaseHelper
{
    private readonly string _connectionString;

    public DatabaseHelper()
    {
        _connectionString = GetValidConnectionString();
    }

    // Execute SELECT (returns DataTable)
    public DataTable ExecuteQuery(string procedure, params SqlParameter[] parameters)
    {
        using (SqlConnection conn = new SqlConnection(_connectionString))
        using (SqlCommand cmd = new SqlCommand(procedure, conn))
        {
            cmd.CommandType = CommandType.StoredProcedure;

            if (parameters != null)
                cmd.Parameters.AddRange(parameters);

            SqlDataAdapter adapter = new SqlDataAdapter(cmd);
            DataTable table = new DataTable();
            adapter.Fill(table);

            return table;
        }
    }

    // Execute INSERT/UPDATE/DELETE
    public int ExecuteNonQuery(string procedure, params SqlParameter[] parameters)
    {
        using (SqlConnection conn = new SqlConnection(_connectionString))
        using (SqlCommand cmd = new SqlCommand(procedure, conn))
        {
            cmd.CommandType = CommandType.StoredProcedure;

            if (parameters != null)
                cmd.Parameters.AddRange(parameters);

            conn.Open();
            return cmd.ExecuteNonQuery();
        }
    }

    private string GetValidConnectionString()
    {
        string[] sources =
        {
        @"Data Source=.;Initial Catalog=QLSieuThiDB;Integrated Security=True",
        @"Data Source=.\SQLEXPRESS;Initial Catalog=QLSieuThiDB;Integrated Security=True",
        @"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=QLSieuThiDB;Integrated Security=True"
    };

        foreach (var connectionString in sources)
        {
            try
            {
                using (SqlConnection connection = new SqlConnection(connectionString))
                {
                    connection.Open();
                    return connectionString; // success
                }
            }
            catch { }
        }

        throw new Exception("No valid SQL Server instance found.");
    }
}