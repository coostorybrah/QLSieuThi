using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace QLSieuThi
{
    internal static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            FrmLogin login = new FrmLogin();

            login.LoginSuccess += () =>
            {
                FrmMain main = new FrmMain();

                main.FormClosed += (s, e) =>
                {
                    login.Show(); // show login again after logout
                };

                main.Show();
            };

            Application.Run(login);
        }
    }
}
