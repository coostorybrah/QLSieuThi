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
    public partial class FrmInvoice : Form
    {
        private int _saleId;

        public FrmInvoice(int saleId)
        {
            InitializeComponent();
            _saleId = saleId;
        }

        private void FrmInvoice_Load(object sender, EventArgs e)
        {
            LoadReport();
        }

        private void LoadReport()
        {
            try
            {
                DatabaseHelper db = new DatabaseHelper();

                var dt = db.ExecuteQuery(
                    "sp_ReportInvoice",
                    new SqlParameter("@SaleId", _saleId)
                );

                var report = new InvoiceReport();

                report.SetDataSource(dt);

                crViewer.ReportSource = report;
                crViewer.Refresh();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }
    }
}
