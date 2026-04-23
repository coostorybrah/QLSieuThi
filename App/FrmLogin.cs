using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace QLSieuThi
{
    public partial class FrmLogin : Form
    {
        public event Action LoginSuccess;

        public FrmLogin()
        {
            InitializeComponent();
        }

        private void btnLogin_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtUsername.Text) || 
                string.IsNullOrWhiteSpace(txtPassword.Text))
            {
                MessageBox.Show("Please enter username and password.");
                return;
            }

            DatabaseHelper db = new DatabaseHelper();
            try
            {
                var result = db.ExecuteQuery(
                    "sp_LoginEmployee",
                    new SqlParameter("@Username", txtUsername.Text),
                    new SqlParameter("@Password", txtPassword.Text)
                );

                if (result.Rows.Count > 0)
                {
                    UserSession.EmployeeId = Convert.ToInt32(result.Rows[0]["EmployeeId"]);
                    UserSession.FullName = result.Rows[0]["FullName"].ToString();
                    UserSession.Username = result.Rows[0]["Username"].ToString();
                    UserSession.Phone = result.Rows[0]["Phone"].ToString();
                    UserSession.Email = result.Rows[0]["Email"].ToString();
                    UserSession.Address = result.Rows[0]["Address"].ToString();
                    UserSession.RoleName = result.Rows[0]["RoleName"].ToString();
                    UserSession.LoginTime = DateTime.Now;

                    LoginSuccess?.Invoke();

                    this.Hide();
                }
                else
                {
                    MessageBox.Show("Invalid username or password.");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }
    }
}
