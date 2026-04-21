using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace QLSieuThi
{
    public partial class FrmMain : Form
    {
        private int childFormNumber = 0;

        public FrmMain()
        {
            InitializeComponent();
            this.IsMdiContainer = true;
        }

        private void FrmMain_Load(object sender, EventArgs e)
        {
            if (!UserSession.IsLoggedIn)
            {
                MessageBox.Show("Unauthorized access.");
                this.Close();
                return;
            }

            mnuSystem.Text = UserSession.FullName;
        }

        private void mnuExit_Click(object sender, EventArgs e)
        {
            UserSession.Clear();
            Application.Exit();
        }

        private void mnuLogout_Click(object sender, EventArgs e)
        {
            UserSession.Clear();
            this.Close();
        }

        private void OpenChildForm(Form child)
        {
            // Close existing child (optional but clean)
            foreach (Form frm in this.MdiChildren)
            {
                frm.Close();
            }

            child.MdiParent = this;
            child.StartPosition = FormStartPosition.CenterScreen;
            child.Show();
        }
    }
}
