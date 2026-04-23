using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace QLSieuThi
{
    public partial class FrmUserInfo : Form
    {
        public FrmUserInfo()
        {
            InitializeComponent();
        }

        private void FrmUserInfo_Load(object sender, EventArgs e)
        {
            // CHANGEABLE
            RefreshUserInfo();

            // READ ONLY
            txtRole.ReadOnly = true;
            txtRole.Text = UserSession.RoleName;

            txtLoginTime.ReadOnly = true;
            txtLoginTime.Text = UserSession.LoginTime.ToString("dd/MM/yyyy - HH:mm:ss");
        }

        private void RefreshUserInfo()
        {
            txtUserFullname.Text = UserSession.FullName;
            txtUsername.Text = UserSession.Username;
            txtPhone.Text = UserSession.Phone;
            txtEmail.Text = UserSession.Email;
            txtAddress.Text = UserSession.Address;
        }

        private void btnUpdateUserInfo_Click(object sender, EventArgs e)
        {
            string fullName = txtUserFullname.Text.Trim();
            string username = txtUsername.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string email = txtEmail.Text.Trim();
            string address = txtAddress.Text.Trim();

            // Check if anything changed (null-safe)
            if ((fullName ?? "") == (UserSession.FullName ?? "") &&
                (username ?? "") == (UserSession.Username ?? "") &&
                (phone ?? "") == (UserSession.Phone ?? "") &&
                (email ?? "") == (UserSession.Email ?? "") &&
                (address ?? "") == (UserSession.Address ?? ""))
            {
                MessageBox.Show("Không có thông tin gì mới.");
                return;
            }

            // Prevents user from spamming update
            btnUpdateUserInfo.Enabled = false;
            try
            {
                DatabaseHelper db = new DatabaseHelper();

                var result = db.ExecuteQuery(
                    "sp_UpdateMyProfile",
                    new SqlParameter("@EmployeeId", UserSession.EmployeeId),
                    new SqlParameter("@FullName", string.IsNullOrWhiteSpace(fullName) ? (object)DBNull.Value : fullName),
                    new SqlParameter("@Username", string.IsNullOrWhiteSpace(username) ? (object)DBNull.Value : username),
                    new SqlParameter("@Phone", string.IsNullOrWhiteSpace(phone) ? (object)DBNull.Value : phone),
                    new SqlParameter("@Email", string.IsNullOrWhiteSpace(email) ? (object)DBNull.Value : email),
                    new SqlParameter("@Address", string.IsNullOrWhiteSpace(address) ? (object)DBNull.Value : address)
                );

                //  Sync session with DB
                if (result.Rows.Count > 0)
                {
                    var row = result.Rows[0];

                    UserSession.FullName = row["FullName"]?.ToString();
                    UserSession.Username = row["Username"]?.ToString();
                    UserSession.Phone = row["Phone"]?.ToString();
                    UserSession.Email = row["Email"]?.ToString();
                    UserSession.Address = row["Address"]?.ToString();
                }

                //  Refresh info
                ((FrmMain)this.MdiParent)?.RefreshUserName();

                RefreshUserInfo();

                MessageBox.Show("Cập nhật thành công.");
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
            finally
            {
                btnUpdateUserInfo.Enabled = true;
            }
        }
    }
}
