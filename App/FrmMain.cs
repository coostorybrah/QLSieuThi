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
        public FrmMain()
        {
            InitializeComponent();
            this.IsMdiContainer = true;
        }
        protected override void OnShown(EventArgs e)
        {
            base.OnShown(e);

            OpenChildForm(new FrmUserInfo());
        }

        private void FrmMain_Load(object sender, EventArgs e)
        {
            if (!UserSession.IsLoggedIn)
            {
                MessageBox.Show("Unauthorized access.");
                this.Close();
                return;
            }

            this.LayoutMdi(MdiLayout.Cascade);

            RefreshUserName();
        }
        
        public void RefreshUserName()
        {
            mnuUser.Text = UserSession.FullName;
        }

        public void OpenChildForm(Form child)
        {
            // Close existing children
            foreach (Form frm in this.MdiChildren.Cast<Form>().ToList())
            {
                frm.Close();
            }

            child.MdiParent = this;

            child.FormBorderStyle = FormBorderStyle.None;
            child.ControlBox = false;
            child.AutoScroll = true;

            child.Dock = DockStyle.Fill;

            child.Location = new Point(0, 0);

            child.Show();
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

        private void mnuSales_Click(object sender, EventArgs e)
        {
            OpenChildForm(new FrmSales());
        }

        private void mnuUserInfo_Click(object sender, EventArgs e)
        {
            OpenChildForm(new FrmUserInfo());
        }
    }
}
