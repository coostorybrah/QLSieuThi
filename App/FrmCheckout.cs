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
    public partial class FrmCheckout : Form
    {
        private decimal totalAmount;
        public decimal AmountPaid { get; private set; }

        public FrmCheckout(List<CartItem> cart, decimal total)
        {
            InitializeComponent();

            totalAmount = total;

            lblTotalValue.Text = total.ToString("N0") + " ₫";

            LoadCartSummary(cart);
        }

        protected override void OnShown(EventArgs e)
        {
            base.OnShown(e);
            lblChangeValue.Text = "Không đủ tiền";
            txtAmountPaid.Focus();
        }

        private void LoadCartSummary(List<CartItem> cart)
        {
            lstSummary.Items.Clear();

            foreach (var item in cart)
            {
                lstSummary.Items.Add(
                    $"{item.ProductName} x{item.Quantity} - {item.Total:N0} ₫"
                );
            }
        }

        private void txtAmountPaid_TextChanged(object sender, EventArgs e)
        {
            if (decimal.TryParse(txtAmountPaid.Text, out decimal paid))
            {
                decimal change = paid - totalAmount;

                lblChangeValue.Text = change >= 0
                    ? change.ToString("N0") + " ₫"
                    : "Không đủ tiền";
            }
            else
            {
                lblChangeValue.Text = "Không đủ tiền";
            }
        }

        private void btnConfirm_Click(object sender, EventArgs e)
        {
            if (!decimal.TryParse(txtAmountPaid.Text, out decimal paid))
            {
                MessageBox.Show("Số tiền không hợp lệ.");
                return;
            }

            if (paid < totalAmount)
            {
                MessageBox.Show("Khách chưa đưa đủ tiền.");
                return;
            }

            AmountPaid = paid;

            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }
    }
}
