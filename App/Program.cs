using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace QLSieuThi
{
    internal static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            bool DEV_MODE = true;

            if (DEV_MODE)
            {
                DatabaseHelper db = new DatabaseHelper();

                int devUserId = 1; // Must exist in DB

                var result = db.ExecuteQuery(
                    "sp_GetMyProfile",
                    new SqlParameter("@EmployeeId", devUserId)
                );

                if (result.Rows.Count == 0)
                {
                    MessageBox.Show("Dev user not found.");
                    return;
                }

                var row = result.Rows[0];

                UserSession.EmployeeId = Convert.ToInt32(row["EmployeeId"]);
                UserSession.FullName = row["FullName"].ToString();
                UserSession.Username = row["Username"].ToString();
                UserSession.Phone = row["Phone"].ToString();
                UserSession.Email = row["Email"].ToString();
                UserSession.Address = row["Address"].ToString();
                UserSession.RoleName = row["RoleName"].ToString();
                UserSession.LoginTime = DateTime.Now;

                Application.Run(new FrmMain());
            }

            else
            {
                FrmLogin login = new FrmLogin();

                login.LoginSuccess += () =>
                {
                    ShowMainForm(login);
                };

                Application.Run(login);
            }
        }
        private static void ShowMainForm(FrmLogin login)
        {
            login.Hide();

            FrmMain main = new FrmMain();

            // When main closes → show login again
            main.FormClosed += (s, e) => login.Show();

            main.Show();
        }
    }
}